//
//  XHYCameraLiveView.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/21.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYCameraLiveView.h"
#import "Masonry.h"
#import "UIView+Toast.h"

static XHYCameraLiveView *cameraLiveView = nil;

static const CGFloat topNaviBarHeight = 44.0f;
static const CGFloat ToolBtnSize = 36.0f;

@interface XHYCameraLiveView (){

    XHYCameraLiveStatus _currentLiveStatus;
    NSString *_currentLiveDeviceID;
    
    UIButton *closeBtn;         //关闭按钮
    UIButton *fullScreenBtn;    //全屏按钮
    
    BOOL isMove;
    CGPoint legend_point;
}

@property(nonatomic,strong) UIView *topNaviView;        //顶部导航条
@property(nonatomic,strong) UIView *bottomToolView;     //底部工具条

@property(nonatomic,strong) UIActivityIndicatorView *loadingIndicatorView;  //加载loading
@end

@implementation XHYCameraLiveView

- (UIView *)topNaviView{
    
    if (!_topNaviView) {
        
        _topNaviView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.bounds.size.width,topNaviBarHeight)];
        _topNaviView.backgroundColor=[UIColor clearColor];
        _topNaviView.alpha = 0.5;
        _topNaviView.userInteractionEnabled = YES;
        
        closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setBackgroundColor:[UIColor clearColor]];
        [closeBtn setImage:[UIImage imageNamed:@"camera_back_normal"] forState:UIControlStateNormal];
        [closeBtn setImage:[UIImage imageNamed:@"camera_back_press"] forState:UIControlStateHighlighted];
        [closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [fullScreenBtn setBackgroundColor:[UIColor clearColor]];
        [fullScreenBtn setImage:[UIImage imageNamed:@"camera_fullscreen_normal"] forState:UIControlStateNormal];
        [fullScreenBtn setImage:[UIImage imageNamed:@"camera_fullscreen_press"] forState:UIControlStateHighlighted];
        [fullScreenBtn addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
        
        [_topNaviView addSubview:closeBtn];
        [_topNaviView addSubview:fullScreenBtn];
        
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(ToolBtnSize, ToolBtnSize));
            make.centerY.mas_equalTo(_topNaviView.mas_centerY);
            make.left.mas_equalTo(_topNaviView.mas_left).offset(15);
        }];
        [fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(ToolBtnSize, ToolBtnSize));
            make.centerY.mas_equalTo(_topNaviView.mas_centerY);
            make.right.mas_equalTo(_topNaviView.mas_right).offset(-15);
        }];
    }
    
    return _topNaviView;
}

- (UIActivityIndicatorView *)loadingIndicatorView{
    
    if (!_loadingIndicatorView) {
        
        _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingIndicatorView.hidesWhenStopped = YES;
        _loadingIndicatorView.center = self.center;
    }
    
    return _loadingIndicatorView;
}

+ (Class)layerClass{
    
    return [CAEAGLLayer class];
}

+ (instancetype)defaultCameraLiveView{

    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        if (!cameraLiveView) {
            
            cameraLiveView = [[XHYCameraLiveView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, 200.0f)];
        }
    });
    
    return cameraLiveView;
}

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]){
        
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        //[[UIApplication sharedApplication] setStatusBarHidden:YES];

        [self addSubview:self.topNaviView];
        [self addSubview:self.loadingIndicatorView];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePan:)];
        [self addGestureRecognizer:panGestureRecognizer];
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    [self.topNaviView setFrame:CGRectMake(0.0f, 0.0f,bounds.size.width,topNaviBarHeight)];
    /*
    [self.talkBtn setFrame:CGRectMake(controlBtnSpace, (CGRectGetHeight(bounds) - controlBtnSize)/2, controlBtnSize + 20, controlBtnSize + 20)];
    
    [self.scpingBtn setFrame:CGRectMake(CGRectGetWidth(bounds) - controlBtnSpace - 100.0f, (CGRectGetHeight(bounds) - controlBtnSize)/2, 100.0f, controlBtnSize)];
    
    
    
    [self.bottomToolView setFrame:CGRectMake(0.0f, bounds.size.height - bottomToolViewHeight,bounds.size.width,bottomToolViewHeight)];
    
    self.bottomToolView.hidden = !(self.isFullScreen && isPlaying);
    
    NSInteger itemCount = [self.bottomToolView.subviews count];
    
    CGFloat spacex = (CGRectGetWidth(self.bottomToolView.bounds) - itemCount * controlBtnSize - (itemCount - 1) * controlBtnSpace)/2;
    
    for (int j = 0; j < itemCount; j++ ) {
        
        UIButton *btn = [self.bottomToolView.subviews objectAtIndex:j];
        [btn setFrame:CGRectMake(spacex + j * (controlBtnSize + controlBtnSpace), (CGRectGetHeight(self.bottomToolView.bounds) - controlBtnSize)/2, controlBtnSize, controlBtnSize)];
        [btn setHidden:self.bottomToolView.hidden];
    }
    
    [self.cameraCollectionView setFrame:CGRectMake(0.0f, (bounds.size.height - cameraCollectionViewHeight)/2, bounds.size.width, cameraCollectionViewHeight)];
    */
    [self.loadingIndicatorView setCenter:CGPointMake(CGRectGetWidth(bounds)/2, CGRectGetHeight(bounds)/2)];
}

#pragma mark ----- 

- (void)closeBtnClick:(id)sender{

    [self removeFromSuperview];
}

- (void)fullScreen:(id)sender{

}

- (void)startCameraLive:(XHYSmartDevice *)liveCamera{
    
    if (!liveCamera){
        
        return;
    }
    
    NSString *uid = [liveCamera.cameraInfo objectForKey:@"uid"];
    //NSString *user = [liveCamera.cameraInfo objectForKey:@"name"];
    //NSString *pwd = [liveCamera.cameraInfo objectForKey:@"password"];
    //char *szPort = (char *)[@"34567" UTF8String];
    
    if ([uid length]){
        
        [self.loadingIndicatorView startAnimating];
        
       // NSString *devId = [NSString stringWithFormat:@"%@:%s",uid,szPort];
        
        /*
        currentPlayCamera = camera;
        currentPlayCameraSerialID = devId;
        // 开始准备播放
        FUN_UnRegWnd(_playHandle);
        _playHandle = FUN_RegWnd((__bridge void*)self);
        FUN_DevLogin(_playHandle, [devId UTF8String], [user UTF8String],[pwd UTF8String],0);
        */
        
    }else{
        
        [self makeToast:@"无效序列号" duration:1.0f position:CSToastPositionCenter];
    }
    
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer{
    
    /*
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
                                         recognizer.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.center = finalPoint;
        } completion:nil];
    }
    */
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    isMove = NO;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    
    if (CGRectContainsPoint(self.superview.frame, point)) {
        
        legend_point = [touch locationInView:self];
        isMove = YES;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesMoved:touches withEvent:event];
    
    if (!isMove) {
        return;
    }
    @autoreleasepool {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.superview];
        //转化成相对的中心
        point.x += self.frame.size.width/2.0f - legend_point.x;
        point.y += self.frame.size.height/2.0f - legend_point.y;
        //        限制范围
        if (point.x < self.frame.size.width / 2.0f) {
            point.x = self.frame.size.width / 2.0f;
        }
        if (point.y < self.frame.size.height / 2.0f) {
            point.y = self.frame.size.height / 2.0f;
        }
        
        if (point.x > self.frame.size.width - self.frame.size.width / 2.0f) {
            point.x = self.frame.size.width - self.frame.size.width / 2.0f;
        }
        if (point.y > self.frame.size.height - self.frame.size.height / 2.0f) {
            point.y = self.frame.size.height - self.frame.size.height / 2.0f;
        }
        
        self.center = point;
    }
}

@end

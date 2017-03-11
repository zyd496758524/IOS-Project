//
//  XHYCurtainControlViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYCurtainControlViewController.h"

#import "XHYCurtainView.h"

static const CGFloat controlBtnSize = 60.0f;

@interface XHYCurtainControlViewController (){

    UIButton *stopBtn;
    UIButton *openBtn;
    UIButton *closeBtn;
}

@property(nonatomic,strong) XHYCurtainView *curtainView;
@property(nonatomic,strong) UIView *controlView;

@end

@implementation XHYCurtainControlViewController

- (XHYCurtainView *)curtainView{

    if (!_curtainView) {
        
        _curtainView = [[XHYCurtainView alloc] init];
        _curtainView.backgroundColor = [UIColor clearColor];
    }
    
    return _curtainView;
}

- (UIView *)controlView{

    if (!_controlView){
        
        _controlView = [[UIView alloc] init];
        _controlView.backgroundColor = [UIColor whiteColor];
        
        openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [openBtn setImage:[UIImage imageNamed:@"curtain_open_normal"] forState:UIControlStateNormal];
        [openBtn setImage:[UIImage imageNamed:@"curtain_open_press"] forState:UIControlStateHighlighted];
        [openBtn addTarget:self action:@selector(curtainOpen:) forControlEvents:UIControlEventTouchUpInside];
        
        stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [stopBtn setImage:[UIImage imageNamed:@"curtain_stop_normal"] forState:UIControlStateNormal];
        [stopBtn setImage:[UIImage imageNamed:@"curtain_stop_press"] forState:UIControlStateHighlighted];
        [stopBtn addTarget:self action:@selector(curtainStop:) forControlEvents:UIControlEventTouchUpInside];

        closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"curtain_close_normal"] forState:UIControlStateNormal];
        [closeBtn setImage:[UIImage imageNamed:@"curtain_close_press"] forState:UIControlStateHighlighted];
        [closeBtn addTarget:self action:@selector(curtainClose:) forControlEvents:UIControlEventTouchUpInside];
        
        [_controlView addSubview:stopBtn];
        [_controlView addSubview:openBtn];
        [_controlView addSubview:closeBtn];
        
        [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.mas_equalTo(_controlView.mas_centerX);
            make.centerY.mas_equalTo(_controlView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(controlBtnSize, controlBtnSize));
        }];

        [openBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerY.mas_equalTo(_controlView.mas_centerY);
            make.right.mas_equalTo(stopBtn.mas_left).offset(-20.0f);
            make.size.mas_equalTo(CGSizeMake(controlBtnSize, controlBtnSize));
        }];
        
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.mas_equalTo(_controlView.mas_centerY);
            make.left.mas_equalTo(stopBtn.mas_right).offset(20.0f);
            make.size.mas_equalTo(CGSizeMake(controlBtnSize, controlBtnSize));
        }];
    }
    
    return _controlView;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @JZWeakObj(self);
    [self.view addSubview:self.controlView];
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.mas_equalTo(selfWeak.view.mas_left);
        make.right.mas_equalTo(selfWeak.view.mas_right);
        make.bottom.mas_equalTo(selfWeak.view.mas_bottom);
        make.height.mas_equalTo(80.0f);
    }];

    [self.view addSubview:self.curtainView];
    [self.curtainView mas_makeConstraints:^(MASConstraintMaker *make){
       
        make.left.mas_equalTo(selfWeak.view.mas_left);
        make.right.mas_equalTo(selfWeak.view.mas_right);
        make.top.mas_equalTo(selfWeak.view.mas_top);
        make.bottom.mas_equalTo(selfWeak.controlView.mas_top);
    }];
    
    
    [self xw_addNotificationForName:XHYCurtainProgressChanged block:^(NSNotification * _Nonnull notification){
        
        NSDictionary *dic = [notification object];
        XHYSmartDevice *msgDevice = dic[@"device"];
        if ([msgDevice isEqual:selfWeak.controlSmartDevice]){
         
            NSNumber *progressNunber = dic[@"progress"];
            CGFloat progress = [progressNunber intValue] / 100.0f;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [selfWeak.curtainView setCurtainProgress:progress];
            });
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    NSString *tempKey = [NSString stringWithFormat:@"%@#progress",self.controlSmartDevice.deviceIEEEAddrIdentifier];
    NSNumber *tempProgress = [[NSUserDefaults standardUserDefaults] objectForKey:tempKey];
    if (tempProgress){
        
        CGFloat progress = [tempProgress intValue]/100.0f;
        [self.curtainView setCurtainProgress:progress];
        
    }else{
        
        [self.curtainView setCurtainProgress:1.0f];
    }
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----- Control Send

//value: open-->0, close -->1, stop -->2.
//开窗帘
- (void)curtainOpen:(UIButton *)btn{
    
    char buffer[100] = {0};
    sendOnOffStopCmd(self.controlSmartDevice.nwkAddr, 0, buffer);
    NSString *tempStr = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendDeviceControlMsg:tempStr];
}

//暂停窗帘
- (void)curtainStop:(UIButton *)btn{
    
    char buffer[100] = {0};
    sendOnOffStopCmd(self.controlSmartDevice.nwkAddr, 2, buffer);
    NSString *tempStr = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendDeviceControlMsg:tempStr];
}

//关窗帘
- (void)curtainClose:(UIButton *)btn{
    
    char buffer[100] = {0};
    sendOnOffStopCmd(self.controlSmartDevice.nwkAddr, 1, buffer);
    NSString *tempStr = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendDeviceControlMsg:tempStr];
}

@end

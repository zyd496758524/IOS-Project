//
//  XHYRoomSelectView.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/29.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYRoomSelectView.h"

#define HEIGHT_OF_POPBOX (([UIScreen mainScreen].bounds.size.width == 414)?290:280)
#define COLOR_BACKGROUD_GRAY  [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1]

@interface XHYRoomSelectView ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic ,strong) UIView * bottomView;       //底层视图
@property (nonatomic ,strong) UIPickerView * statePicker;//运营状态轱辘
@property (nonatomic ,strong) UIView * controllerToolBar;//控制工具栏
@property (nonatomic ,strong) UIButton * finishBtn;      //取消按钮
@property (nonatomic ,strong) UIButton * cancelBtn;      //取消按钮
@property (nonatomic ,strong) UILabel * titleLabel;      //标题
@property (nonatomic ,strong) NSString * stateStr;       //选中的运营状态
@property (nonatomic, assign) NSInteger pickerHeight;    //弹层的高度

@end

@implementation XHYRoomSelectView


- (instancetype)init{
    
    if (self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.userInteractionEnabled = YES;
        [self addSubview:self.maskView];
        //self.pickerHeight = HEIGHT_OF_POPBOX - 160;
        self.pickerHeight = HEIGHT_OF_POPBOX - 24;
        //初始化子视图
        [self initSubViews];
    }
    return self;
}

/**初始化子视图*/
- (void)initSubViews
{
    //初始化轱辘的位置
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomView];
    
    //选择器
    self.statePicker = [[UIPickerView alloc] init];
    self.statePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.statePicker.backgroundColor = [UIColor whiteColor];
    self.statePicker.showsSelectionIndicator = YES;
    self.statePicker.dataSource = self;
    self.statePicker.delegate = self;
    [self.bottomView addSubview:self.statePicker];
    
    //控制栏
    self.controllerToolBar = [[UIView alloc] init];
    self.controllerToolBar.backgroundColor = COLOR_BACKGROUD_GRAY;
    [self.bottomView addSubview:_controllerToolBar];
    
    //完成按钮
    self.finishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.finishBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.finishBtn addTarget:self action:@selector(finishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.finishBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.finishBtn setTitleColor:self.tintColor forState:UIControlStateNormal];
    [self.controllerToolBar addSubview:self.finishBtn];
    
    //取消按钮
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelBtn addTarget:self action:@selector(canceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:self.tintColor forState:UIControlStateNormal];
    [self.controllerToolBar addSubview:_cancelBtn];
    
    //标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"移动到";
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.controllerToolBar addSubview:self.titleLabel];
    
}

- (void)layoutSelfSubviews
{
    //底层视图
    self.bottomView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, self.pickerHeight);
    
    //选择器
    self.statePicker.frame = CGRectMake(0, 40, ScreenWidth, self.pickerHeight - 40);
    
    //控制栏
    self.controllerToolBar.frame = CGRectMake(0, 0, ScreenWidth, 40);
    
    //完成按钮
    self.finishBtn.frame = CGRectMake(ScreenWidth - 70, 5, 70, 30);
    
    //取消按钮
    self.cancelBtn.frame = CGRectMake(0, 5, 70, 30);
    
    //标题
    self.titleLabel.frame = CGRectMake(70, 5, ScreenWidth - 140, 30);
    
}

#pragma mark - set相关

- (void)setDataSource:(NSArray *)dataSource{
    
    _dataSource = dataSource;
    
    //设置弹层高度
    /*
     if (HEIGHT_PICKER > HEIGHT_OF_POPBOX - 24) {
     self.pickerHeight = HEIGHT_OF_POPBOX - 24;
     } else {
     self.pickerHeight = HEIGHT_PICKER;
     }
     */
    //设置返回默认值
    //self.stateStr = _dataSource[0];
    
    //刷新布局
    [self layoutSelfSubviews];
    [self.statePicker setNeedsLayout];
    
    //刷新轱辘数据
    //[self.statePicker reloadAllComponents];
    //[self.statePicker selectRow:0 inComponent:0 animated:NO];
}

- (void)setDefaultStr:(NSString *)defaultStr{
    
    _defaultStr = defaultStr;
    self.stateStr = defaultStr;
    
    NSArray *tempArray = [self.stateStr componentsSeparatedByString:@"/"];
    if ([tempArray count]){
        
        [self.dataSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj[@"name"] isEqualToString:[tempArray firstObject]]){
                
                NSArray *roomArr = obj[@"scences"];
                
                if ([roomArr count]){
                    
                    [roomArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                        
                        if ([obj1[@"scenceName"] isEqualToString:[tempArray lastObject]]){
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [self.statePicker selectRow:idx inComponent:0 animated:NO];
                                [self.statePicker selectRow:idx1 inComponent:1 animated:NO];
                                [self.statePicker reloadAllComponents];
                            });
                            *stop1 = YES;
                            *stop = YES;
                        }
                    }];
                }
            }
        }];
    }
}

/*
- (void)setPickerTitle:(NSString *)pickerTitle
{
    _pickerTitle = pickerTitle;
    self.titleLabel.text = pickerTitle;
}
*/

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 34.0f;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (0 == component){
        
        return self.dataSource.count;
        
    }else{
        
        NSInteger index = [self.statePicker selectedRowInComponent:0];
        NSDictionary *floorDic = [self.dataSource objectAtIndex:index];
        return [[floorDic objectForKey:@"scences"] count];
    }
    
    return self.dataSource.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (0 == component){
        
        NSDictionary *floorDic = [self.dataSource objectAtIndex:row];
        return floorDic[@"name"];
        
    }else if (1 == component){
        
        NSInteger index = [self.statePicker selectedRowInComponent:0];
        NSDictionary *floorDic = [self.dataSource objectAtIndex:index];
        NSArray *roomArray = floorDic[@"scences"];
        if (row < [roomArray count]){
            
            return roomArray[row][@"scenceName"];
            
        }else{
            
            return nil;
        }
        
    }else{
    
        return nil;
    }
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    switch(component){
            
        case 0:{
            
            [self.statePicker reloadComponent:1];
        }
            break;
            
        default:
            break;
    }
    
    //[self.statePicker reloadAllComponents];
    NSLog(@"didSelectRow row--->%ld component--->%ld",(long)row,(long)component);
    
    NSInteger tempSection = [self.statePicker selectedRowInComponent:0];
    NSInteger tempRow = [self.statePicker selectedRowInComponent:1];
    
    NSMutableString *tempString = [NSMutableString string];
    NSDictionary *floorDic = [self.dataSource objectAtIndex:tempSection];
    if ([floorDic[@"name"] length]){
        
        [tempString appendFormat:@"%@/",floorDic[@"name"]];
    }
    NSArray *roomArray = floorDic[@"scences"];
    
    if (tempRow < [roomArray count]){
        
        if ([roomArray[tempRow][@"scenceName"] length]){
            
            [tempString appendString:roomArray[tempRow][@"scenceName"]];
        }
    }
    
    self.stateStr = tempString;
    tempString = nil;
}

#pragma mark - 按钮相关

/**点击完成按钮*/
- (void)finishBtnClicked:(UIButton *)button{
    
    if (self.roomDidSelect){
        
        self.roomDidSelect(self.stateStr);
    }
    
    [self removeSelfFromSupView];
}

/**点击取消按钮*/
- (void)canceBtnClicked:(UIButton *)button{
    
    [self removeSelfFromSupView];
}

/**点击背景释放界面*/
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self removeSelfFromSupView];
}

#pragma mark - 显示弹层相关

/**弹出视图*/
- (void)show{
    
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    
    //动画出现
    CGRect frame = self.bottomView.frame;
    if (frame.origin.y == ScreenHeight) {
        frame.origin.y -= self.pickerHeight;
        [UIView animateWithDuration:0.3 animations:^{
            
            self.bottomView.frame = frame;
            
        }completion:^(BOOL finished) {
            
        }];
    }
}

/**移除视图*/
- (void)removeSelfFromSupView{
    
    CGRect selfFrame = self.bottomView.frame;
    
    if (selfFrame.origin.y == ScreenHeight - self.pickerHeight){
        
        selfFrame.origin.y += self.pickerHeight;
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomView.frame = selfFrame;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

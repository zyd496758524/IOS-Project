//
//  XHYCenterControlViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2017/2/7.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYCenterControlViewController.h"
#import "UIButton+ImageTitleSpacing.h"

#define kTagCenterBtn 11000
#define kTagCenterBtn1 26
#define kTagCenterBtn2 27
#define kTagCenterBtn3 28

static CGFloat const centerBtnSize = 60.0f;

@interface XHYCenterControlViewController ()

@property(nonatomic,strong) UIButton *centerBtn1;
@property(nonatomic,strong) UIButton *centerBtn2;
@property(nonatomic,strong) UIButton *centerBtn3;

@property(nonatomic,strong) UIView *centerView;

@end

@implementation XHYCenterControlViewController

- (UIButton *)centerBtn1{

    if (!_centerBtn1) {
        
        _centerBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerBtn1.backgroundColor = [UIColor brownColor];
        _centerBtn1.layer.cornerRadius = 6.0f;
        _centerBtn1.tag = kTagCenterBtn + kTagCenterBtn1;
        [_centerBtn1 setTitle:@"中控一键" forState:UIControlStateNormal];
        [_centerBtn1.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_centerBtn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_centerBtn1 addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_centerBtn1 layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:2.0f];
    }
    
    return _centerBtn1;
}

- (UIButton *)centerBtn2{
    
    if (!_centerBtn2) {
        
        _centerBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerBtn2.backgroundColor = [UIColor purpleColor];
        _centerBtn2.layer.cornerRadius = 6.0f;
        _centerBtn2.tag = kTagCenterBtn + kTagCenterBtn2;
        [_centerBtn2 setTitle:@"中控二键" forState:UIControlStateNormal];
        [_centerBtn2.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_centerBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_centerBtn2 addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_centerBtn2 layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:2.0f];
    }
    
    return _centerBtn2;
}

- (UIButton *)centerBtn3{
    
    if (!_centerBtn3) {
        
        _centerBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerBtn3.backgroundColor = [UIColor orangeColor];
        _centerBtn3.layer.cornerRadius = 6.0f;
        _centerBtn3.tag = kTagCenterBtn + kTagCenterBtn3;
        [_centerBtn3 setTitle:@"中控三键" forState:UIControlStateNormal];
        [_centerBtn3.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_centerBtn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_centerBtn3 addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_centerBtn3 layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:2.0f];
    }
    
    return _centerBtn3;
}

- (UIView *)centerView{

    if (!_centerView){
     
        _centerView = [[UIView alloc] init];
        _centerView.backgroundColor = [UIColor whiteColor];
        
        [_centerView addSubview:self.centerBtn1];
        [_centerView addSubview:self.centerBtn2];
        [_centerView addSubview:self.centerBtn3];
        
        CGFloat spaceX = (ScreenWidth - 3 * centerBtnSize) / 4.0f;
        
        [self.centerBtn2 mas_makeConstraints:^(MASConstraintMaker *make){
           
            make.centerX.mas_equalTo(_centerView.mas_centerX);
            make.centerY.mas_equalTo(_centerView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(centerBtnSize, centerBtnSize));
        }];
        [self.centerBtn1 mas_makeConstraints:^(MASConstraintMaker *make){
            
            make.right.mas_equalTo(self.centerBtn2.mas_left).offset(-spaceX);
            make.centerY.mas_equalTo(_centerView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(centerBtnSize, centerBtnSize));
        }];
        [self.centerBtn3 mas_makeConstraints:^(MASConstraintMaker *make){
            
            make.left.mas_equalTo(self.centerBtn2.mas_right).offset(spaceX);
            make.centerY.mas_equalTo(_centerView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(centerBtnSize, centerBtnSize));
        }];
    }
    
    return _centerView;
}

#pragma mark ----- Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.centerView];
    @JZWeakObj(self);
    [self.centerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.mas_equalTo(selfWeak.view.mas_left);
        make.right.mas_equalTo(selfWeak.view.mas_right);
        make.height.mas_equalTo(centerBtnSize + 20);
        make.bottom.mas_equalTo(selfWeak.view.mas_bottom);//.offset(-0.3 * (ScreenHeight - 64.0f))
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----- UIButton Click

- (void)centerBtnClick:(id)sender{

    UIButton *tempCenterBtn = (UIButton *)sender;
    NSInteger btnTag = tempCenterBtn.tag - kTagCenterBtn;
    char buffer[1000] = {0};
    sendAppCtlEventCmd(self.controlSmartDevice.nwkAddr,self.controlSmartDevice.endPoint, btnTag, 0, buffer);
    NSString *msgStr = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendDeviceControlMsg:msgStr];
}

@end

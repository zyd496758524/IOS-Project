//
//  XHYLightControlViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYLightControlViewController.h"

@interface XHYLightControlViewController ()

@property(nonatomic,strong) UIButton *powerBtn;

@end

@implementation XHYLightControlViewController

- (UIButton *)powerBtn{

    if (!_powerBtn) {
        
        _powerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _powerBtn.backgroundColor = [UIColor clearColor];
        [_powerBtn setImage:[UIImage imageNamed:@"device_control_power_on"] forState:UIControlStateNormal];
        [_powerBtn setBackgroundColor:[UIColor whiteColor]];
        [_powerBtn addTarget:self action:@selector(lightPowerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _powerBtn;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.powerBtn];
    @JZWeakObj(self);
    [self.powerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
//        make.centerX.mas_equalTo(selfWeak.view.mas_centerX);
//        make.centerY.mas_equalTo(selfWeak.view.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(100.0f, 100.0f));
        make.left.mas_equalTo(selfWeak.view.mas_left);
        make.right.mas_equalTo(selfWeak.view.mas_right);
        make.bottom.mas_equalTo(selfWeak.view.mas_bottom);
        make.height.mas_equalTo(80.0f);
    }];
    
    [self xw_addNotificationForName:XHYDeviceWorkStatusChanged block:^(NSNotification * _Nonnull notification){
        
        NSDictionary *dic = [notification object];
        XHYSmartDevice *msgDevice = dic[@"device"];
        
        if ([msgDevice isEqual:self.controlSmartDevice]){
            
            self.controlSmartDevice = msgDevice;
            [self reloadPowerBtnImage:self.controlSmartDevice.deviceWorkStatus];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self reloadPowerBtnImage:self.controlSmartDevice.deviceWorkStatus];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----

- (void)reloadPowerBtnImage:(NSInteger)workStatus{

    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (workStatus){
            
            [_powerBtn setImage:[UIImage imageNamed:@"device_control_power_on"] forState:UIControlStateNormal];
            
            
        }else{
            
            [_powerBtn setImage:[UIImage imageNamed:@"device_control_power_off"] forState:UIControlStateNormal];
        }
    });
}

#pragma mark ----- 开关按钮事件

- (void)lightPowerBtnClick:(id)sender{
    
    if (self.controlSmartDevice.deviceID == XHY_DEVICE_ColorModule){
        
        NSInteger workStatus = self.controlSmartDevice.deviceWorkStatus ? 0 : 1;
        
        unsigned char sendChar = [[NSNumber numberWithInteger:workStatus] unsignedCharValue];
        
        char buffer[1000] = {0};
        sendDimmerOnOffCmd(self.controlSmartDevice.nwkAddr, self.controlSmartDevice.endPoint,sendChar, buffer);
        NSString *msgStr = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
        [XHYMsgSendTool sendDeviceControlMsg:msgStr];

        return;
    }
    
    NSInteger workStatus = self.controlSmartDevice.deviceWorkStatus ? 0 : 1;
    unsigned char sendChar = [[NSNumber numberWithInteger:workStatus] unsignedCharValue];
    char buffer[1000] = {0};
    setOnOffCmd(self.controlSmartDevice.nwkAddr,self.controlSmartDevice.endPoint,sendChar,buffer);
    NSString *msgStr = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendDeviceControlMsg:msgStr];
}

@end

//
//  XHYRootControlViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYRootControlViewController.h"
#import "UIImage+Blur.h"
#import "XHYDeviceEditViewController.h"
#import "CBAutoScrollLabel.h"
#import "XHYFontTool.h"

@interface XHYRootControlViewController ()

@property(nonatomic,strong) CBAutoScrollLabel *warnScrollLabel;

@end

@implementation XHYRootControlViewController

- (CBAutoScrollLabel *)warnScrollLabel{

    if (!_warnScrollLabel){
        
        _warnScrollLabel = [[CBAutoScrollLabel alloc] init];
        _warnScrollLabel.scrollDirection = CBAutoScrollDirectionLeft;
        _warnScrollLabel.backgroundColor = [UIColor redColor];
        _warnScrollLabel.textColor = [UIColor whiteColor];
        _warnScrollLabel.textAlignment = NSTextAlignmentCenter;
        _warnScrollLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:14.0f];
        _warnScrollLabel.text = @"此设备已离线！只有保证设备在线才能控制";
    }
    
    return _warnScrollLabel;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"backgroud_common.png"].CGImage);
    self.view.backgroundColor = BackgroudColor;
    
    @JZWeakObj(self);
    [self.view addSubview:self.warnScrollLabel];
    [self.warnScrollLabel mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.mas_equalTo(selfWeak.view.mas_left);
        make.right.mas_equalTo(selfWeak.view.mas_right);
        make.top.mas_equalTo(selfWeak.view.mas_top);
        make.height.mas_equalTo(0);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(enterDeviceEditController:)];
    
    [self xw_addNotificationForName:XHYDeviceNameChanged block:^(NSNotification * _Nonnull notification){
        
        XHYSmartDevice *tempSmartDevice = [notification object];
        if ([tempSmartDevice isEqual:selfWeak.controlSmartDevice]){
            
            selfWeak.controlSmartDevice.customDeviceName = tempSmartDevice.customDeviceName;
            selfWeak.navigationItem.title = [self.controlSmartDevice.customDeviceName length] ? self.controlSmartDevice.customDeviceName : self.controlSmartDevice.deviceName;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = [self.controlSmartDevice.customDeviceName length] ? self.controlSmartDevice.customDeviceName : self.controlSmartDevice.deviceName;
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    if (!self.controlSmartDevice.deviceOnlineStatus){
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.warnScrollLabel mas_updateConstraints:^(MASConstraintMaker *make){
                make.height.mas_equalTo(30.0f);
            }];
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enterDeviceEditController:(id)sender{

    XHYDeviceEditViewController *deviceEditViewController = [[XHYDeviceEditViewController alloc] init];
    deviceEditViewController.editSmartDevice = self.controlSmartDevice;
    [self.navigationController pushViewController:deviceEditViewController animated:YES];
}

- (void)dealloc{

    [self xw_removeNotificationForName:XHYDeviceNameChanged];
}

@end

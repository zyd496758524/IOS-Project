//
//  XHYRootTabBarController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/11.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYRootTabBarController.h"

#import "UIImage+Color.h"
#import "UIColor+JKHEX.h"
#import "UIView+Toast.h"

#import "XHYDeviceListViewController.h"
#import "XHYMsgListViewController.h"
#import "XHYModeListViewController.h"
#import "XHYCenterViewController.h"
#import "XHYSettingViewController.h"

#import "AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "JDStatusBarNotification.h"

@interface XHYRootTabBarController ()

@end

@implementation XHYRootTabBarController

- (instancetype)init{

    if (self = [super init]){
        
        XHYDeviceListViewController *deviceListViewController = [[XHYDeviceListViewController alloc] init];
        UINavigationController *navi_device = [[UINavigationController alloc] initWithRootViewController:deviceListViewController];
        navi_device.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设备" image:[UIImage imageNamed:@"tabbar_msg_normal"] selectedImage:[UIImage imageNamed:@"tabbar_msg_select"]];
        
        XHYMsgListViewController *msgListViewController = [[XHYMsgListViewController alloc] init];
        UINavigationController *navi_msg = [[UINavigationController alloc] initWithRootViewController:msgListViewController];
        navi_msg.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息" image:[UIImage imageNamed:@"tabbar_msg_normal"] selectedImage:[UIImage imageNamed:@"tabbar_msg_select"]];
        
        XHYModeListViewController *modeListViewController = [[XHYModeListViewController alloc] init];
        UINavigationController *navi_mode = [[UINavigationController alloc] initWithRootViewController:modeListViewController];
        navi_mode.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"模式" image:[UIImage imageNamed:@"tabbar_mode_normal"] selectedImage:[UIImage imageNamed:@"tabbar_mode_select"]];
        
        XHYSettingViewController *setViewController = [[XHYSettingViewController alloc] init];
        UINavigationController *navi_set = [[UINavigationController alloc] initWithRootViewController:setViewController];
        navi_set.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"tabbar_set_normal"] selectedImage:[UIImage imageNamed:@"tabbar_set_select"]];
        
        self.viewControllers = @[navi_device,navi_msg,navi_mode,navi_set];
        
        UIView *colorView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
        colorView.backgroundColor = [UIColor blackColor];
        [self.tabBar insertSubview:colorView atIndex:0];
        self.tabBar.tintColor = MainColor;
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kRealReachabilityChangedNotification
                                               object:nil];
    */
    @JZWeakObj(self);
//    [self xw_addNotificationForName:kRealReachabilityChangedNotification block:^(NSNotification * _Nonnull notification){
//        [selfWeak networkChanged:notification];
//    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----
/*
- (void)networkChanged:(NSNotification *)notification{
    
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    NSLog(@"当前网络状态%ld",(long)status);
    switch (status){
        case RealStatusUnknown:
        case RealStatusNotReachable:{
            
            [JDStatusBarNotification setDefaultStyle:^JDStatusBarStyle *(JDStatusBarStyle *style){
                
                style.barColor = [UIColor redColor];
                style.textColor = [UIColor whiteColor];
                return style;
            }];
            [JDStatusBarNotification showWithStatus:@"网络不可用" dismissAfter:CGFLOAT_MAX];
        }
            break;
            
        case RealStatusViaWiFi:
        case RealStatusViaWWAN:{
            
            [JDStatusBarNotification setDefaultStyle:^JDStatusBarStyle *(JDStatusBarStyle *style){
                style.barColor = MainColor;
                style.textColor = [UIColor whiteColor];
                return style;
            }];
            [JDStatusBarNotification showWithStatus:@"网络恢复可用" dismissAfter:1.0f];
        }
            break;
            
        default:
            break;
    }
}
 */
@end

//
//  AppDelegate.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/6/28.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "AppDelegate.h"
#import "XHYLoginViewController.h"
#import <Bugtags/Bugtags.h>
#import "XHYDBManager.h"
#import "XHYLoginManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark ----- Application Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    //启用闪退收集系统
    [Bugtags startWithAppKey:bugTagsAppKey invocationEvent:BTGInvocationEventShake];
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UINavigationBar appearance] setBarTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    //启用网络监测
//    GLobalRealReachability.hostForPing = @"www.baidu.com";
//    [GLobalRealReachability startNotifier];
    //创建数据库
    [XHYDBManager createDataBase];
    [XHYDBManager addField:@"msgUUID" inTable:@"XHYMsg"];
    
    XHYLoginViewController *loginViewController = [[XHYLoginViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    startReconnect();
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{

    return YES;
}

@end

//
//  XHYSmartConst.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/24.
//  Copyright © 2016年  XHY. All rights reserved.
//

#ifndef XHYSmartConst_h
#define XHYSmartConst_h

#define MainDataBasePath [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"DataBase.db"]

static NSString * const bugTagsAppKey = @"5a2efc930969b7f28d21de271f06d5f6";

static NSString * const mainIP = @"112.74.77.78";

static NSString * const keychainService = @"com.xinghuoyuan.justin";

// 所有一级图标的大小 如设备列表、设备管理列表、模式列表、设置、配合项列表（门锁设置，添加红外转发等）
static const CGFloat primaryIconSize = 48.0f; //一级图标大小
// 左右边缘间隙大小
static const CGFloat marginSpaceSize = 8.0f;
// 选择
static const CGFloat selectImageSize = 20.0f;

#define currentAccount [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENTACCOUNT"]

#define XHYFORBIDMSG     [[NSUserDefaults standardUserDefaults] objectForKey:@"XHYFORBIDMSG"]
#define XHYFORBIDSHAKE    [[NSUserDefaults standardUserDefaults] objectForKey:@"XHYFORBIDSHAKE"]
#define XHYFORBIDVOICE    [[NSUserDefaults standardUserDefaults] objectForKey:@"XHYFORBIDVOICE"]
//禁止顶部状态栏通知
#define XHYForbidStatusBarNotification [[NSUserDefaults standardUserDefaults] objectForKey:@"XHYFORBIDSTATUSBARNOTIFICATION"]
//禁止置顶设备
#define XHYForbidStickDevice [[NSUserDefaults standardUserDefaults] objectForKey:@"XHYFORBIDSTICKDEVICE"]

#define XHYPasswordVisible [[NSUserDefaults standardUserDefaults] objectForKey:@"XHYPASSWORDVISIBLE"]

#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

#define ScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

#define MainColor [UIColor jk_colorWithHexString:@"#00a84d"]
#define BackgroudColor [UIColor jk_colorWithHexString:@"#292F3D"]

#define NavigationBarBackgroudColor [UIColor colorWithRed:96.0/255.0 green:249.0/255.0 blue:221.0/255.0 alpha:1.0F]

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define AppDelegateInstance [[UIApplication sharedApplication] delegate]

#define JZWeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

#endif /* XHYSmartConst_h */

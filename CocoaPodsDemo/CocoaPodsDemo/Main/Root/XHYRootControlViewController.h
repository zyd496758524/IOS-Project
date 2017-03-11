//
//  XHYRootControlViewController.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHYBaseViewController.h"
#import "XHYSmartDevice.h"
#import "XHYMsgSendTool.h"
//控制界面的根界面
@interface XHYRootControlViewController : XHYBaseViewController

@property(nonatomic,strong) XHYSmartDevice *controlSmartDevice;

- (void)enterDeviceEditController:(id)sender;

@end

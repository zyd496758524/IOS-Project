//
//  XHYAYCameraPlayViewController.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHYBaseViewController.h"
#import <UAnYan/UAnYan.h>

@interface XHYAYCameraPlayViewController : XHYBaseViewController
{
    AYClient_Device_Baseinfo *_playCamera;
    BOOL isPlaying;
}

- (instancetype)initWithCameraInfo:(AYClient_Device_Baseinfo *)playCamera;

@end

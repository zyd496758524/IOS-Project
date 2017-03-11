//
//  XHYCameraLiveView.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/21.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHYSmartDevice.h"

typedef NS_ENUM(NSUInteger, XHYCameraLiveStatus) {
    
    XHYCameraLivePrepare,
    XHYCameraLiveBuffer,
    XHYCameraliveLiveing,
};

@interface XHYCameraLiveView : UIView

@property(nonatomic,assign,readonly) XHYCameraLiveStatus currentLiveStatus;
@property(nonatomic,copy,readonly) NSString *currentLiveingDevId;

+ (instancetype)defaultCameraLiveView;

- (void)startCameraLive:(XHYSmartDevice *)liveCamera;

@end

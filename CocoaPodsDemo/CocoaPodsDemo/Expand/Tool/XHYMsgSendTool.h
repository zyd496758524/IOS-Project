//
//  XHYMsgSendTool.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/14.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHYMsgSendTool : NSObject

+ (void)sendDeviceControlMsg:(NSString *)msg;

+ (void)sendIQData:(NSString *)domin msgContent:(NSString *)msg;

@end

//
//  XHYMsgHandler.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/28.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "zigbee.h"

@interface XHYMsgHandler : NSObject

+ (instancetype)defaultMsgHandler;

- (void)startHandleMsg:(struct MsgInfo_S) msginfo;

@end

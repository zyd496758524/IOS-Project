//
//  XHYSmartLinkage.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/14.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XHYSmartDevice.h"

//联动数据 和 中控开关数据

@interface XHYSmartLinkage : NSObject

@property(nonatomic,copy) NSString *linkageName;

//触发设备以及触发值 附加值
@property(nonatomic,strong) XHYSmartDevice *triggerDevice;
@property(nonatomic,copy) NSString *triggerValue;
@property(nonatomic,copy) NSString *additionalValue;

//响应设备以及响应值
@property(nonatomic,strong) NSMutableArray *responseDeviceArray;

- (NSMutableDictionary *)formatterSendLinkage;
- (BOOL)isEqual:(XHYSmartLinkage *)object;
@end

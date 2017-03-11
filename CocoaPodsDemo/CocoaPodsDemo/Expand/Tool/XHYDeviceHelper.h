//
//  XHYDeviceHelper.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/16.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XHYSmartDevice.h"

@interface XHYDeviceHelper : NSObject

// 通过IEEEAddr + endPoint来确定设备唯一性 常用于 在联动，模式数据解析时找到对应的触发设备和响应设备
+ (XHYSmartDevice *)findSmartDeviceIEEEAddr:(NSString *)IEEEAddr andEndPoint:(NSString *)endPoint;

// 通过nwkAddr + endPoint来确定设备唯一性 常用于 在接收消息时通过消息中的nwkAddr和endPoint找到对应的设备
+ (XHYSmartDevice *)querySmartDeviceNwkAddr:(NSString *)nwkAddr andEndPoint:(NSString *)endPoint;

@end

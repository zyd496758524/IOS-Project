//
//  XHYCameraConfigureTool.h
//  XHYSparxSmart
//
//  Created by  XHY on 16/7/13.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHYCameraConfigureTool : NSObject

//检查ssid
+ (BOOL)checkSSID:(NSString*)tempSsid;
+ (NSString *)currentWifiSSID;
+ (NSString*)getCurrent_IP_Address;
+ (NSString*)getCurrent_Mac;

@end

//
//  XHYSmartLinkage.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/14.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYSmartLinkage.h"

@implementation XHYSmartLinkage

/*
 
 device =             {
 deviceSerialNumber = 770;
 endPoint = 48;
 extraValue = 0;
 iEEEAddr = 5149013082959454;
 linkName = "";
 linkedState = 4;
 name = "\U7ea2\U5916\U63a2\U6d4b1";
 nwkAddr = 0;
 };
 mdevices =             (
 {
 deviceSerialNumber = 256;
 endPoint = 17;
 iEEEAddr = 5149013038034335;
 isOnline = 0;
 ischeck = 0;
 linkedState = 0;
 name = "\U706f9";
 nwkAddr = 0;
 state = 0;
 },
 {
 deviceSerialNumber = 0;
 endPoint = 32;
 iEEEAddr = 5149013082957235;
 isOnline = 0;
 ischeck = 0;
 linkedState = 0;
 name = "\U5f00\U5173";
 nwkAddr = 0;
 state = 0;
 }
 );
 */

- (NSMutableDictionary *)formatterSendLinkage{

    NSMutableDictionary *sendLinkageDic = [NSMutableDictionary dictionary];
    
    //触发设备信息（字典）
    NSMutableDictionary *triggerDict = [NSMutableDictionary dictionary];
    [triggerDict setObject:[NSString stringWithFormat:@"%@",self.triggerDevice.IEEEAddr] forKey:@"iEEEAddr"];
    [triggerDict setObject:[NSNumber numberWithChar:self.triggerDevice.endPoint] forKey:@"endPoint"];
    [triggerDict setObject:[NSNumber numberWithInt: self.triggerDevice.deviceID] forKey:@"deviceSerialNumber"];
    [triggerDict setObject:[self.triggerDevice.customDeviceName length]?self.triggerDevice.customDeviceName:self.triggerDevice.deviceName forKey:@"name"];
    [triggerDict setObject:self.triggerValue forKey:@"linkedState"];
    [triggerDict setObject:[self.linkageName length]?self.linkageName:@"" forKey:@"linkName"];
    [triggerDict setObject:[NSNumber numberWithUnsignedShort:self.triggerDevice.nwkAddr] forKey:@"nwkAddr"];
    
    @try {
        
        if ([self.additionalValue length]){
            
            [triggerDict setObject:[NSNumber numberWithInt:[self.additionalValue intValue]] forKey:@"extraValue"];
        }

    } @catch (NSException *exception) {
        
        NSLog(@"exception --->%@",exception.reason);
        
    } @finally {
        
    }

    //响应设备信息（字典数组）
    NSMutableArray *responDeviceArray = [NSMutableArray array];
    
    if ([self.responseDeviceArray count]){
        
        [self.responseDeviceArray enumerateObjectsUsingBlock:^(NSDictionary *responDict, NSUInteger idx, BOOL * _Nonnull stop) {
            
            XHYSmartDevice *responDevice = responDict[@"device"];
            NSString *responValue = responDict[@"linkedState"];
            
            NSMutableDictionary *repsonDeviceDict = [NSMutableDictionary dictionary];
            
            [repsonDeviceDict setObject: [NSString stringWithFormat:@"%@",responDevice.IEEEAddr] forKey:@"iEEEAddr"];
            [repsonDeviceDict setObject:[NSNumber numberWithChar:responDevice.endPoint] forKey:@"endPoint"];
            [repsonDeviceDict setObject:responValue forKey:@"linkedState"];
            [repsonDeviceDict setObject:[responDevice.customDeviceName length]?responDevice.customDeviceName:responDevice.deviceName forKey:@"name"];
            [repsonDeviceDict setObject:[NSNumber numberWithInt: responDevice.deviceID] forKey:@"deviceSerialNumber"];
            
            [repsonDeviceDict setObject:@"0" forKey:@"isOnline"];
            [repsonDeviceDict setObject:@"0" forKey:@"ischeck"];
            [repsonDeviceDict setObject:[NSNumber numberWithUnsignedShort:self.triggerDevice.nwkAddr] forKey:@"nwkAddr"];
            [repsonDeviceDict setObject:@"0" forKey:@"state"];
            
            [responDeviceArray addObject:repsonDeviceDict];
        }];
    }
    
    //发送所需的联动数据（字典）
    [sendLinkageDic setObject:triggerDict forKey:@"device"];
    [sendLinkageDic setObject:responDeviceArray forKey:@"mdevices"];
    NSLog(@"%@",[sendLinkageDic description]);
    return sendLinkageDic;
}

- (BOOL)isEqual:(XHYSmartLinkage *)object{

    return [object.triggerDevice isEqual:self.triggerDevice]&&[object.triggerValue isEqualToString:self.triggerValue];
}

@end

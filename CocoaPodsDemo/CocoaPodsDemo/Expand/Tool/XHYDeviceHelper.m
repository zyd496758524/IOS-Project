//
//  XHYDeviceHelper.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/16.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYDeviceHelper.h"


@implementation XHYDeviceHelper

+ (XHYSmartDevice *)findSmartDeviceIEEEAddr:(NSString *)IEEEAddr andEndPoint:(NSString *)endPoint{

    __block XHYSmartDevice *tempSmartDevice = nil;
    
    NSString *tempIdentifiler = [NSString stringWithFormat:@"%@#%@",IEEEAddr,endPoint];
    
    [[XHYDataContainer defaultDataContainer].allSmartDeviceArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XHYSmartDevice *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([tempIdentifiler isEqualToString:obj.deviceIEEEAddrIdentifier]){
            
            tempSmartDevice = obj;
            *stop = YES;
        }
    }];
    
    return tempSmartDevice;
}

+ (XHYSmartDevice *)querySmartDeviceNwkAddr:(NSString *)nwkAddr andEndPoint:(NSString *)endPoint{

    __block XHYSmartDevice *tempSmartDevice = nil;
    
    NSString *tempIdentifiler = [NSString stringWithFormat:@"%@#%@",nwkAddr,endPoint];
    
    if ([nwkAddr length] && [endPoint length]){
        
        [[XHYDataContainer defaultDataContainer].allSmartDeviceArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XHYSmartDevice *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([tempIdentifiler isEqualToString:obj.deviceNwkAddrIdentifier]){
                
                tempSmartDevice = obj;
                *stop = YES;
            }
        }];
    }
    return tempSmartDevice;
}

@end

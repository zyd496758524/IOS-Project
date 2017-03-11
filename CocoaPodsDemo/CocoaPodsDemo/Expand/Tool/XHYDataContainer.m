//
//  XHYDataContainer.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/14.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYDataContainer.h"
#import "XHYSmartDevice.h"
#import "XMPP.h"
#import "XHYLoginManager.h"
#import "XHYMsgSendTool.h"

static XHYDataContainer *dataContainer = nil;

@implementation XHYDataContainer

+ (instancetype)defaultDataContainer{

    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        if (!dataContainer) {
            
            dataContainer = [[self alloc] init];
        }
    });
    
    return dataContainer;
}

- (NSMutableArray *)allSmartDeviceArray{

    if (!_allSmartDeviceArray) {
     
        _allSmartDeviceArray = [NSMutableArray array];
    }
    
    return _allSmartDeviceArray;
}

- (NSMutableArray *)allLinkageDataArray{

    if (!_allLinkageDataArray) {
        
        _allLinkageDataArray = [NSMutableArray array];
    }
    
    return _allLinkageDataArray;
}

- (NSMutableArray *)allModeDataArray{

    if (!_allModeDataArray) {
        
        _allModeDataArray = [NSMutableArray array];
    }
    
    return _allModeDataArray;
}

- (NSMutableArray *)allFloorDataArray{

    if (!_allFloorDataArray) {
     
        _allFloorDataArray = [NSMutableArray array];
    }
    
    return _allFloorDataArray;
}

- (NSDictionary *)deviceNameDict{

    if (!_deviceNameDict) {
    
        _deviceNameDict = [NSDictionary dictionary];
    }
    
    return _deviceNameDict;
}

- (void)clearAllData{

    [self.allSmartDeviceArray removeAllObjects];
    [self.allLinkageDataArray removeAllObjects];
    [self.allModeDataArray removeAllObjects];
    [self.allFloorDataArray removeAllObjects];
}

- (BOOL)smartDeviceExist:(XHYSmartDevice *)smartDevice{

    __block BOOL isExist = NO;
    
    [self.allSmartDeviceArray enumerateObjectsUsingBlock:^(XHYSmartDevice *device, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([device isEqual:smartDevice]){
            
            isExist = YES;
        }
    }];
    
    return isExist;
}

- (BOOL)startConfigureDeviceName{

    __block BOOL isNeedRefresh = NO;
    
    if ([self.allSmartDeviceArray count] && [self.deviceNameDict allKeys].count){
        
        @synchronized (self.allSmartDeviceArray){
            
            [self.deviceNameDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *name, BOOL * _Nonnull stop){
                
                NSArray *keyArray = [key componentsSeparatedByString:@"#"];
                if ([keyArray count]) {
                    
                    NSString *IEEEAddr = [keyArray objectAtIndex:1];
                    NSString *endPoint = [keyArray lastObject];
                    
                    XHYSmartDevice *tempSmart = [[XHYSmartDevice alloc] initWithZigBeeIEEEAddr:IEEEAddr andEndPoint:endPoint];
                    [self.allSmartDeviceArray enumerateObjectsUsingBlock:^(XHYSmartDevice *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if ([tempSmart isEqual:obj]){
                            
                            obj.customDeviceName = [name stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                            isNeedRefresh = YES;
                            *stop = YES;
                        }
                    }];
                }
            }];
        }
    }
    
    return isNeedRefresh;
}

- (BOOL)startCongigureDeviceFloor{
    
    __block BOOL isNeedRefresh = NO;

    if ([self.allFloorDataArray count] && [self.allSmartDeviceArray count]){
        
        @synchronized (self.allSmartDeviceArray){
            
            [self.allFloorDataArray enumerateObjectsUsingBlock:^(NSDictionary *floorDict, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *floorName = floorDict[@"name"];
                NSArray *roomeArray = floorDict[@"scences"];
                
                [roomeArray enumerateObjectsUsingBlock:^(NSDictionary *roomDict, NSUInteger idx, BOOL * _Nonnull stop){
                    
                    NSString *roomName = roomDict[@"scenceName"];
                    NSArray *deviceArray = roomDict[@"mDevcieData"];
                    
                    [deviceArray enumerateObjectsUsingBlock:^(NSDictionary *deviceDict, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        NSString *IEEEAddr = deviceDict[@"iEEEAddr"];
                        NSString *endPoint = deviceDict[@"endPoint"];
                        
                        [[XHYDataContainer defaultDataContainer].allSmartDeviceArray enumerateObjectsUsingBlock:^(XHYSmartDevice *device, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            XHYSmartDevice *tempDevice = [[XHYSmartDevice alloc] initWithZigBeeIEEEAddr:IEEEAddr andEndPoint:endPoint];
                            
                            if ([tempDevice isEqual:device]){
                                
                                device.floor = floorName;
                                device.room = roomName;
                                isNeedRefresh = YES;
                                *stop = YES;
                            }
                        }];
                    }];
                }];
            }];
        }
    }
    
    return isNeedRefresh;
}

#pragma mark ----- 同步数据到云服务器

//同步联动数据

- (void)startSyncLinkageData{
    
    NSMutableDictionary *mlink = [NSMutableDictionary dictionary];
    
    [mlink setObject:self.allLinkageDataArray forKey:@"mLinkedData"];
    
    NSData *datac = [NSJSONSerialization dataWithJSONObject:mlink options:0 error:nil];
    
    NSString *result = [[NSString alloc] initWithData:datac encoding:NSUTF8StringEncoding];
    
    const char *color_char = [result cStringUsingEncoding:NSUTF8StringEncoding];
    
    char buffer[100*1024] = {0};
    
    int setResult = setLinkData((char*)color_char, (int)strlen(color_char), buffer);
    
    if (setResult == -1){
        NSLog(@"联动个数超过上限");
        return;
    }
    
    NSString *msgContent = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendDeviceControlMsg:msgContent];
}

//同步模式数据

- (void)startSyncModeData{

    NSMutableDictionary *mlink = [NSMutableDictionary dictionary];
    
    [mlink setObject:self.allModeDataArray forKey:@"modeBeans"];
    
    NSData *datac = [NSJSONSerialization dataWithJSONObject:mlink options:0 error:nil];
    
    NSString *result = [[NSString alloc]initWithData:datac encoding:NSUTF8StringEncoding];
    
    const char *color_char = [result cStringUsingEncoding:NSUTF8StringEncoding];
    
    char buffer[100*1024] = {0};
    
    setModeData((char*)color_char, (int)strlen(color_char), buffer);
    
    NSString *msgContent = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    
    [XHYMsgSendTool sendDeviceControlMsg:msgContent];
}

//同步楼层数据

- (void)startSyncFloorData{
    
    NSMutableDictionary *mlink = [NSMutableDictionary dictionary];
    [mlink setObject:self.allFloorDataArray forKey:@"mfloorbeans"];
    
    NSData *datac = [NSJSONSerialization dataWithJSONObject:mlink options:0 error:nil];
    NSString *result = [[NSString alloc]initWithData:datac encoding:NSUTF8StringEncoding];
    NSString *msgContent = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendIQData:@"ScenceData" msgContent:msgContent];
}

//同步设备名数据

- (void)startSyncDeviceNameData{
    
    /*
    NSMutableDictionary *mlink = [NSMutableDictionary dictionary];
    
    [mlink setObject:self.allLinkageDataArray forKey:@"mLinkedData"];
    
    NSData *datac = [NSJSONSerialization dataWithJSONObject:mlink options:0 error:nil];
    
    NSString *result = [[NSString alloc] initWithData:datac encoding:NSUTF8StringEncoding];
    
    const char *color_char = [result cStringUsingEncoding:NSUTF8StringEncoding];
    
    char buffer[100*1024] = {0};
    
    setLinkData((char*)color_char, (int)strlen(color_char), buffer);
    
    NSString *msgContent = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    
    [self sendXMPPMsg:msgContent];
    */
}

- (void)startSyncIQData:(NSString *)dataContent domin:(NSString *)domin{

    
}

@end

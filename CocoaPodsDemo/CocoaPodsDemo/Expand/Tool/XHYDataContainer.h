//
//  XHYDataContainer.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/14.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XHYSmartDevice;

@interface XHYDataContainer : NSObject

@property(nonatomic,strong) NSMutableArray *allSmartDeviceArray;
@property(nonatomic,strong) NSMutableArray *allLinkageDataArray;
@property(nonatomic,strong) NSMutableArray *allModeDataArray;
@property(nonatomic,strong) NSMutableArray *allFloorDataArray;
@property(nonatomic,strong) NSDictionary *deviceNameDict;

//单例模式 只有一个数据容器
+ (instancetype)defaultDataContainer;

//清空所有数据
- (void)clearAllData;

//判断设备是否已存在
- (BOOL)smartDeviceExist:(XHYSmartDevice *)smartDevice;

//开始配置设备的名字信息
- (BOOL)startConfigureDeviceName;

//开始配置设备的楼层信息
- (BOOL)startCongigureDeviceFloor;

#pragma mark ----- 同步数据到云服务器

//同步联动数据
- (void)startSyncLinkageData;

//同步模式数据
- (void)startSyncModeData;

//同步区域数据
- (void)startSyncFloorData;

//同步设备名称数据
- (void)startSyncDeviceNameData;

@end

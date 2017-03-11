//
//  XHYSmartDevice.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/2.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "zigbee.h"

@interface XHYSmartDevice : NSObject{

    struct DeviceInfo_S zigBeeInfo;
}

@property(nonatomic,readonly,copy) NSString *deviceName;           //设备默认名称
@property(nonatomic,readonly,copy) NSString *deviceIEEEAddrIdentifier;     //唯一识别号 IEEEAddr + endPoint
@property(nonatomic,readonly,copy) NSString *deviceNwkAddrIdentifier;      //唯一识别号 nwkAddr + endPoint
@property(nonatomic,readonly,copy) NSString *IEEEAddr;
@property(nonatomic,readonly,assign) unsigned char endPoint;
@property(nonatomic,readonly,assign) short int deviceID;
@property(nonatomic,readonly,assign) unsigned short int nwkAddr;
@property(nonatomic,readonly,assign) NSInteger powerStatus;        //电量状态【弱电设备有亏电状态，需提醒】
@property(nonatomic,readonly,assign) NSInteger deviceOnlineStatus; //在线状态
@property(nonatomic,readonly,assign) NSInteger deviceWorkStatus;   //工作状态

@property(nonatomic,copy) NSString *customDeviceName;     //自定义名称
@property(nonatomic,copy) NSString *room;                 //房间
@property(nonatomic,copy) NSString *floor;                //楼层

//电视 空调等红外转发设备专属属性
@property(nonatomic,copy) NSString *belongTo;             // 电视，空调等所从属的红外转发器的设备信息
@property(nonatomic,assign) NSInteger addType;            //添加方式 1：手动复制添加  0：品牌搜索添加
@property(nonatomic,copy) NSString *groupID;              //红外码库序号(品牌添加特有，手动复制为空)

//摄像头专属属性
@property(nonatomic,strong) NSDictionary *cameraInfo;     //摄像头基本信息

- (instancetype)initWithZigBeeData:(struct DeviceInfo_S)deviceInfo;

- (instancetype)initWithZigBeeIEEEAddr:(NSString *)IEEEAddr andEndPoint:(NSString *)endPoint;

- (BOOL)isEqual:(XHYSmartDevice *)smartDevice;

//默认排序值
- (int)getDefaultSortNum;

//获取设备全部的动作值（主动设备的触发值 或者 被动设备的响应值）[用于联动数据中，包括中控开关]
- (NSArray *)getAllActionValueForCenterControl:(BOOL)forCenter;

#pragma mark ----- 设备类型判断
/*
 *
 *
 用于联动数据[包括中控开关数据]编辑时判断
 *
 *
 */

//是否为触发设备
- (BOOL)isTriggerDevice;

//是否为响应设备
- (BOOL)isResponseDevice;

/*
 *
 *
 用于设备展示判断
 *
 *
 */

//是否为控制设备
- (BOOL)isControlDevice;

//是否为传感设备
- (BOOL)isSensorDevice;

/*
 *
 *
 判断强电弱电设备
 *
 *
 */

//是否为强电设备
- (BOOL)isStrongPowerDevice;
//是否为弱电设备
- (BOOL)isWeakPowerDevice;

#pragma mark ----- 用于判断设备是否需要显示工作状态
//类似灯、开关有工作状态 则需显示
- (BOOL)isNeedDisplayWorkStatus;

//获取设备对应icon图标名称
- (NSString *)getDeviceIconName;

#pragma mark ---- 获取位置信息的完整描述
// 格式为:楼层/房间
- (NSString *)getFloorRoomDescription;

#pragma mark ----- 刷新设备状态信息

- (void)changeDeviceWorkStatus:(NSInteger)workStatus;

- (void)changeDeviceOnlineStatus:(NSInteger)onlineStatus;

@end

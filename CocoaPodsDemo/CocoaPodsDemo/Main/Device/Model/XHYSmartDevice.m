//
//  XHYSmartDevice.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/2.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYSmartDevice.h"
#import "XHYDeviceHelper.h"

@interface XHYSmartDevice(){

    NSString *_deviceIEEEAddrIdentifier;
    NSString *_deviceNwkAddrIdentifier;
}

@end

@implementation XHYSmartDevice

- (instancetype)initWithZigBeeData:(struct DeviceInfo_S)deviceInfo{

    if (self = [super init]){
        
        zigBeeInfo = deviceInfo;
    }
    
    return self;
}

- (instancetype)initWithZigBeeIEEEAddr:(NSString *)IEEEAddr andEndPoint:(NSString *)endPoint{

    if (self = [super init]) {
        
        struct DeviceInfo_S deviceInfo;
        deviceInfo.IEEEAddr = [IEEEAddr longLongValue];
        deviceInfo.endPoint = [[NSNumber numberWithInteger:[endPoint integerValue]] unsignedCharValue];
        zigBeeInfo = deviceInfo;
    }
    
    return self;
}

- (NSString *)IEEEAddr{

    return [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:zigBeeInfo.IEEEAddr]];
}

#pragma mark ----- 获取设备ZigBee属性

- (unsigned char)endPoint{

    return zigBeeInfo.endPoint;
}

- (short int)deviceID{

    return zigBeeInfo.deviceId;
}

- (unsigned short)nwkAddr{

    return zigBeeInfo.nwkAddr;
}

- (NSInteger)powerStatus{

    NSNumber *powerValue = [NSNumber numberWithUnsignedChar:zigBeeInfo.powerStatus];
    
    return [powerValue integerValue];
}

- (NSInteger)deviceOnlineStatus{
    
    if (self.deviceID == XHY_DEVICE_TV||self.deviceID == XHY_DEVICE_AirConditioner){
        
        if ([self.belongTo length]){
            
            NSArray *tempArray = [self.belongTo componentsSeparatedByString:@"#"];
            
            if ([tempArray count]){
                
                NSString *IEEEAddr = tempArray[1];
                NSString *endPoint = [tempArray lastObject];
                XHYSmartDevice *belongDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:IEEEAddr andEndPoint:endPoint];
                if (belongDevice) {
                    
                    return belongDevice.deviceOnlineStatus;
                }
            }
        }
    }
    
    NSNumber *onlineNumber = [NSNumber numberWithUnsignedChar:zigBeeInfo.status];
    
    return [onlineNumber integerValue];
}

- (NSInteger)deviceWorkStatus{
    
    NSNumber *workNumber = [NSNumber numberWithUnsignedChar:zigBeeInfo.dev_status];
    
    return [workNumber integerValue];
}

- (NSString *)deviceName{
    
    /*
     #define ZCL_HA_DEVICEID_CURTAIN_CONTROL          0x0501         //窗帘
     #define ZCL_HA_DEVICEID_DOOR                     0x0503         //门磁
     #define ZCL_HA_DEVICEID_TEMPERATURE_SENSOR       0x0302         //红外探测&&温湿度
     #define ZCL_HA_DEVICEID_IAS_ZONE                 0x0402         //烟雾探测
     #define ZCL_HA_DEVICEID_INFRA_FORWARD            0x0500         //红外转发
     #define ZCL_HA_DEVICEID_LOCK                     0x0502         //锁
     #define ZCL_HA_DEVICEID_ON_OFF_LIGHT             0x0100         //灯
     #define ZCL_HA_DEVICEID_ON_OFF_SWITCH            0x0000         //开关
     #define ZCL_HA_DEVICEID_REMOTE_CONTROL           0x0600         //智能遥控器
     #define ZCL_HA_DEVICEID_GAS_CONTROL              0x0011         //燃气传感感
     #define ZCL_HA_DEVICEID_WATER_CONTROL            0x0504         //雨水传感器
     #define ZCL_HA_DEVICEID_SOS_CONTROL              0x0010         //sos按键
     #define ZCL_HA_DEVICEID_MODECHANGE_CONTROL       0x000A         //情景面板
     #define ZCL_HA_DEVICEID_AUTOPUSHWINDOW           0x0505         //电动推窗器
     #define ZCL_HA_DEVICEID_CENTRALCONTROLONE        0x0506         //中控开关1位
     #define ZCL_HA_DEVICEID_CENTRALCONTROLTWO        0x0507         //中控开关2位
     #define ZCL_HA_DEVICEID_CENTRALCONTROLTHREE      0x0508         //中控开关3位
     #define ZCL_HA_DEVICEID_COLORMODULE              0x0102         //调光开关
     #define ZCL_HA_DEVICEID_MUSIC                    0x4001         //背景音乐
     
     #define ZCL_HA_DEVICEID_CAMERA                   0x1111         //摄像头
     #define ZCL_HA_DEVICEID_TV                       0x2222         //电视
     #define ZCL_HA_DEVICEID_CONDITIONER              0x3333         //空调

     */
    
    NSString *deviceName = @"未知设备";
    
    switch (self.deviceID) {
            
        case XHY_DEVICE_Curtain:
            deviceName = @"窗帘";
            break;
            
        case XHY_DEVICE_DoorContact:
            deviceName = @"门磁";
            break;
            
        case XHY_DEVICE_InfraredDetection:
            deviceName = @"多功能红外侦测";
            break;
            
        case XHY_DEVICE_SmokeDetection:
            deviceName = @"烟雾探测器";
            break;
            
        case XHY_DEVICE_InfraredRepeater:
            deviceName = @"红外转发器";
            break;
            
        case XHY_DEVICE_Lock:
            deviceName = @"门锁";
            break;
            
        case XHY_DEVICE_Light:
            deviceName = @"灯";
            break;
            
        case XHY_DEVICE_Switch:
            deviceName = @"开关";
            break;
            
        case XHY_DEVICE_SmartController:
            deviceName = @"智能遥控器";
            break;
            
        case XHY_DEVICE_GasDetection:
            deviceName = @"燃气探测器";
            break;
            
        case XHY_DEVICE_WaterDetection:
            deviceName = @"溢水探测器";
            break;
            
        case XHY_DEVICE_SOSAlarm:
            deviceName = @"SOS按钮";
            break;
            
        case XHY_DEVICE_SceneControlPanel:
            deviceName = @"双路场景";
            break;
            
        case XHY_DEVICE_AutoWindowPusher:
            deviceName = @"推窗器";
            break;
            
        case XHY_DEVICE_CenterControlOne:
        case XHY_DEVICE_CenterControlTwo:
        case XHY_DEVICE_CenterControlThree:
            deviceName = @"中控开关";
            break;
        
        case XHY_DEVICE_ColorModule:
            deviceName = @"调光开关";
            break;
            
        case XHY_DEVICE_MusicPlayer:
            deviceName = @"背景音乐";
            break;
            
        case XHY_DEVICE_Camera:
            deviceName = @"网络摄像头";
            break;
            
        case XHY_DEVICE_TV:
            deviceName = @"电视";
            break;
            
        case XHY_DEVICE_AirConditioner:
            deviceName = @"空调";
            break;
        case XHY_DEVICE_PM25:
            deviceName = @"PM2.5探测器";
            break;
            
        default:
            break;
    }
    
    return deviceName;
}

#pragma mark ----- 唯一识别号

- (NSString *)deviceIEEEAddrIdentifier{

    if (!_deviceIEEEAddrIdentifier) {
        
        NSString *IEEEAddr = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:zigBeeInfo.IEEEAddr]];
        NSString *endPoint = [NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedChar:zigBeeInfo.endPoint]];
        _deviceIEEEAddrIdentifier = [NSString stringWithFormat:@"%@#%@",IEEEAddr,endPoint];
    }
    
    return _deviceIEEEAddrIdentifier;
}

- (NSString *)deviceNwkAddrIdentifier{

    if (!_deviceNwkAddrIdentifier) {
        
        NSString *nwkAddr = [NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedShort:zigBeeInfo.nwkAddr]];
        NSString *endPoint = [NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedChar:zigBeeInfo.endPoint]];
        _deviceNwkAddrIdentifier = [NSString stringWithFormat:@"%@#%@",nwkAddr,endPoint];
    }
    
    return _deviceNwkAddrIdentifier;
}

- (BOOL)isEqual:(XHYSmartDevice *)smartDevice{

    return [self.deviceIEEEAddrIdentifier isEqualToString:smartDevice.deviceIEEEAddrIdentifier];
}

- (int)getDefaultSortNum{
    
    int defaultSort = 0;
    
    switch (self.deviceID){
            
        case XHY_DEVICE_Light:
            defaultSort = 1;
            break;
            
        case XHY_DEVICE_Switch:
            defaultSort = 2;
            break;
            
        case XHY_DEVICE_Lock:
            defaultSort = 3;
            break;
            
        case XHY_DEVICE_TV:
            defaultSort = 4;
            break;
            
        case XHY_DEVICE_AirConditioner:
            defaultSort = 5;
            break;
            
        case XHY_DEVICE_Curtain:
            defaultSort = 6;
            break;
            
        case XHY_DEVICE_AutoWindowPusher:
            defaultSort = 7;
            break;
            
        case XHY_DEVICE_CenterControlOne:
        case XHY_DEVICE_CenterControlTwo:
        case XHY_DEVICE_CenterControlThree:
            defaultSort = 8;
            break;
            
        case XHY_DEVICE_ColorModule:
            defaultSort = 9;
            break;
            
        case XHY_DEVICE_MusicPlayer:
            defaultSort = 10;
            break;
            
        case XHY_DEVICE_DoorContact:
            defaultSort = 11;
            break;
            
        case XHY_DEVICE_InfraredDetection:
            defaultSort = 12;
            break;
            
        case XHY_DEVICE_GasDetection:
            defaultSort = 13;
            break;
            
        case XHY_DEVICE_SmokeDetection:
            defaultSort = 14;
            break;
            
        case XHY_DEVICE_WaterDetection:
            defaultSort = 15;
            break;
            
        case XHY_DEVICE_SOSAlarm:
            defaultSort = 16;
            break;
            
        case XHY_DEVICE_InfraredRepeater:
            defaultSort = 17;
            break;
    
        case XHY_DEVICE_SmartController:
            defaultSort = 18;
            break;

        case XHY_DEVICE_SceneControlPanel:
            defaultSort = 19;
            break;
            
        case XHY_DEVICE_PM25:
            defaultSort = 20;
            break;
            
        default:
            break;
    }
    
    return defaultSort;
}

- (NSArray *)getAllActionValueForCenterControl:(BOOL)forCenter{

    NSMutableArray *actionValue = [NSMutableArray array];
    
    switch (self.deviceID) {
            
            //窗帘
        case XHY_DEVICE_Curtain:{
            
            [actionValue addObject:@"0"];
            [actionValue addObject:@"1"];
            
            if (forCenter) {
                
                [actionValue addObject:@"29"];
            }
        }
            break;
            
            //门磁
        case XHY_DEVICE_DoorContact:{
            
            [actionValue addObject:@"2"];
            [actionValue addObject:@"3"];
        }
            break;
            
            //红外探测(温、湿、亮度)
        case XHY_DEVICE_InfraredDetection:{
            
            [actionValue addObject:@"4"];
            [actionValue addObject:@"5"];
            [actionValue addObject:@"6"];
            [actionValue addObject:@"7"];
            [actionValue addObject:@"8"];
            [actionValue addObject:@"9"];
            [actionValue addObject:@"10"];
        }
            break;
            
            //烟雾探测
        case XHY_DEVICE_SmokeDetection:{
            
            [actionValue addObject:@"15"];
        }
            break;
            
            //红外转发
        case XHY_DEVICE_InfraredRepeater:{
            
            [actionValue addObject:@"0"];
            [actionValue addObject:@"1"];
        }
            break;
            
            //锁
        case XHY_DEVICE_Lock:{
            
            [actionValue addObject:@"18"];
            [actionValue addObject:@"19"];
        }
            break;
            
            //灯
        case XHY_DEVICE_Light:{
            
            [actionValue addObject:@"0"];
            [actionValue addObject:@"1"];
            
            if (forCenter) {
                
                [actionValue addObject:@"29"];
            }
        }
            break;
            
            //开关
        case XHY_DEVICE_Switch:{
            
            [actionValue addObject:@"0"];
            [actionValue addObject:@"1"];
            
            if (forCenter) {
                
                [actionValue addObject:@"29"];
            }
        }
            break;
            
            //智能遥控器
        case XHY_DEVICE_SmartController:{
            
        }
            break;
            
            //燃气传感感
        case XHY_DEVICE_GasDetection:{
            
            [actionValue addObject:@"12"];
            [actionValue addObject:@"13"];
        }
            break;
            
            //雨水传感器
        case XHY_DEVICE_WaterDetection:{
            
            [actionValue addObject:@"11"];
        }
            break;
            
            //sos报警器
        case XHY_DEVICE_SOSAlarm:{
            [actionValue addObject:@"14"];
        }
            break;
            
            //情景面板
        case XHY_DEVICE_SceneControlPanel:{
            
        }
            break;
            
            //电动推窗器
        case XHY_DEVICE_AutoWindowPusher:{
            
            [actionValue addObject:@"0"];
            [actionValue addObject:@"1"];
            
            if (forCenter) {
                
                [actionValue addObject:@"29"];
            }
        }
            break;
            
            //中控开关2、3位
        case XHY_DEVICE_CenterControlOne:
        case XHY_DEVICE_CenterControlTwo:
        case XHY_DEVICE_CenterControlThree:{
            
        }
            break;
            
            //调光开关
        case XHY_DEVICE_ColorModule:{
            
            [actionValue addObject:@"0"];
            [actionValue addObject:@"1"];
        }
            break;
            
            //背景音乐
        case XHY_DEVICE_MusicPlayer:{
            
            [actionValue addObject:@"0"];
            [actionValue addObject:@"1"];
        }
            break;
            
            //摄像头
        case XHY_DEVICE_Camera:{
            
            [actionValue addObject:@"20"];
            [actionValue addObject:@"21"];
            [actionValue addObject:@"22"];
            [actionValue addObject:@"23"];
        }
            break;
            
            //电视
        case XHY_DEVICE_TV:{
            
            [actionValue addObject:@"24"];
            [actionValue addObject:@"25"];
        }
            break;
            
            //空调
        case XHY_DEVICE_AirConditioner:{
            
            [actionValue addObject:@"24"];
            [actionValue addObject:@"25"];
        }
            break;
            
        default:
            break;
    }
    
    return actionValue;
}

#pragma mark ----- 设备类型

- (BOOL)isTriggerDevice{

    BOOL isTrigger = NO;
    
    switch (self.deviceID) {
            
        case XHY_DEVICE_DoorContact:
        case XHY_DEVICE_SOSAlarm:
        case XHY_DEVICE_InfraredDetection:
        case XHY_DEVICE_WaterDetection:
        case XHY_DEVICE_SmokeDetection:
        case XHY_DEVICE_GasDetection:
        case XHY_DEVICE_Lock:
            isTrigger = YES;
            break;
            
        default:
            break;
    }
    
    return isTrigger;
}

- (BOOL)isResponseDevice{

    BOOL isResponse = NO;
    
    switch (self.deviceID) {
            
        case XHY_DEVICE_Light:
        case XHY_DEVICE_Switch:
        case XHY_DEVICE_Curtain:
        case XHY_DEVICE_AutoWindowPusher:
        case XHY_DEVICE_ColorModule:
        case XHY_DEVICE_MusicPlayer:
        case XHY_DEVICE_Camera:
        case XHY_DEVICE_TV:
        case XHY_DEVICE_AirConditioner:
            isResponse = YES;
            break;
            
        default:
            break;
    }
    
    return isResponse;
}

- (BOOL)isControlDevice{

    BOOL isControl = NO;
    
    switch (self.deviceID) {
            
        case XHY_DEVICE_Curtain:
        case XHY_DEVICE_Lock:
        case XHY_DEVICE_Light:
        case XHY_DEVICE_Switch:
        case XHY_DEVICE_AutoWindowPusher:
        case XHY_DEVICE_MusicPlayer:
        case XHY_DEVICE_CenterControlOne:
        case XHY_DEVICE_CenterControlTwo:
        case XHY_DEVICE_CenterControlThree:
        case XHY_DEVICE_ColorModule:
        case XHY_DEVICE_SmartController:
            isControl = YES;
            break;
            
        default:
            break;
    }
    
    return isControl;
}

- (BOOL)isSensorDevice{

    BOOL isSensor = NO;
    
    switch (self.deviceID){
        case XHY_DEVICE_DoorContact:
        case XHY_DEVICE_SOSAlarm:
        case XHY_DEVICE_InfraredDetection:
        case XHY_DEVICE_WaterDetection:
        case XHY_DEVICE_SmokeDetection:
        case XHY_DEVICE_GasDetection:
        case XHY_DEVICE_InfraredRepeater:
        case XHY_DEVICE_SceneControlPanel:
            isSensor = YES;
            break;
            
        default:
            break;
    }
    
    return isSensor;
}

- (BOOL)isNeedDisplayWorkStatus{

    BOOL isNeed = NO;
    
    switch (self.deviceID) {
        case XHY_DEVICE_Lock:
        case XHY_DEVICE_Light:
        case XHY_DEVICE_Switch:
        case XHY_DEVICE_ColorModule:
            isNeed = YES;
            break;
            
        default:
            break;
    }
    
    return isNeed;
}

- (BOOL)isStrongPowerDevice{
    
    BOOL isStrongPower = NO;
    isStrongPower = self.powerStatus == 255;
    return isStrongPower;
}

- (BOOL)isWeakPowerDevice{

    BOOL isWeak = NO;
    
    switch (self.deviceID) {
        case XHY_DEVICE_SOSAlarm:
        case XHY_DEVICE_DoorContact:
        case XHY_DEVICE_Lock:
        case XHY_DEVICE_SmokeDetection:
        case XHY_DEVICE_GasDetection:
        case XHY_DEVICE_InfraredDetection:
            isWeak = YES;
            break;
            
        default:
            break;
    }

    return isWeak;
}

- (NSString *)getDeviceIconName{

    NSMutableString *iconName = [NSMutableString string];
    
    switch (self.deviceID) {
            
        case XHY_DEVICE_Light:
        {
            [iconName appendString:@"device_light_"];
        }
            break;
            
        case XHY_DEVICE_Switch:
        {
            [iconName appendString:@"device_switch_"];
        }
            break;
            
        case XHY_DEVICE_Lock:
        {
            [iconName appendString:@"device_lock_"];
        }
            break;
            
        case XHY_DEVICE_TV:
        {
            [iconName appendString:@"device_tv_"];
        }
            break;
            
        case XHY_DEVICE_AirConditioner:
        {
            [iconName appendString:@"device_airconditioner_"];
        }

            break;
            
        case XHY_DEVICE_Curtain:
        {
            [iconName appendString:@"device_curtain_"];
        }

            break;
            
        case XHY_DEVICE_AutoWindowPusher:
        {
            [iconName appendString:@"device_autopush_"];
        }

            break;
            
        case XHY_DEVICE_CenterControlOne:
        case XHY_DEVICE_CenterControlTwo:
        case XHY_DEVICE_CenterControlThree:
        {
            [iconName appendString:@"device_centercontrol_"];
        }

            break;
            
        case XHY_DEVICE_ColorModule:
        {
            [iconName appendString:@"device_colormodule_"];
        }

            break;
            
        case XHY_DEVICE_MusicPlayer:
        {
            [iconName appendString:@"device_music_"];
        }

            break;
            
        case XHY_DEVICE_DoorContact:
        {
            [iconName appendString:@"sensor_door_"];
        }

            break;
            
        case XHY_DEVICE_InfraredDetection:
        {
            [iconName appendString:@"sensor_infrareddetector_"];
        }

            break;
            
        case XHY_DEVICE_InfraredRepeater:
        {
            [iconName appendString:@"sensor_infraredrepeater_"];
        }
            break;
            
        case XHY_DEVICE_GasDetection:
        {
            [iconName appendString:@"sensor_gasalarm_"];
        }

            break;
            
        case XHY_DEVICE_SmokeDetection:
        {
            [iconName appendString:@"sensor_smokealarm_"];
        }

            break;
            
        case XHY_DEVICE_WaterDetection:
        {
            [iconName appendString:@"sensor_water_"];
        }

            break;
            
        case XHY_DEVICE_SmartController:
        {
            [iconName appendString:@"sensor_remotecontroller_"];
        }

            break;
            
        case XHY_DEVICE_SOSAlarm:
        {
            [iconName appendString:@"sensor_sos_"];
        }

            break;
            
        case XHY_DEVICE_SceneControlPanel:
        {
            [iconName appendString:@"sensor_double_"];
        }
            break;
            
        case XHY_DEVICE_Camera:{
        
            [iconName appendString:@"device_camera_"];
        }
            break;
            
        default:
            break;
    }
    
    if (self.deviceOnlineStatus||self.deviceID == XHY_DEVICE_Camera||self.deviceID == XHY_DEVICE_TV||self.deviceID == XHY_DEVICE_AirConditioner){
        
        [iconName appendString:@"online.png"];
        
    }else{
        
        [iconName appendString:@"offline.png"];
    }

    return iconName;
}

- (NSString *)getFloorRoomDescription{

    NSMutableString *floorStr = [NSMutableString string];
    
    if ([self.floor length]){
        
        [floorStr appendFormat:@"%@",self.floor];
    }
    
    if ([floorStr length]) {
        
        [floorStr appendString:@"/"];
    }
    
    if ([self.room length]){
        
        [floorStr appendFormat:@"%@",self.room];
    }
    
    return floorStr;
}

#pragma mark ----- 修改设备工作状态

- (void)changeDeviceWorkStatus:(NSInteger)workStatus{

    if (workStatus == self.deviceWorkStatus){
        
        return;
    }
    
    struct DeviceInfo_S deviceInfo;
    
    deviceInfo = zigBeeInfo;
    deviceInfo.dev_status = [[NSNumber numberWithInteger:workStatus] unsignedCharValue];
    zigBeeInfo = deviceInfo;
}

- (void)changeDeviceOnlineStatus:(NSInteger)onlineStatus{

    if (onlineStatus == self.deviceOnlineStatus){
        
        return;
    }
    
    struct DeviceInfo_S deviceInfo;
    
    deviceInfo = zigBeeInfo;
    deviceInfo.status = [[NSNumber numberWithInteger:onlineStatus] unsignedCharValue];
    zigBeeInfo = deviceInfo;
}

- (NSString *)description{

    return [NSString stringWithFormat:@"deviceID--->%#x IEEEAddr--->%@ endPoint--->%@ nwkAddr--->%d powerStatus--->%ld",self.deviceID,self.IEEEAddr,[NSNumber numberWithUnsignedChar:self.endPoint],self.nwkAddr,(long)self.powerStatus];
}

@end

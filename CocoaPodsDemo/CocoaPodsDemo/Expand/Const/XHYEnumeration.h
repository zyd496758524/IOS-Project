//
//  XHYEnumeration.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/2.
//  Copyright © 2016年  XHY. All rights reserved.
//

#ifndef XHYEnumeration_h
#define XHYEnumeration_h

typedef NS_ENUM(NSUInteger, XHYSmartDeviceType){
    
    XHY_DEVICE_Curtain              =    0x0501,         //窗帘
    XHY_DEVICE_DoorContact          =    0x0503,         //门磁
    XHY_DEVICE_InfraredDetection    =    0x0302,         //红外传感器(温、湿、亮度)
    XHY_DEVICE_SmokeDetection       =    0x0402,         //烟雾传感器
    XHY_DEVICE_InfraredRepeater     =    0x0500,         //红外转发
    XHY_DEVICE_Lock                 =    0x0502,         //锁
    XHY_DEVICE_Light                =    0x0100,         //灯
    XHY_DEVICE_Switch               =    0x0000,         //插座
    XHY_DEVICE_SmartController      =    0x0600,         //智能遥控器
    XHY_DEVICE_GasDetection         =    0x0011,         //燃气传感器
    XHY_DEVICE_WaterDetection       =    0x0504,         //溢水传感器
    XHY_DEVICE_SOSAlarm             =    0x0010,         //SOS报警器
    XHY_DEVICE_SceneControlPanel    =    0x000A,         //情景控制面板
    XHY_DEVICE_AutoWindowPusher     =    0x0505,         //电动推窗器
    XHY_DEVICE_CenterControlOne     =    0x0506,         //中控开关1位
    XHY_DEVICE_CenterControlTwo     =    0x0507,         //中控开关2位
    XHY_DEVICE_CenterControlThree   =    0x0508,         //中控开关3位
    XHY_DEVICE_PM25                 =	 0x0509,		 //PM2.5检测
    XHY_DEVICE_ColorModule          =    0x0102,         //调光开关
    XHY_DEVICE_MusicPlayer          =    0x4001,         //背景音乐
    
    XHY_DEVICE_Camera               =    0x1111,         //摄像头
    XHY_DEVICE_TV                   =    0x2222,         //电视
    XHY_DEVICE_AirConditioner       =    0x3333,         //空调
};

#endif /* XHYEnumeration_h */

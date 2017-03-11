//
//  XHYMsg.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/24.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XHYSmartDevice;

@interface XHYMsg : NSObject

@property(nonatomic,copy) NSString *account;        //当前账号
@property(nonatomic,assign) int msgType;            //日志消息:0 报警消息:1
@property(nonatomic,copy) NSString *msgDate;        //消息时间 2016-08-23 18:45:32
@property(nonatomic,copy) NSString *deviceNwkAddr;  //设备唯一识别号
@property(nonatomic,assign) int alarmValue;         //消息内容
@property(nonatomic,copy) NSString *msgUUID;        //消息UUID 用于删除

+ (NSArray *)selectAllMsg;

+ (NSArray *)selectAllMsgForDevice:(XHYSmartDevice *)smartDevice;

//查询时间点比某个消息早的30条消息 适用于上拉刷新(全部消息列表中)
+ (NSArray *)selectMsgBefore:(XHYMsg *)msg;

//查询时间点比某个消息早的30条消息 适用于上拉刷新(单独设备的消息列表中)
+ (NSArray *)selectDeviceMsgBefore:(XHYMsg *)msg;

//保存到本地数据库
- (void)saveIntoLocalDB;

- (NSString *)getMsgDisplayContent;

@end

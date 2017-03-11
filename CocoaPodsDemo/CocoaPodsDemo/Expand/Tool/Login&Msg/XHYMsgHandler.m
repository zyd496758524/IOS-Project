//
//  XHYMsgHandler.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/28.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYMsgHandler.h"
#import "XHYDeviceHelper.h"
#import "XHYSmartDevice.h"
#import "JDStatusBarNotification.h"
#import <AudioToolbox/AudioToolbox.h>
#import "XHYMsg.h"
#import "NSString+UUID.h"

static XHYMsgHandler *msgHandle = nil;

@interface XHYMsgHandler(){

    NSTimeInterval lastPlayVoiceTime;
}

@property(nonatomic,strong) NSDateFormatter *msgDateFormatter;
@property(nonatomic,strong) NSOperationQueue *msgNotiQueue;

@end

@implementation XHYMsgHandler

- (NSDateFormatter *)msgDateFormatter{

    if (!_msgDateFormatter) {
        
        _msgDateFormatter = [[NSDateFormatter alloc] init];
        [_msgDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return _msgDateFormatter;
}

- (NSOperationQueue *)msgNotiQueue{

    if (!_msgNotiQueue) {
        
        _msgNotiQueue = [[NSOperationQueue alloc] init];
        _msgNotiQueue.maxConcurrentOperationCount = 1;
    }
    
    return _msgNotiQueue;
}

+ (instancetype)defaultMsgHandler{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        msgHandle = [[XHYMsgHandler alloc] init];
    });
    return msgHandle;
}

- (void)startHandleMsg:(struct MsgInfo_S)msginfo{

    enum MsgType_E msgType = msginfo.type;
    unsigned short nwkAddr;					// Network address.
    unsigned char endPoint;					// Endpoint.

    nwkAddr = msginfo.nwkAddr;
    endPoint = msginfo.endPoint;
    /*
     NSLog(@"msgInfo.nwkAddr = %hu",msgInfo.nwkAddr);
     NSLog(@"msgInfo.endPoint = %c",msgInfo.endPoint);
     NSLog(@"msgInfo.value = %c",msgInfo.value);
     NSLog(@"msgInfo.intValue = %d",msgInfo.intValue);
     NSLog(@"msgInfo.charValue = %s",msgInfo.charValue);
     NSLog(@"msgInfo.charValueLen = %d",msgInfo.charValueLen);
     */
    /*
     enum MsgType_E type;						// Msg type..
     unsigned short nwkAddr;					// Network address.
     unsigned char endPoint;					// Endpoint.
     unsigned char value;						// Msg value.
     unsigned int intValue;						// Msg value by int.
     unsigned char charValue[2048];				// Msg value by char array.
     int charValueLen;							// Len of char array value.
     */
    /*
     MSG_TYPE_REPORT_STATE			= 0,		// Device on/off status changed. For switch, light and lock.
     MSG_TYPE_ONLINE_CHANGE			= 1,		// Device online/offline changed. For all devices.
     MSG_TYPE_REPORT_TEMPERATURE		= 2,		// Report temperature.
     MSG_TYPE_REPORT_HUMIDITY		= 3,		// Report humidity.
     MSG_TYPE_REPORT_DOOR_OPEN		= 4,		// Report door opened.
     MSG_TYPE_MOTION					= 5,		// Report motion alarm.
     MSG_TYPE_SMOKE					= 6,		// Report smoke alarm.
     MSG_TYPE_KNOCK_ON_THE_DOOR		= 7,		// Report someone knock on the the door.
     MSG_TYPE_USER_LIST				= 8,		// User list.
     MSG_TYPE_REPORT_LOCK_OPEN		= 9,		// Report lock opened.
     MSG_TYPE_PHOTO_SENSITIVE_CFG	= 10,		// Get photo sensivive config.
     MSG_TYPE_MOTION_CFG				= 11,		// Get motion config.
     MSG_TYPE_REPORT_CURTAIN_PROGRESS = 12,		// Report curtain progress.
     MSG_TYPE_REPORT_AT_HOME_MODE	= 13,		// Report at home mode.
     MSG_TYPE_REPORT_LEAVE_HOME_DELAY= 14,		// Report leave home delay.
     MSG_TYPE_REPORT_SOS				= 15,		// Report SOS msg
     MSG_TYPE_REPORT_CO_ALARM		= 16,		// Report CO alarm
     MSG_TYPE_REPORT_CH4_ALARM		= 17,		// Report CH4 alarm
     MSG_TYPE_REPORT_REMOTER_LEARNING	= 18,	// Report remoter learning key
     MSG_TYPE_REPORT_MODEDATA_CHANGE = 19,		// Report modedata change
     MSG_TYPE_REPORT_LINKDATA_CHANGE = 20,		// Report linkdata change
     MSG_TYPE_REPORT_RAIN_ALARM		= 21,   	// Report rain alarm: 0位: 0 白天 1黑夜 1位：0 无水 1 有水
     MSG_TYPE_REPORT_GW_VERSION		= 22,		// Report Gateway version
     MSG_TYPE_REPORT_DEVICE_DEL 		= 23,     	// Report Device del
     MSG_TYPE_REPORT_SWITCH_POWER 	= 24,		// Report Device power
     MSG_TYPE_NEW_DEVICE 			= 25,  		// Report New Device
     MSG_TYPE_REPORT_DAYNIGHT 		= 26, 		// Report Day(1) or night(0)
     MSG_TYPE_REPORT_DIMMER_SCENE 	= 27, 		// Report Dimmer scene 0~8
     MSG_TYPE_REPORT_DIMMER_COLOR 	= 28, 		// Report Dimmer color/mode
     MSG_TYPE_REPORT_BGM_STATUS 		= 29, 		// Report Background Music Play Status
     MSG_TYPE_REPORT_BGM_DEVINFO  	= 30,		// Report Background Music Dev info
     MSG_TYPE_REPORT_LINK_DEL		= 31,		// Report link del
     MSG_TYPE_REPORT_GW_PING			= 32,		// Report GW_PING
     MSG_TYPE_REPORT_SAVE_AC_KEY		= 33		// Report Ac remoter save key
     */

    /*
     与设备无关联的消息
     */
    
    if (msgType == MSG_TYPE_REPORT_GW_VERSION){
        //接收网关版本
        char *des = (char *)malloc(msginfo.charValueLen + 1);
        memcpy(des, msginfo.charValue, msginfo.charValueLen);
        des[msginfo.charValueLen] = '\0';
        NSString *gatewayVersion = [NSString stringWithUTF8String:des];
        free(des);
        NSLog(@"获取网关版本%@",gatewayVersion);
        [[NSUserDefaults standardUserDefaults] setObject:gatewayVersion forKey:currentAccount];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
        
    }else if (msgType == MSG_TYPE_REPORT_DEVICE_DEL){
        //删除智能设备
        char *des = (char *)malloc(msginfo.charValueLen + 1);
        memcpy(des, msginfo.charValue, msginfo.charValueLen);
        des[msginfo.charValueLen] = '\0';
        NSString *deleteString = [NSString stringWithUTF8String:des];
        free(des);
        NSData *deleteData = [deleteString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dicDelete = [NSJSONSerialization JSONObjectWithData:deleteData options:NSJSONReadingMutableContainers error:nil];
        NSArray *tempArr = dicDelete[@"devices"];
        if ([tempArr count]){
            
            [tempArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop){
                
                NSNumber *endPoint = obj[@"endPoint"];
                NSString *iEEEAddr = obj[@"iEEEAddr"];
                
                XHYSmartDevice *tempDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:iEEEAddr andEndPoint:[NSString stringWithFormat:@"%@",endPoint]];
                [[XHYDataContainer defaultDataContainer].allSmartDeviceArray removeObject:tempDevice];
                switch (tempDevice.deviceID){
                    case XHY_DEVICE_Camera:
                    case XHY_DEVICE_TV:
                    case XHY_DEVICE_AirConditioner:{
                    
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceDelete object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceFloorInfoChanged object:nil userInfo:nil];
            });
        }
        return;
    }
    
    NSString *msgNwkAddr = [NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedShort:nwkAddr]];
    NSString *msgEndPoint = [NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedChar:endPoint]];
    /*
     处理消息流程 (控制类消息与日志类消息)
     1、首先通过消息中的nwkAddr和endPoint，从总数据源中匹配到对应的设备；
     2、进而更新设备的数据(在线状态，工作状态，温度，湿度等等)(针对于控制类消息)或者将消息保存进数据库(针对于日志类消息)
     3、最后再发广播进而刷新界面
    */
    XHYSmartDevice *msgDevice = [XHYDeviceHelper querySmartDeviceNwkAddr:msgNwkAddr andEndPoint:msgEndPoint];
    if (!msgDevice){
        
        NSLog(@"找不到对应的设备,返回 msgNwkAddr--->%@ msgEndPoint--->%@",msgNwkAddr,msgEndPoint);
        msgNwkAddr = nil;
        msgEndPoint = nil;
        return;
    }
    
    unsigned char value;						// Msg value.
    unsigned int intValue;						// Msg value by int.
    //unsigned char charValue[2048];				// Msg value by char array.
    int charValueLen;							// Len of char array value.

    value = msginfo.value;
    intValue = msginfo.intValue;
    charValueLen = msginfo.charValueLen;
    
    NSString *msgValue = [NSString stringWithFormat:@"%@",[NSNumber numberWithChar:value]];
    NSString *msgIntValue = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:intValue]];
    
    NSLog(@"msgInfo.type --->%d",msgType);
    NSLog(@"接收到消息 msgvalue --->%@ msgIntValue --->%@",msgValue,msgIntValue);
    switch (msgType){
            
        case MSG_TYPE_REPORT_STATE:{
            
            //设备状态相同 可以不处理
            if (msgDevice.deviceWorkStatus == [msgValue integerValue]){
                
                return;
            }
            
            [msgDevice changeDeviceWorkStatus:[msgValue integerValue]];
            NSDictionary *notiDic = [NSDictionary dictionaryWithObjectsAndKeys:msgDevice,@"device",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceWorkStatusChanged object:notiDic];

            NSString *deviceType = msgDevice.deviceName;
            NSString *deviceCustomName = [msgDevice.customDeviceName length]?msgDevice.customDeviceName:msgDevice.deviceName;
            NSString *deviceStatus = [msgValue intValue]?@"开":@"关";
            NSString *msgContent = [NSString stringWithFormat:@"设备类型:%@ 设备名称:%@ 工作状态:%@",deviceType,deviceCustomName,deviceStatus];
            [self showStatusBarNotification:msgContent];
        }
            break;
            
        case MSG_TYPE_ONLINE_CHANGE:{
            
            //设备状态相同 可以不处理
            if (msgDevice.deviceOnlineStatus == [msgValue integerValue]){
                
                return;
            }
            
            [msgDevice changeDeviceOnlineStatus:[msgValue integerValue]];
            NSDictionary *notiDic = [NSDictionary dictionaryWithObjectsAndKeys:msgDevice,@"device",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceWorkStatusChanged object:notiDic];
            
            NSString *deviceType = msgDevice.deviceName;
            NSString *deviceCustomName = [msgDevice.customDeviceName length]?msgDevice.customDeviceName:msgDevice.deviceName;
            NSString *deviceOnlineStatus = [msgValue intValue] ? @"在线" : @"离线";
            NSString *msgContent = [NSString stringWithFormat:@"设备类型:%@ 设备名称:%@ 在线状态:%@",deviceType,deviceCustomName,deviceOnlineStatus];
            
            [self showStatusBarNotification:msgContent];
        }
            break;
            
        case MSG_TYPE_REPORT_TEMPERATURE:{
            
            // 下发温度信息
            // 返回值为当前侦测到温度 一个四位数 需处理
            
            CGFloat temperature = [msgIntValue floatValue] / 100.0f;
            NSString *currentTemerature = [NSString stringWithFormat:@"当前温度 %.0f℃",temperature];
            [self showStatusBarNotification:currentTemerature];
        }
            break;
            
        case MSG_TYPE_REPORT_HUMIDITY:{
            
            // 下发湿度信息
            // 返回值为当前侦测到湿度 一个四位数 需处理
            CGFloat humidity = [msgIntValue floatValue] / 100.0f;
            NSString *currentHumidity = [NSString stringWithFormat:@"当前湿度 %.0f%%",humidity];
            [self showStatusBarNotification:currentHumidity];
        }
            break;
            
        case MSG_TYPE_REPORT_DOOR_OPEN:{
            
            XHYMsg *tempMsg = [[XHYMsg alloc] init];
            tempMsg.account = currentAccount;
            tempMsg.msgType = 0;
            tempMsg.deviceNwkAddr = [NSString stringWithFormat:@"%@#%@",msgNwkAddr,msgEndPoint];
            tempMsg.msgDate = [self.msgDateFormatter stringFromDate: [NSDate date]];
            tempMsg.alarmValue = 1;
            tempMsg.msgUUID = [NSString getUUID];
            [self playNormalVoice];
            [self handleLogMsg:tempMsg];
        }
            break;
            
        case MSG_TYPE_MOTION:{
        
            XHYMsg *tempMsg = [[XHYMsg alloc] init];
            tempMsg.account = currentAccount;
            tempMsg.msgType = 0;
            tempMsg.deviceNwkAddr = [NSString stringWithFormat:@"%@#%@",msgNwkAddr,msgEndPoint];
            tempMsg.msgDate = [self.msgDateFormatter stringFromDate: [NSDate date]];
            tempMsg.alarmValue = 1;
            tempMsg.msgUUID = [NSString getUUID];
            [self playNormalVoice];
            [self handleLogMsg:tempMsg];
        }
            break;
            
        case MSG_TYPE_SMOKE:{
            
            XHYMsg *tempMsg = [[XHYMsg alloc] init];
            tempMsg.account = currentAccount;
            tempMsg.msgType = 1;
            tempMsg.deviceNwkAddr = [NSString stringWithFormat:@"%@#%@",msgNwkAddr,msgEndPoint];
            tempMsg.msgDate = [self.msgDateFormatter stringFromDate: [NSDate date]];
            tempMsg.alarmValue = 1;
            tempMsg.msgUUID = [NSString getUUID];
            [self playNormalVoice];
            [self handleLogMsg:tempMsg];
        }
            break;
            
        case MSG_TYPE_USER_LIST:{
        
        }
            break;
            
        case MSG_TYPE_KNOCK_ON_THE_DOOR:{
            
            XHYMsg *tempMsg = [[XHYMsg alloc] init];
            tempMsg.account = currentAccount;
            tempMsg.msgType = 0;
            tempMsg.deviceNwkAddr = [NSString stringWithFormat:@"%@#%@",msgNwkAddr,msgEndPoint];
            tempMsg.msgDate = [self.msgDateFormatter stringFromDate: [NSDate date]];
            tempMsg.alarmValue = 2;
            tempMsg.msgUUID = [NSString getUUID];
            [self playNormalVoice];
            [self handleLogMsg:tempMsg];
        }
            break;
            
        case MSG_TYPE_REPORT_LOCK_OPEN:{
            
            NSLog(@"LOCK_OPEN");
        }
            break;
            
        case MSG_TYPE_REPORT_CURTAIN_PROGRESS:{
            
            if (XHY_DEVICE_AutoWindowPusher == msgDevice.deviceID) {
                
                //返回数值为 8位数(31421454),其中前四位为最大值（3142）后四位为当前进度值(1454),从而得到百分比进度
                int progress = [msgIntValue intValue];
                int maxProgress = progress / 10000; //取出 最大值
                int currentProgress = progress % 10000; //取出 当前进度
                
                if(maxProgress <= 0){
                    
                    return;
                }
                int nowProgress = 100 - (currentProgress * 100)/maxProgress;
                NSLog(@"电动推窗器当前的进度 %d",nowProgress);
                
            }else if (XHY_DEVICE_Curtain == msgDevice.deviceID){
            
                //返回数值为 8位数(31421454),其中前四位为最大值（3142）后四位为当前进度值(1454),从而得到百分比进度
                int progress = [msgIntValue intValue];
                int maxProgress = progress / 1000; //取出 最大值
                int currentProgress = progress % 1000; //取出 当前进度
                
                if(maxProgress <= 0){
                    return;
                }
                
                int nowProgress = 100 - (currentProgress * 100)/maxProgress;
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    NSString *tempKey = [NSString stringWithFormat:@"%@#progress",msgDevice.deviceIEEEAddrIdentifier];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nowProgress] forKey:tempKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                });
                
                NSLog(@"窗帘当前的进度 %d",nowProgress);
                NSDictionary *notiDic = [NSDictionary dictionaryWithObjectsAndKeys:msgDevice,@"device",[NSNumber numberWithInt:nowProgress],@"progress", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:XHYCurtainProgressChanged object:notiDic];
            }
        }
            break;
            
        case MSG_TYPE_REPORT_AT_HOME_MODE:{
            
            NSLog(@"AT_HOME_MODE");
        }
            break;
            
        case MSG_TYPE_REPORT_LEAVE_HOME_DELAY:{
            
            NSLog(@"LEAVE_HOME_DELAY");
        }
            break;
            
        case MSG_TYPE_REPORT_SOS:{
            
            XHYMsg *tempMsg = [[XHYMsg alloc] init];
            tempMsg.account = currentAccount;
            tempMsg.msgType = 1;
            tempMsg.deviceNwkAddr = [NSString stringWithFormat:@"%@#%@",msgNwkAddr,msgEndPoint];
            tempMsg.msgDate = [self.msgDateFormatter stringFromDate: [NSDate date]];
            tempMsg.alarmValue = 1;
            tempMsg.msgUUID = [NSString getUUID];
            [self playNormalVoice];
            [self handleLogMsg:tempMsg];
        }
            break;
            
        case MSG_TYPE_REPORT_CO_ALARM:{
            
            XHYMsg *tempMsg = [[XHYMsg alloc] init];
            tempMsg.account = currentAccount;
            tempMsg.msgType = 1;
            tempMsg.deviceNwkAddr = [NSString stringWithFormat:@"%@#%@",msgNwkAddr,msgEndPoint];
            tempMsg.msgDate = [self.msgDateFormatter stringFromDate: [NSDate date]];
            tempMsg.alarmValue = 0;
            tempMsg.msgUUID = [NSString getUUID];
            [self playNormalVoice];
            [self handleLogMsg:tempMsg];
        }
            break;
            
        case MSG_TYPE_REPORT_CH4_ALARM:{
            
            XHYMsg *tempMsg = [[XHYMsg alloc] init];
            tempMsg.account = currentAccount;
            tempMsg.msgType = 1;
            tempMsg.deviceNwkAddr = [NSString stringWithFormat:@"%@#%@",msgNwkAddr,msgEndPoint];
            tempMsg.msgDate = [self.msgDateFormatter stringFromDate: [NSDate date]];
            tempMsg.alarmValue = 1;
            tempMsg.msgUUID = [NSString getUUID];
            [self playNormalVoice];
            [self handleLogMsg:tempMsg];
        }
            break;
            
        case MSG_TYPE_REPORT_REMOTER_LEARNING:{
            
        }
            break;
            
        case MSG_TYPE_REPORT_MODEDATA_CHANGE:{
            
        }
            break;
            
        case MSG_TYPE_REPORT_LINKDATA_CHANGE:{
            
        }
            break;
            
        case MSG_TYPE_REPORT_RAIN_ALARM:{
            
            int rainValue = [msgValue intValue];
            int alarmValue = 0;
            if (rainValue == 34||rainValue == 58||rainValue == 1||rainValue == 46){
                
                alarmValue = 1;
            }
            
            XHYMsg *tempMsg = [[XHYMsg alloc] init];
            tempMsg.account = currentAccount;
            tempMsg.msgType = 0;
            tempMsg.deviceNwkAddr = [NSString stringWithFormat:@"%@#%@",msgNwkAddr,msgEndPoint];
            tempMsg.msgDate = [self.msgDateFormatter stringFromDate: [NSDate date]];
            tempMsg.alarmValue = alarmValue;
            tempMsg.msgUUID = [NSString getUUID];
            [self playNormalVoice];
            [self handleLogMsg:tempMsg];
        }
            break;
            
            
        case MSG_TYPE_REPORT_SWITCH_POWER:{
            
        }
            break;
            
        case MSG_TYPE_NEW_DEVICE:{
            
        }
            break;
            
        case MSG_TYPE_REPORT_DAYNIGHT:{
            
            NSInteger day = [msgIntValue integerValue];
            if (day) {
                
                NSLog(@"亮度检测显示为->白天");
                
            }else{
                
                NSLog(@"亮度检测显示为->黑夜");
            }
        }
            break;
            
        case MSG_TYPE_REPORT_DIMMER_SCENE:{
            
        }
            break;
            
        case MSG_TYPE_REPORT_DIMMER_COLOR:{
            
        }
            break;
            
        case MSG_TYPE_REPORT_BGM_STATUS:{
        
        }
            break;
            
        case MSG_TYPE_REPORT_BGM_DEVINFO:{
        
        }
            break;
            
        case MSG_TYPE_REPORT_LINK_DEL:{}
            break;
            
        case MSG_TYPE_REPORT_GW_PING:{}
            break;
            
        case MSG_TYPE_REPORT_SAVE_AC_KEY:{}
            break;
            
        default:
            break;
    }
}

//播放提示音
- (void)playNormalVoice{
    
    if ([XHYFORBIDMSG boolValue]){
        return;
    }

    if ([XHYFORBIDVOICE boolValue]){
        return;
    }
    
    if (!lastPlayVoiceTime){
        
        lastPlayVoiceTime =  [[NSDate date] timeIntervalSince1970];
        AudioServicesPlayAlertSound(1312);
        
    }else{
        
        NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
        
        if (current - lastPlayVoiceTime > 5){
            
            AudioServicesPlayAlertSound(1312);
        }
        
        lastPlayVoiceTime = current;
    }
}

//显示状态栏上的通知
- (void)showStatusBarNotification:(NSString *)msgContent{

    if ([XHYFORBIDMSG boolValue]){
        return;
    }
    if ([XHYForbidStatusBarNotification boolValue]){
        
        return;
    }
    
    [JDStatusBarNotification setDefaultStyle:^JDStatusBarStyle *(JDStatusBarStyle *style){
        style.barColor = MainColor;
        style.textColor = [UIColor whiteColor];
        return style;
    }];
    NSBlockOperation *msgNotiOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [JDStatusBarNotification showWithStatus:msgContent dismissAfter:1.0f];
        });
    }];
    [self.msgNotiQueue addOperation:msgNotiOperation];
    [self.msgNotiQueue addOperationWithBlock:^{
        sleep(1);
    }];
}

//处理消息 将消息保存到数据库 然后再界面上显示
- (void)handleLogMsg:(XHYMsg *)msg{

    if ([XHYFORBIDMSG boolValue]){
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [msg saveIntoLocalDB];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:XHYReceiveNeedDisplayMessage object:msg];
        });
    });
}

@end

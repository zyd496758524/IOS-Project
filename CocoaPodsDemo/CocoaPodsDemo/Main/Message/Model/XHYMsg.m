//
//  XHYMsg.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/24.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYMsg.h"
#import "XHYDeviceHelper.h"
#import "XHYDBManager.h"

@implementation XHYMsg

+ (NSArray *)selectAllMsg{

    NSString *queryString = [NSString stringWithFormat:@"select * from XHYMsg where account = '%@' order by msgDate desc limit 30;",currentAccount];
    return [XHYMsg queryMsg:queryString];
}

+ (NSArray *)selectAllMsgForDevice:(XHYSmartDevice *)smartDevice{

    NSString *queryString = [NSString stringWithFormat:@"select * from XHYMsg where account = '%@' and deviceNwkAddr = '%@' order by msgDate desc limit 30;",currentAccount,smartDevice.deviceNwkAddrIdentifier];
    return [XHYMsg queryMsg:queryString];
}

+ (NSArray *)selectMsgBefore:(XHYMsg *)msg{

    NSString *queryString = [NSString stringWithFormat:@"select * from XHYMsg where account = '%@' and msgDate < '%@' order by msgDate desc limit 30;",currentAccount,msg.msgDate];
    return [XHYMsg queryMsg:queryString];
}

+ (NSArray *)selectDeviceMsgBefore:(XHYMsg *)msg{

    NSString *queryString = [NSString stringWithFormat:@"select * from XHYMsg where account = '%@' and deviceNwkAddr = '%@' and msgDate < '%@' order by msgDate desc limit 30;",currentAccount,msg.deviceNwkAddr,msg.msgDate];
    return [XHYMsg queryMsg:queryString];
}

//根据SQL语句查询消息
+ (NSArray *)queryMsg:(NSString *)querySQL{

    FMDatabaseQueue *queue = [XHYDBManager shareDataDaseQueue];
    
    __block NSMutableArray *msgArray = [NSMutableArray array];
    
    [queue inDatabase:^(FMDatabase *db){
        
        if ([db open]){
            
            FMResultSet *set = [db executeQuery:querySQL];
            
            while ([set next]){
                
                XHYMsg *msg = [[XHYMsg alloc] init];
                msg.account = [set stringForColumn:@"account"];
                msg.deviceNwkAddr = [set stringForColumn:@"deviceNwkAddr"];
                msg.msgType = [set intForColumn:@"msgType"];
                msg.msgDate = [set stringForColumn:@"msgDate"];
                msg.alarmValue = [set intForColumn:@"alarmValue"];
                [msgArray addObject:msg];
            }
            
            [set close];
        }
    }];
    
    return msgArray;
}

- (void)saveIntoLocalDB{
    
    FMDatabaseQueue *queue = [XHYDBManager shareDataDaseQueue];
    
    [queue inDatabase:^(FMDatabase *db){
        
        if ([db open]){
            
            BOOL worked = [db executeUpdate:@"insert into XHYMsg ('account','deviceNwkAddr',msgType,'msgDate',alarmValue,'msgUUID') VALUES (?,?,?,?,?,?);",self.account,self.deviceNwkAddr,[NSNumber numberWithInt:self.msgType],self.msgDate,[NSNumber numberWithInt:self.alarmValue],self.msgUUID];
            
            if (!worked){
                
                NSLog(@"insert into XHYMsg fail");
            }
        }
    }];
}

- (NSString *)getMsgDisplayContent{

    NSMutableString *displayMsgContent = [NSMutableString string];
    
    NSMutableString *deviceName = [NSMutableString string];
    XHYSmartDevice *msgDevice = nil;
    
    if ([self.deviceNwkAddr length]){
        
        NSArray *tempArray = [self.deviceNwkAddr componentsSeparatedByString:@"#"];
        if ([tempArray count]){
            
            NSString *nwkAddr = [tempArray firstObject];
            NSString *endPoint = [tempArray lastObject];
            msgDevice = [XHYDeviceHelper querySmartDeviceNwkAddr:nwkAddr andEndPoint:endPoint];
            if (msgDevice){
                
                if ([[msgDevice getFloorRoomDescription] length]){
                    
                    [deviceName appendString:[msgDevice getFloorRoomDescription]];
                }
                if ([deviceName length]){
                    
                    [deviceName appendString:@"/"];
                }
                
                [deviceName appendString:[msgDevice.customDeviceName length] ? msgDevice.customDeviceName : msgDevice.deviceName];
            }
        }
    }
    
    if ([deviceName length]){
        
        [displayMsgContent appendFormat:@"%@ : ",deviceName];
    }

    NSString *tempMsgContent = @"";
    switch (msgDevice.deviceID){
            
            //溢水报警器
        case XHY_DEVICE_WaterDetection:{
        
            if (self.alarmValue) {
                
                tempMsgContent = @"探针导通【有水】";
                
            }else{
                
                tempMsgContent = @"探针断开【无水】";
            }
        }
            break;
            
            //SOS报警器
        case XHY_DEVICE_SOSAlarm:{
            
            tempMsgContent = @"SOS报警";
        }
            break;
            
            //燃气报警器
        case XHY_DEVICE_GasDetection:{
        
            if (self.alarmValue) {
                
                tempMsgContent = @"甲烷超标报警";
                
            }else{
                
                tempMsgContent = @"一氧化碳超标报警";
            }
        }
            break;
            //燃气报警器
        case XHY_DEVICE_SmokeDetection:{
            
            if (self.alarmValue){
                
                tempMsgContent = @"烟雾报警";
            }
        }
            break;

            //多功能红外侦测
        case XHY_DEVICE_InfraredDetection:{
        
            if (self.alarmValue == 1){
                
                tempMsgContent = @"检测到有人移动";
            }
        }
            break;
            
            //门磁
        case XHY_DEVICE_DoorContact:{
            
            if (self.alarmValue == 1){
                
                tempMsgContent = @"门磁打开";
                
            }else if (0 == self.alarmValue){
            
                tempMsgContent = @"门磁关闭";
                
            }else if (2 == self.alarmValue){
                
                tempMsgContent = @"有人敲门";
            }
        }
            break;

        default:
            break;
    }
    
    if ([tempMsgContent length]){
        
        [displayMsgContent appendString:tempMsgContent];
    }
    
    if (![displayMsgContent length]){
        
        displayMsgContent = [NSMutableString stringWithFormat:@"设备或已被移除"];
    }
    
    return displayMsgContent;
}
@end

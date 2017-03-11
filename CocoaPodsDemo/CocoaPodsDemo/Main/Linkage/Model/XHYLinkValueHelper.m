//
//  XHYLinkValueHelper.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/16.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYLinkValueHelper.h"

@implementation XHYLinkValueHelper

+ (NSString *)getActionDescriptionFromActionValue:(NSString *)actionValue{
    
    NSString *title = @"";
    
    if (![actionValue length]){
        
        return title;
    }
    
    switch (actionValue.integerValue) {
            
        case 0:
            title=@"开";
            break;
            
        case 1:
            title=@"关";
            break;
            
        case 2:
            title=@"开";
            break;
            
        case 3:
            title=@"关";
            break;
            
        case 4:
            title = @"有人移动";
            break;
            
        case 5:
            title = @"温度过高";
            break;
            
        case 6:
            title=@"温度过低";
            break;
            
        case 7:
            title = @"湿度过高";
            break;
            
        case 8:
            title = @"湿度过低";
            break;
        case 9:
            title = @"亮光";
            break;
            
        case 10:
            title = @"暗";
            break;
            
        case 11:
            title = @"溢雨报警";
            break;
            
        case 12:
            title = @"甲烷超标";
            break;
            
        case 13:
            title = @"一氧化碳超标";
            break;
            
        case 14:
            title = @"SOS报警";
            break;
            
        case 15:
            title = @"烟雾报警";
            break;
            
        case 16:
            title = @"在家";
            break;
            
        case 17:
            title = @"离家";
            break;
            
        case 18:
            title = @"有人按门铃";
            break;
            
        case 19:
            title = @"开锁";
            break;
            
        case 20:
            title = @"开启监控";
            break;
            
        case 21:
            title = @"抓拍照片";
            break;
            
        case 22:
            title = @"录像5分钟";
            break;
        case 23:
            title = @"转动到预置位";
            break;
            
        case 24:
            title = @"打开电源";
            break;
            
        case 25:
            title = @"关闭电源";
            break;
            
        case 29:
            title = @"切换";
            break;
            
        default:
            break;
    }
    
    return title;
}

+ (BOOL)needAdditionalValueForActionValue:(NSString *)actionValue{

    BOOL isNeed = NO;
    
    switch ([actionValue integerValue]) {
            
        case 5: //title = @"温度过高";
        case 6: //title=@"温度过低";
        case 7: //title = @"湿度过高";
        case 8: //title = @"湿度过低";
        case 9: //title = @"亮光";
        case 10://title = @"暗";
            isNeed = YES;
            break;
            
        default:
            break;
    }
    
    return isNeed;
}

@end

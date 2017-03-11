//
//  XHYCameraConfigureTool.m
//  XHYSparxSmart
//
//  Created by  XHY on 16/7/13.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import "XHYCameraConfigureTool.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

@implementation XHYCameraConfigureTool

+ (BOOL)checkSSID:(NSString*)tempSsid{
    
    if ([tempSsid hasPrefix:@"robot_"] || [tempSsid hasPrefix:@"card"] || [tempSsid hasPrefix:@"car_"]
        || [tempSsid hasPrefix:@"seye_"] || [tempSsid hasPrefix:@"NVR"] || [tempSsid hasPrefix:@"DVR"]
        || [tempSsid hasPrefix:@"beye_"] || [tempSsid hasPrefix:@"IPC"] || [tempSsid hasPrefix:@"Car_"] || [tempSsid hasPrefix:@"BOB_"] || [tempSsid hasPrefix:@"socket_"] || [tempSsid hasPrefix:@"mov_"] || [tempSsid hasPrefix:@"xmjp_"] || [tempSsid hasPrefix:@"spt_"]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (NSString *)currentWifiSSID{
    
    NSArray* ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id infoDic = nil;
    for (NSString* ifnam in ifs) {
        infoDic = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, infoDic);
        //if (infoDic && [infoDic count]) { break; }
    }
    const char* charSSID = [[infoDic objectForKey:@"SSID"] UTF8String];
    NSLog(@"%s", charSSID);
    if (TARGET_IPHONE_SIMULATOR) {
        charSSID = "";
    }
    if (charSSID == NULL) {
        return @"";
    }
    NSString* tempSsid = [NSString stringWithUTF8String:charSSID];
    return tempSsid;
}

+ (NSString*)getCurrent_IP_Address{
    
    NSString* address = @"error";
    struct ifaddrs* interfaces = NULL;
    struct ifaddrs* temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}

+ (NSString*)getCurrent_Mac{
    
    NSArray* ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id infoDic = nil;
    for (NSString* ifnam in ifs) {
        infoDic = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, infoDic);
        //if (infoDic && [infoDic count]) { break; }
    }
    const char* charMac = [[infoDic objectForKey:@"BSSID"] UTF8String];
    NSLog(@"%s", charMac);
    if (TARGET_IPHONE_SIMULATOR) {
        charMac = "kuozhanbu";
    }
    if (charMac == NULL) {
        return @"";
    }
    NSString* Mac = [NSString stringWithUTF8String:charMac];
    return Mac;
}

@end

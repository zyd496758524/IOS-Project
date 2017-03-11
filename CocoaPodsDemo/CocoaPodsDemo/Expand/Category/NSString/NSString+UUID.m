//
//  NSString+UUID.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2017/1/22.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *)getUUID{
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [[NSString stringWithString:(__bridge NSString*)uuid_string_ref] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(uuid_string_ref);
    return uuid;
}

@end

//
//  XHYTCPMsgTool.h
//  XHYSparxSmart
//
//  Created by  XHY on 2017/2/22.
//  Copyright © 2017年 XHY_SmartLife. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHYTCPMsgTool : NSObject

+ (instancetype)shareTCPMsgTool;

//按协议拼接报文
- (NSData *)getFormatterTCPMsg:(NSData *)msgData;

//按协议拼接登录报文(正常客户端登录)
- (NSData *)getFormatterTCPMsgForLogin:(NSString *)account andPassword:(NSString *)pwd;

- (NSData *)getFormatterTCPMsgForConfigurateGateway:(NSString *)SSID andPassword:(NSString *)pwd andencryptType:(int)encrypt;

@end

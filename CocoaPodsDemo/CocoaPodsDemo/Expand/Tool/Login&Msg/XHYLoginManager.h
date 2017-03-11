//
//  XHYLoginManager.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/2.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPPFramework.h"
#import "XMPPReconnect.h"

//#import <UAnYan/UAnYan.h>

typedef void(^LoginSuccessBlock)();
typedef void(^LoginFailureBlock)(NSString *errorDescription);

typedef NS_ENUM(NSUInteger, XHYLoginType){
    
    XHYLoginType_NoLogin = 0,  //未登录
    XHYLoginType_TCPLogin = 1,  //局域网登录
    XHYLoginType_XMPPLogin = 2, //XMPP登录
};

typedef enum {
    
    CMD_MSG = 0x01,
    CMD_LINK = 0x02,
    CMD_MODE = 0x03,
    CMD_EXTRA = 0x04,
    CMD_ROOM = 0x05,
    CMD_IR_REMOTE = 0x06,
    CMD_DEVICE_NAME = 0x07,
    CMD_ACCOUNT = 0x08
    
} CMD_TYPE;

@interface XHYLoginManager : NSObject<GCDAsyncSocketDelegate>{

    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    
    NSString *password;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    
    LoginSuccessBlock _LoginSuccessBlock;
    LoginFailureBlock _LoginFailureBlock;
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, assign, readonly) XHYLoginType currentLoginType;

//@property (nonatomic, strong) UAnYanAPI *anYanAPI;

+ (instancetype)defaultLoginManager;

#pragma mark ----- XMPP(互联网)登录

- (BOOL)connectXMPP:(NSString *)JID andPassword:(NSString *)pwd loginSuccess:(LoginSuccessBlock)successBlock loginFailure:(LoginFailureBlock)failureBlock;

- (void)disconnect;

#pragma mark ----- LAN(局域网)登录

- (BOOL)LocalAreaNetwork:(NSString *)account andPassword:(NSString *)pwd LoginSuccess:(LoginSuccessBlock)successBlock loginFailure:(LoginFailureBlock)failureBlock;

- (void)localAeaNetworkSendMsg:(NSData *)msg;
/*
#pragma mark ----- AnYan(安眼摄像头)登录

- (BOOL)loginAnYan:(NSString *)account andPassword:(NSString *)pwd LoginSuccess:(LoginSuccessBlock)successBlock loginFailure:(LoginFailureBlock)failureBlock;
*/
#pragma mark ----- 局域网和互联网登录合并

- (void)loginWithAccount:(NSString *)account andPassword:(NSString *)pwd andLoginType:(XHYLoginType)loginType;

- (void)sendMessage:(NSString *)msg;

@end

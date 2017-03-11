//
//  XHYMsgSendTool.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/14.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYMsgSendTool.h"
#import "XHYLoginManager.h"

@implementation XHYMsgSendTool

+ (void)sendDeviceControlMsg:(NSString *)msg{

    XHYLoginManager *loginManager = [XHYLoginManager defaultLoginManager];
    //判断当前登录方式 从而选择发送方式
    switch (loginManager.currentLoginType){
        // 互联网登录 发送XMPP消息
        case XHYLoginType_XMPPLogin:{
            
            NSString *IPAddress = [NSString stringWithFormat:@"%@/gateway",mainIP];
            XMPPMessage *sendMsg = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"g%@",currentAccount] domain:IPAddress resource:nil]];
            [sendMsg addChild:[DDXMLNode elementWithName:@"body" stringValue:msg]];
            [loginManager.xmppStream sendElement:sendMsg];
        }
            break;
            
        // 局域网登录 发送TCP数据包消息
        case XHYLoginType_TCPLogin:{
            
            NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
            [loginManager localAeaNetworkSendMsg:msgData];
        }
            break;
            
        default:
            break;
    }
}

+ (void)sendIQData:(NSString *)domin msgContent:(NSString *)msg{

    XHYLoginManager *loginManager = [XHYLoginManager defaultLoginManager];
    //判断当前登录方式 从而选择发送方式
    switch (loginManager.currentLoginType){
            // 互联网登录 发送XMPP消息
        case XHYLoginType_XMPPLogin:{
            
            DDXMLElement *op2 = [[DDXMLElement alloc] initWithName:@"query"];
            [op2 addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:private"];
            
            NSXMLElement *query1 = [NSXMLElement elementWithName:domin xmlns:[NSString stringWithFormat:@"%@:devicePrivateData",domin]];
            DDXMLNode * node = [DDXMLNode elementWithName:@"HashMap" stringValue:msg];
            [query1 addChild:node];
            [op2 addChild:query1];
            
            XMPPIQ *setIQ = [XMPPIQ iqWithType:@"set" elementID:[[loginManager xmppStream] generateUUID]];
            [setIQ addChild:op2];
            [[loginManager xmppStream] sendElement:setIQ];
        }
            break;
            
            // 局域网登录 发送TCP数据包消息
        case XHYLoginType_TCPLogin:{
            
            NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
            [loginManager localAeaNetworkSendMsg:msgData];
        }
            break;
            
        default:
            break;
    }
}

@end

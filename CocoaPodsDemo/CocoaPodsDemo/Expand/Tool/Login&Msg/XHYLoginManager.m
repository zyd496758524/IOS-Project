//
//  XHYLoginManager.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/2.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYLoginManager.h"

#import "XMPP.h"
#import "XMPPReconnect.h"


#import "XHYDataContainer.h"
#import "XHYSmartDevice.h"
#import "XHYMsgHandler.h"
#import "XHYTCPMsgTool.h"

static XHYLoginManager *currentLoginManager = nil;
static const long kTCPMsgTag = 200;

@interface XHYLoginManager()<GCDAsyncUdpSocketDelegate>{

    XHYLoginType _currentLoginType;
    
    NSMutableData *reviceData;
    NSString *tcpAccount;
    NSString *tcpPassword;
    dispatch_queue_t xmppQueue;
}

@property(nonatomic,strong) GCDAsyncSocket *TCPSocket;
@property(nonatomic,strong) GCDAsyncUdpSocket *UDPSocket;

@end

@implementation XHYLoginManager

@synthesize xmppStream;
@synthesize xmppReconnect;

#pragma mark ----- Singleton

+ (instancetype)defaultLoginManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!currentLoginManager) {
            
            currentLoginManager = [[XHYLoginManager alloc] initSingleton];
            [currentLoginManager setupStream];
        }
    });
    return currentLoginManager;
}

#pragma mark ----- Getter

- (XHYLoginType)currentLoginType{

    return _currentLoginType;
}

- (GCDAsyncSocket *)TCPSocket{

    if (!_TCPSocket){
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        _TCPSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    }
    
    return _TCPSocket;
}

- (GCDAsyncUdpSocket *)UDPSocket{

    if (!_UDPSocket){
        
        _UDPSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return _UDPSocket;
}

/*
- (UAnYanAPI *)anYanAPI{

    if (!_anYanAPI) {
        
        _anYanAPI = [UAnYanAPI sharedSingleton];
        _anYanAPI.notifyDelegate = self;
    }
    
    return _anYanAPI;
}
*/
#pragma mark ----- Init

- (instancetype)initSingleton{

    if (self = [super init]){
        
        xmppQueue = dispatch_queue_create("com.xhy.cocoaPodsDemo", NULL);
        _currentLoginType = XHYLoginType_NoLogin;
    }
    
    return self;
}

#pragma mark ----- Private


- (void)setupStream{
    
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect  activate:xmppStream];
    [xmppStream addDelegate:self delegateQueue:xmppQueue];
    [xmppReconnect addDelegate:self delegateQueue:xmppQueue];
    
    [xmppStream setHostName:mainIP];
    [xmppStream setHostPort:5222];
    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
}

- (void)teardownStream{
    
    [xmppStream removeDelegate:self];
    [xmppReconnect deactivate];
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
}

- (void)goOnline{
    
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    NSString *domain = [xmppStream.myJID domain];

    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline{
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ----- Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connectXMPP:(NSString *)JID andPassword:(NSString *)pwd loginSuccess:(LoginSuccessBlock)successBlock loginFailure:(LoginFailureBlock)failureBlock{
    
    if (![xmppStream isDisconnected]){
        
        return YES;
    }
    
    NSString *myJID = [NSString stringWithFormat:@"%@@%@",JID,mainIP];
    NSString *myPassword = pwd;
    
    if (myJID == nil || myPassword == nil){
        
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    _LoginSuccessBlock = successBlock;
    _LoginFailureBlock = failureBlock;
    
    NSError *error = nil;
    NSLog(@"开始连接openFire服务器");
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

- (void)disconnect{
    
    if (xmppStream.isConnected){
        
        [self goOffline];
        [xmppStream disconnect];
    }
    
    if (self.TCPSocket.isConnected){
        
        [self.TCPSocket disconnect];
    }
    
    _currentLoginType = XHYLoginType_NoLogin;
}

#pragma mark -----
#pragma mark -----  XMPPStream Delegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    isXmppConnected = YES;
    NSError *error = nil;
    NSLog(@"连接openFire服务器成功，开始验证身份");
    if (![[self xmppStream] authenticateWithPassword:password error:&error]){}
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{

    [self disconnect];
    if (_LoginFailureBlock){
        
        _LoginFailureBlock(@"登录超时");
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    NSLog(@"通过身份验证，openFire服务器登录成功，开始获取所有数据");
    [self goOnline];
    /*
        发送获取App所需数据的请求 设备列表（普通设备，红外转发，摄像头、电视、空调等）联动数据 模式数据 网关信息 楼层数据
    */
    
    //send Message
    [self getAllDevice:currentAccount];
    [self getGatewayVersion:currentAccount];
    //send IQ
    [self IQQueryLinkageData:currentAccount];
    [self IQQuery:@"ExtraDeviceData"];  //空调、电视、摄像头等设备信息
    [self IQQuery:@"ScenceData"];       //楼层数据
    [self IQQuery:@"DeviceName"];       //自定义名数据
    [self IQQuery:@"Infra_Data"];       //红外转发数据
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    
    NSLog(@"未通过身份验证，登录失败");
    [self disconnect];
    //无法确定账号还是密码错误
    if (_LoginFailureBlock){
        _LoginFailureBlock(@"身份验证失败,请检查账号和密码是否正确");
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error{
    
    NSLog(@"didReceiveError %@",error);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
    if(!isXmppConnected){
        
        if(_LoginFailureBlock){
            
            _LoginFailureBlock(error.localizedDescription);
        }
    }
}

#pragma mark ----- Send Message/IQ
#pragma mark ----- IQ
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    //NSLog(@"%@;%@",NSStringFromSelector(_cmd),iq);
    NSXMLElement *vCard = [iq elementForName:@"vCard"];
    NSXMLElement *ModeData = [vCard elementForName:@"modeData"];
    NSXMLElement *LinkedData = [vCard elementForName:@"linkedData"];
    
    if (ModeData){
        
        NSString *a1Encode2 = [ModeData.stringValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [a1Encode2 dataUsingEncoding:NSUTF8StringEncoding];
        
        if(data != nil) {
            
            NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"模式数据,%@",dic);
            NSMutableArray *modeDataArray = dic[@"modeBeans"];
            [XHYDataContainer defaultDataContainer].allModeDataArray = modeDataArray;
        }
    }
    if (LinkedData){
        
        NSString *a1Encode2 = [LinkedData.stringValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [a1Encode2 dataUsingEncoding:NSUTF8StringEncoding];
        
        if(data != nil){
            
            NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"联动数据%@",dic);
            NSMutableArray *linkDataArray = dic[@"mLinkedData"];
            [XHYDataContainer defaultDataContainer].allLinkageDataArray = linkDataArray;
        }
    }
    
    NSXMLElement *query = [iq elementForName:@"query"];
    NSXMLElement *DeviceName = [query elementForName:@"DeviceName"];
    NSXMLElement *ExtraDeviceData = [query elementForName:@"ExtraDeviceData"];
    NSXMLElement *ScenceData = [query elementForName:@"ScenceData"];
    NSXMLElement *Infra_Data = [query elementForName:@"Infra_Data"];
    
    if (query) {
        
        NSString *a1Encode2 = [query.stringValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [a1Encode2 dataUsingEncoding:NSUTF8StringEncoding];
        
        if (DeviceName && [data length]){
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@",dic);
            [XHYDataContainer defaultDataContainer].deviceNameDict = dic;
            
            if ([[XHYDataContainer defaultDataContainer] startConfigureDeviceName]){
                
                NSLog(@"自定义名信息后到，匹配信息成功后，发送广播通知界面刷新");
                [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceNameChanged object:nil];
            }
            
            //NSLog(@"DeviceName %@",dic);
        }
        
        if (ExtraDeviceData && [data length]){
            
            //摄像头,红外转发设备(电视,空调)等设备
            NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"ExtraDeviceData --- %@",dic);
            NSArray *cameraArray = dic[@"mExtraData"];
            if ([cameraArray count]){
                
                [cameraArray enumerateObjectsUsingBlock:^(NSDictionary *cameraDict, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSString *cameraUID = cameraDict[@"UUID"];
                    NSString *cameraIEEEAddr = cameraDict[@"iEEEAddr"];
                    NSNumber *cameraEndPoint = cameraDict[@"endPoint"];
                    NSString *belongTo = cameraDict[@"belongTo"];
                    
                    if ([cameraUID length] && [cameraIEEEAddr length] && [cameraEndPoint longValue]){
                        
                        struct DeviceInfo_S deviceInfo;
                        deviceInfo.deviceId = ZCL_HA_DEVICEID_CAMERA;
                        deviceInfo.IEEEAddr = [cameraIEEEAddr longLongValue];
                        deviceInfo.endPoint = [cameraEndPoint unsignedCharValue];
                        deviceInfo.powerStatus = 0xff;
                        
                        XHYSmartDevice *cameraDevice = [[XHYSmartDevice alloc] initWithZigBeeData:deviceInfo];
                        
                        if (![[XHYDataContainer defaultDataContainer] smartDeviceExist:cameraDevice]){
                            
                            [[XHYDataContainer defaultDataContainer].allSmartDeviceArray addObject:cameraDevice];
                        }
                        
                    }else if ([belongTo length]&& [cameraIEEEAddr length] && [cameraEndPoint longValue]){
                        
                        /*
                         belongTo = "8305#5149013102687731#32";
                         deviceSerialNumber = 13107;
                         endPoint = 99;
                         iEEEAddr = 74866554864000;
                         isStudy = 0;
                         mGroup = 4332;
                         mStudyGroup = 0;
                         
                         belongTo = "8305#5149013102687731#32";
                         deviceSerialNumber = 8738;
                         endPoint = 116;
                         iEEEAddr = 264891824873460;
                         isStudy = 1;
                         mGroup = "";
                         mStudyGroup = 0;
                         */
                        struct DeviceInfo_S deviceInfo;
                        deviceInfo.deviceId = [cameraDict[@"deviceSerialNumber"] intValue];
                        deviceInfo.IEEEAddr = [cameraIEEEAddr longLongValue];
                        deviceInfo.endPoint = [cameraEndPoint unsignedCharValue];
                        deviceInfo.powerStatus = 0xff;
                        
                        XHYSmartDevice *smartDevice = [[XHYSmartDevice alloc] initWithZigBeeData:deviceInfo];
                        smartDevice.belongTo = cameraDict[@"belongTo"];
                        smartDevice.addType = [cameraDict[@"isStudy"] integerValue];
                        smartDevice.groupID = cameraDict[@"mGroup"];
                        
                        if (![[XHYDataContainer defaultDataContainer] smartDeviceExist:smartDevice]){
                            
                            [[XHYDataContainer defaultDataContainer].allSmartDeviceArray addObject:smartDevice];
                        }
                    }
                }];
            }
        }
        
        if (ScenceData && [data length]){
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *floorArray = dic[@"mfloorbeans"];
            //NSLog(@"floorArray %@",floorArray);
            if ([floorArray count]){
                
                [[XHYDataContainer defaultDataContainer].allFloorDataArray removeAllObjects];
                [XHYDataContainer defaultDataContainer].allFloorDataArray = [NSMutableArray arrayWithArray:floorArray];
                if([[XHYDataContainer defaultDataContainer] startCongigureDeviceFloor]){
                    
                    NSLog(@"楼层信息后到，匹配信息成功后，发送广播通知界面刷新");
                    [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceFloorInfoChanged object:nil];
                }
            }
        }
        
        if (Infra_Data && [data length]){
            
            NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"Infra_Data %@",dic);
        }
    }
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq{
    
    NSLog(@"%@;%@",NSStringFromSelector(_cmd),iq);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error{
    
    NSLog(@"%@;%@",NSStringFromSelector(_cmd),iq);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[UIApplication sharedApplication].keyWindow makeToast:@"信息保存失败!" duration:1.0f position:CSToastPositionCenter];
    });
}

#pragma mark ----- Message

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    if ([message isChatMessageWithBody]){
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        const char *temp = [body cStringUsingEncoding:NSASCIIStringEncoding];
        int isContinue = networkResponse(temp,(int)body.length);
        
        if(0 == isContinue){
            
            int totalNum = getDeviceCount();
            for(int i = 0; i < totalNum; i++){
                
                struct DeviceInfo_S *device = getDeviceInfo(i);
                NSInteger status = [[NSNumber numberWithChar:device->status] integerValue];
                /*
                 状态为2，表示设备或被删除，隐藏显示
                */
                if(device == NULL||status == 2){
                    
                    continue;
                }
                
                XHYSmartDevice *tempSmartDevice = [[XHYSmartDevice alloc] initWithZigBeeData:*device];
                //NSLog(@"SmartDevice--->%@",[tempSmartDevice description]);
                if (tempSmartDevice.deviceID == 0xff){
                    tempSmartDevice = nil;
                    continue;
                }
                if (![[XHYDataContainer defaultDataContainer] smartDeviceExist:tempSmartDevice]){
                    
                    [[XHYDataContainer defaultDataContainer].allSmartDeviceArray addObject:tempSmartDevice];
                }
            }
            //NSLog(@"全部智能设备信息%lu",(unsigned long)[[XHYDataContainer defaultDataContainer].allSmartDeviceArray count]);
            [[XHYDataContainer defaultDataContainer] startCongigureDeviceFloor];
            [[XHYDataContainer defaultDataContainer] startConfigureDeviceName];
            _currentLoginType = XHYLoginType_XMPPLogin;
            
            if (_LoginSuccessBlock) {
                
                _LoginSuccessBlock();
                _LoginSuccessBlock = nil;
                
            }else{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceFloorInfoChanged object:nil];
            }
        }
        
        struct MsgInfo_S msgInfo;
        int command = handleMsg(temp, (int)body.length, &msgInfo);
        if(0 == command){
            
            NSLog(@"接收消息的原始数据 --->%@",body);
            [[XHYMsgHandler defaultMsgHandler] startHandleMsg:msgInfo];
        }
    }
}
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    
    NSLog(@"%@;%@",NSStringFromSelector(_cmd),message);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    
    NSLog(@"%@;%@",NSStringFromSelector(_cmd),message);
    dispatch_async(dispatch_get_main_queue(), ^{
        
         [[UIApplication sharedApplication].keyWindow makeToast:@"消息发送失败!" duration:1.0f position:CSToastPositionCenter];
    });
}

#pragma mark ----- XMPPReconnectDelegate

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags{

    NSLog(@"发现意外断线 网络连接--->%d",connectionFlags);
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags{
    
    NSLog(@"尝试自动重连 网络连接--->%d",reachabilityFlags);
    return YES;
}

#pragma mark ----- 获取设备信息和其他联动数据命令

- (void)getAllDevice:(NSString *)account{
    
    if (![account length]){
        return;
    }
    
    NSString *IPAddress = [NSString stringWithFormat:@"%@/gateway",mainIP];
    XMPPMessage *ms = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"g%@",account] domain:IPAddress resource:nil]];
    char buffer[100] = {0};
    getNetworkRequest(buffer);
    NSString *tempStr = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    [ms addChild:[DDXMLNode elementWithName:@"body" stringValue:tempStr]];
    [self.xmppStream sendElement:ms];
}

- (void)IQQuery:(NSString *)element{
    
    DDXMLElement *xmlElement = [[DDXMLElement alloc] initWithName:@"query"];
    [xmlElement addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:private"];
    NSXMLElement *query1 = [NSXMLElement elementWithName:element xmlns:[NSString stringWithFormat:@"%@:devicePrivateData",element]];
    [xmlElement addChild:query1];
    
    XMPPIQ *xmppIQ = [XMPPIQ iqWithType:@"get" elementID:[self.xmppStream generateUUID]];
    [xmppIQ addChild:xmlElement];
    [self.xmppStream sendElement:xmppIQ];
}

//获取联动数据
- (void)IQQueryLinkageData:(NSString *)account{
    
    NSXMLElement *query1 = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    XMPPIQ *sbIQ = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"g%@", account] domain:mainIP resource:nil]];
    [sbIQ addChild:query1];
    [self.xmppStream sendElement:sbIQ];
}

- (void)getGatewayVersion:(NSString *)account{
    
    char buffer[100] = {0};
    getGwVersion(buffer);
    
    NSString *gwString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    NSString *IPAddress = [NSString stringWithFormat:@"%@/gateway",mainIP];
    
    XMPPMessage *ms = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"g%@",account] domain:IPAddress resource:nil]];
    
    [ms addChild:[DDXMLNode elementWithName:@"body" stringValue:gwString]];
    [self.xmppStream sendElement:ms];
}

#pragma mark ----- Local Area Network

- (BOOL)LocalAreaNetwork:(NSString *)account andPassword:(NSString *)pwd LoginSuccess:(LoginSuccessBlock)successBlock loginFailure:(LoginFailureBlock)failureBlock{

    _LoginSuccessBlock = successBlock;
    _LoginFailureBlock = failureBlock;
    tcpAccount = account;
    tcpPassword = pwd;
    
    [self.UDPSocket localPort];
    NSTimeInterval timeout = 5000;
    NSString *request = @"GETIP";
    NSData *data = [NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    UInt16 port = 9090;
    NSError *error;
    [self.UDPSocket enableBroadcast:YES error:&error];
    [self.UDPSocket sendData:data toHost:@"255.255.255.255" port:port withTimeout:timeout tag:1];
    return [self.UDPSocket beginReceiving:&error];

    /*
    NSString *localIP = @"192.168.2.101";
    u_int16_t port = 8001;
    
    NSError *error = nil;
    BOOL isContect = [self.TCPSocket connectToHost:localIP onPort:port error:&error];
    if (error){
        
        NSLog(@"%@",[error localizedDescription]);
    }
    
    if (isContect){
     
        reviceData = [NSMutableData data];
    }
    
    return NO;
    */
}

#pragma mark ----- GCDAsyncUdpSocketDelegate

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
    if(error){
        
        if(_LoginFailureBlock){
            
            _LoginFailureBlock([error localizedDescription]);
        }
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
    [self.UDPSocket beginReceiving:nil];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(nullable id)filterContext{
    
    if ([data length]){
        
        NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"udpSocket didReceiveData:%@",result);
        
        if (![result hasSuffix:@".138"]){
            
            return;
        }
        
        u_int16_t port = 8001;
        if ([self.TCPSocket isConnected]){
            
            [self.TCPSocket disconnect];
        }
        
        NSError *error = nil;
        BOOL isContect = [self.TCPSocket connectToHost:result onPort:port error:&error];
        
        if (error){
            
            if (_LoginFailureBlock){
                
                _LoginFailureBlock([error localizedDescription]);
            }
        }
        
        if (isContect){
            reviceData = [NSMutableData data];
        }
    }
}


#pragma mark -----
#pragma mark ----- GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
    NSError *error = nil;
    [sock acceptOnPort:port error:&error];
    [self localAreaNetworkLogin:tcpAccount andPassword:tcpPassword];
    [sock readDataWithTimeout:-1 tag:kTCPMsgTag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
    NSLog(@"断开连接 %@",err.localizedDescription);
    if (_LoginFailureBlock){
        
        _LoginFailureBlock(err.localizedDescription);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    [sock readDataWithTimeout:-1 tag:200];
    NSUInteger nLen = [data length];
    if(nLen <= 0){
        
        return;
    }
    
    [reviceData appendData:data];
    
    do {
        //从缓存区截取出完整的消息
        NSData *msgData = [self captureSignificantByte:reviceData];
        
        //判断消息是否有效
        if ([msgData length]){
            //解析消息 再做后续处理
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReviceTCPData:msgData];
            });
            
        }else{
            //没有完整报文 跳出循环
            break;
        }
        
        //缓存区为空时 跳出循环
    } while ([reviceData length]);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{

    NSLog(@"didWriteDataWithTag %ld",tag);
}

#pragma mark ----- 处理接收消息

- (NSData *)captureSignificantByte:(NSMutableData *)data{
    
    NSUInteger nLen = [data length];
    NSData *msgData = nil;
    if (!nLen){
        
        return msgData;
    }
    
    Byte *buffer = (Byte *)[data bytes];
    if (buffer[0] == 0xfe && buffer[1] == 0xef){
        
        unsigned char headBuffer[4] = {0};
        [data getBytes:&headBuffer range:NSMakeRange(2, 4)];
        int  allLength = [self transToInt:headBuffer];
        if (buffer[allLength + 2] == 0xff && allLength < nLen){
            
            msgData = [data subdataWithRange:NSMakeRange(0, allLength + 3)];
            [data replaceBytesInRange:NSMakeRange(0, allLength + 3) withBytes:NULL length:0];
        }
    }
    
    return msgData;
}


- (void)handleReviceTCPData:(NSData *)data{
    
    NSUInteger nLen = [data length];
    if(nLen <= 0){
        return;
    }
    
    Byte *buffer = (Byte *)[data bytes];
    if (buffer[0] == 0xfe && buffer[1] == 0xef && buffer[nLen - 1] == 0xff){
        
        unsigned char headBuffer[4] = {0};
        [data getBytes:&headBuffer range:NSMakeRange(2, 4)];
        
        //报文总长度（不包括报头报尾）
        //将字符串转为表示长度的整型
        int  allLength = [self transToInt:headBuffer];
        //判断长度
        if (allLength == nLen - 3){
            
            //截取消息类型
            unsigned char msgTypeBuffer[1] = {0};
            msgTypeBuffer[0] = buffer[11];
            
            unsigned char len0[4] = {0};
            [data getBytes:&len0 range:NSMakeRange(12,4)];
            int tempLen0 = [self transToInt:len0];
            
            //截取出data0数据
            int dataLen = tempLen0 - 4;
            NSData *bodyData = [data subdataWithRange:NSMakeRange(16,dataLen)];
            
            if (![bodyData length]){
                
                return;
            }
            
            if(msgTypeBuffer[0] == CMD_MSG){
                
                int isContinue = networkResponse((const char *)[bodyData bytes],dataLen);
                
                if(0 == isContinue){
                    
                    int totalNum = getDeviceCount();
                    for(int i = 0; i < totalNum; i++){
                        
                        struct DeviceInfo_S *device = getDeviceInfo(i);
                        NSInteger status = [[NSNumber numberWithChar:device->status] integerValue];
                        /*
                         状态为2，表示设备或被删除，隐藏显示
                         */
                        if(device == NULL||status == 2){
                            
                            continue;
                        }
                        
                        XHYSmartDevice *tempSmartDevice = [[XHYSmartDevice alloc] initWithZigBeeData:*device];
                        NSLog(@"SmartDevice--->%@",[tempSmartDevice description]);
                        if (tempSmartDevice.deviceID == 0xff){
                            tempSmartDevice = nil;
                            continue;
                        }
                        if (![[XHYDataContainer defaultDataContainer] smartDeviceExist:tempSmartDevice]){
                            
                            [[XHYDataContainer defaultDataContainer].allSmartDeviceArray addObject:tempSmartDevice];
                        }
                    }
                    //NSLog(@"全部智能设备信息%lu",(unsigned long)[[XHYDataContainer defaultDataContainer].allSmartDeviceArray count]);
                    [[XHYDataContainer defaultDataContainer] startCongigureDeviceFloor];
                    [[XHYDataContainer defaultDataContainer] startConfigureDeviceName];
                    _currentLoginType = XHYLoginType_XMPPLogin;
                    
                    if (_LoginSuccessBlock) {
                        
                        _LoginSuccessBlock();
                        _LoginSuccessBlock = nil;
                        
                    }else{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceFloorInfoChanged object:nil];
                    }
                }
                
                struct MsgInfo_S msgInfo;
                int command = handleMsg((const char *)[bodyData bytes],dataLen, &msgInfo);
                if(0 == command){
                    switch (msgInfo.type) {
                            
                        case MSG_TYPE_GET_LINK_DATA:{
                            
                            char *linkBuffer = (char *)malloc(sizeof(char) * 100 * 1024);
                            handleSpMessage((const char *)[bodyData bytes],100 * 1024,linkBuffer);
                            
                            NSString *linkString = [[NSString alloc] initWithCString:(const char *)linkBuffer encoding:NSUTF8StringEncoding];
                            NSString *tempLinkString = [linkString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            NSData *linkData = [tempLinkString dataUsingEncoding:NSUTF8StringEncoding];
                            
                            if ([linkData length]) {
                                
                                NSError *error = nil;
                                NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:linkData options:NSJSONReadingMutableContainers error:&error];
                                
                                if (dic && !error){
                                    
                                    NSMutableArray *linkDataArray = dic[@"mLinkedData"];
                                    [XHYDataContainer defaultDataContainer].allLinkageDataArray = linkDataArray;
                                }
                            }
                        }
                            break;
                            
                        case MSG_TYPE_GET_MODE_DATA:{
                            
                            char *modeBuffer = (char *)malloc(sizeof(char) * 100 * 1024);
                            handleSpMessage((const char *)[bodyData bytes],100 * 1024,modeBuffer);
                            
                            NSString *modeString = [[NSString alloc] initWithCString:(const char *)modeBuffer encoding:NSUTF8StringEncoding];
                            NSString *tempModeString = [modeString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            NSData *modeData = [tempModeString dataUsingEncoding:NSUTF8StringEncoding];
                            
                            if ([modeData length]) {
                                
                                NSError *error = nil;
                                NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:modeData options:NSJSONReadingMutableContainers error:&error];
                                
                                if (dic && !error) {
                                    
                                    NSMutableArray *modeDataArray = dic[@"modeBeans"];
                                    [XHYDataContainer defaultDataContainer].allModeDataArray = modeDataArray;
                                }
                            }
                        }
                            break;
                            
                        case MSG_TYPE_GET_DEVICE_NAME_DATA:{
                            
                            char *deviceNameBuffer = (char *)malloc(sizeof(char) * 100 * 1024);
                            handleSpMessage((const char *)[bodyData bytes],100 * 1024,deviceNameBuffer);
                            
                            NSString *deviceNameString = [[NSString alloc] initWithCString:(const char *)deviceNameBuffer encoding:NSUTF8StringEncoding];
                            NSString *tempdeviceNameString = [deviceNameString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            NSData *deviceNameData = [tempdeviceNameString dataUsingEncoding:NSUTF8StringEncoding];
                            
                            if ([deviceNameData length]) {
                                
                                NSError *error = nil;
                                NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:deviceNameData options:NSJSONReadingMutableContainers error:&error];
                                
                                if (dic && !error){
                                    
                                    [XHYDataContainer defaultDataContainer].deviceNameDict = dic;
                                    
                                    if ([[XHYDataContainer defaultDataContainer] startConfigureDeviceName]){
                                        
                                        NSLog(@"自定义名信息后到，匹配信息成功后，发送广播通知界面刷新");
                                        [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceNameChanged object:nil];
                                    }
                                }
                            }
                            
                        }
                            break;
                            
                        case MSG_TYPE_GET_ROOM_DATA:{
                            
                            char *roomBuffer = (char *)malloc(sizeof(char) * 100 * 1024);
                            handleSpMessage((const char *)[bodyData bytes],100 * 1024,roomBuffer);
                            
                            NSString *roomString = [[NSString alloc] initWithCString:(const char *)roomBuffer encoding:NSUTF8StringEncoding];
                            NSString *tempRoomString = [roomString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            NSData *roomData = [tempRoomString dataUsingEncoding:NSUTF8StringEncoding];
                            
                            if ([roomData length]) {
                                
                                NSError *error = nil;
                                NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:roomData options:NSJSONReadingMutableContainers error:&error];
                                
                                if (dic && !error){
                                    
                                    NSArray *floorArray = dic[@"mfloorbeans"];
                                    if ([floorArray count]){
                                        
                                        [[XHYDataContainer defaultDataContainer].allFloorDataArray removeAllObjects];
                                        [XHYDataContainer defaultDataContainer].allFloorDataArray = [NSMutableArray arrayWithArray:floorArray];
                                        if([[XHYDataContainer defaultDataContainer] startCongigureDeviceFloor]){
                                            
                                            NSLog(@"楼层信息后到，匹配信息成功后，发送广播通知界面刷新");
                                            [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceFloorInfoChanged object:nil];
                                        }
                                    }
                                }
                            }
                        }
                            break;
                            
                        case MSG_TYPE_GET_EXTRA_DATA:{
                            
                            char *extraBuffer = (char *)malloc(sizeof(char) * 100 * 1024);
                            handleSpMessage((const char *)[bodyData bytes],100 * 1024,extraBuffer);
                            
                            NSString *extraString = [[NSString alloc] initWithCString:(const char *)extraBuffer encoding:NSUTF8StringEncoding];
                            NSString *tempExtraString = [extraString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            NSData *extraData = [tempExtraString dataUsingEncoding:NSUTF8StringEncoding];
                            
                            if ([extraData length]) {
                                
                                //摄像头,红外转发设备(电视,空调)等设备
                                NSError *error = nil;
                                NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:extraData options:NSJSONReadingMutableContainers error:&error];
                                
                                if (dic && !error){
                                    NSArray *cameraArray = dic[@"mExtraData"];
                                    if ([cameraArray count]){
                                        
                                        [cameraArray enumerateObjectsUsingBlock:^(NSDictionary *cameraDict, NSUInteger idx, BOOL * _Nonnull stop) {
                                            
                                            NSString *cameraUID = cameraDict[@"UUID"];
                                            NSString *cameraIEEEAddr = cameraDict[@"iEEEAddr"];
                                            NSNumber *cameraEndPoint = cameraDict[@"endPoint"];
                                            NSString *belongTo = cameraDict[@"belongTo"];
                                            
                                            if ([cameraUID length] && [cameraIEEEAddr length] && [cameraEndPoint longValue]){
                                                
                                                struct DeviceInfo_S deviceInfo;
                                                deviceInfo.deviceId = ZCL_HA_DEVICEID_CAMERA;
                                                deviceInfo.IEEEAddr = [cameraIEEEAddr longLongValue];
                                                deviceInfo.endPoint = [cameraEndPoint unsignedCharValue];
                                                deviceInfo.powerStatus = 0xff;
                                                
                                                XHYSmartDevice *cameraDevice = [[XHYSmartDevice alloc] initWithZigBeeData:deviceInfo];
                                                
                                                if (![[XHYDataContainer defaultDataContainer] smartDeviceExist:cameraDevice]){
                                                    
                                                    [[XHYDataContainer defaultDataContainer].allSmartDeviceArray addObject:cameraDevice];
                                                }
                                                
                                            }else if ([belongTo length]&& [cameraIEEEAddr length] && [cameraEndPoint longValue]){
                                                
                                                struct DeviceInfo_S deviceInfo;
                                                deviceInfo.deviceId = [cameraDict[@"deviceSerialNumber"] intValue];
                                                deviceInfo.IEEEAddr = [cameraIEEEAddr longLongValue];
                                                deviceInfo.endPoint = [cameraEndPoint unsignedCharValue];
                                                deviceInfo.powerStatus = 0xff;
                                                
                                                XHYSmartDevice *smartDevice = [[XHYSmartDevice alloc] initWithZigBeeData:deviceInfo];
                                                smartDevice.belongTo = cameraDict[@"belongTo"];
                                                smartDevice.addType = [cameraDict[@"isStudy"] integerValue];
                                                smartDevice.groupID = cameraDict[@"mGroup"];
                                                
                                                if (![[XHYDataContainer defaultDataContainer] smartDeviceExist:smartDevice]){
                                                    
                                                    [[XHYDataContainer defaultDataContainer].allSmartDeviceArray addObject:smartDevice];
                                                }
                                            }
                                        }];
                                    }
                                }
                            }
                            
                        }
                            break;
                            
                        case MSG_TYPE_GET_IR_DATA:{
                            
                            char *linkBuffer = (char *)malloc(sizeof(char) * 100 * 1024);
                            handleSpMessage((const char *)[bodyData bytes],100 * 1024,linkBuffer);
                            
                            NSString *IRString = [[NSString alloc] initWithCString:(const char *)linkBuffer encoding:NSUTF8StringEncoding];
                            NSString *tempIRString = [IRString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            NSData *linkData = [tempIRString dataUsingEncoding:NSUTF8StringEncoding];
                            
                            if ([linkData length]) {
                                
                                NSError *error = nil;
                                NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:linkData options:NSJSONReadingMutableContainers error:&error];
                                
                                if (dic && !error){
                                    NSLog(@"mIRData --->%@",dic);
                                    //dele.Infra_Data = dic;
                                }
                            }
                        }
                            break;
                            
                        default:{
                            
                            NSLog(@"接收消息的原始数据 --->%@",[bodyData description]);
                            [[XHYMsgHandler defaultMsgHandler] startHandleMsg:msgInfo];
                        }
                            break;
                    }
                }

            }else if (msgTypeBuffer[0] == 0x02){
                
                NSLog(@"登录消息");
                Byte *buffer = (Byte *)[bodyData bytes];
                if (buffer[0] == 0x01){
                    
                    NSLog(@"--- 登录成功 --- 获取基本数据信息");
                    /*
                     获取全部设备
                     */
                    char buffer[100] = {0};
                    getNetworkRequest(buffer);
                    NSData *msgData = [[NSData alloc] initWithBytes:buffer length:strlen(buffer)];
                    [self localAeaNetworkSendMsg:msgData];
                    
                    /*
                     获取全部联动
                     */
                    char linkBuffer[100] = {0};
                    getLinkData(linkBuffer);
                    NSData *linkData = [[NSData alloc] initWithBytes:linkBuffer length:strlen(linkBuffer)];
                    [self localAeaNetworkSendMsg:linkData];

                    /*
                     获取全部模式
                     */
                    char modeBuffer[100] = {0};
                    getModeData(modeBuffer);
                    NSData *modeData = [[NSData alloc] initWithBytes:modeBuffer length:strlen(modeBuffer)];
                    [self localAeaNetworkSendMsg:modeData];
                    
                    /*
                     获取网关版本
                     */
                    char versionBuffer[100] = {0};
                    getGwVersion(buffer);
                    NSData *versionData = [[NSData alloc] initWithBytes:versionBuffer length:strlen(versionBuffer)];
                    [self localAeaNetworkSendMsg:versionData];
                    
                }else{
                    
                    NSLog(@"***登录失败***");
                }
                
            }else{
            
                NSLog(@"未知消息");
            }
        }
        
    }else{
    
        NSLog(@"非完整报文，继续接收");
    }
}

#pragma mark ----- 转换

- (int)transToInt:(unsigned char *)data{
    
    int  totalLen = 0;
    // 4位
    for(int i = 0; i< 4;i++){
        
        int temp = data[i];
        totalLen += temp<<(8*i);
    }
    return totalLen;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-stack-address"

- (char *)transforHex:(int)dataLength{
    
    char temAllLength[4] = {0};
    for(int i = 0;i < 4;i++){ 
        
        temAllLength[i] = dataLength >>(8*i);
    }
    return temAllLength;
}

#pragma mark ----- Send LAN Control Msg

- (void)localAreaNetworkLogin:(NSString *)account andPassword:(NSString *)pwd{

    NSData *msgData = [[XHYTCPMsgTool shareTCPMsgTool] getFormatterTCPMsgForLogin:account andPassword:pwd];
    [self.TCPSocket writeData:msgData withTimeout:10.0f tag:kTCPMsgTag];
}

- (void)localAeaNetworkSendMsg:(NSData *)msg{
    
    NSData *msgData = [[XHYTCPMsgTool shareTCPMsgTool] getFormatterTCPMsg:msg];
    [self.TCPSocket writeData:msgData withTimeout:10.0f tag:kTCPMsgTag];
}

#pragma mark -----

- (void)loginWithAccount:(NSString *)account andPassword:(NSString *)pwd andLoginType:(XHYLoginType)loginType{

    switch (loginType) {
            
        case XHYLoginType_XMPPLogin:{
            [self connectXMPP:account andPassword:pwd loginSuccess:nil loginFailure:nil];
        }
            break;
            
        case XHYLoginType_TCPLogin:{
            [self LocalAreaNetwork:account andPassword:pwd LoginSuccess:nil loginFailure:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)sendMessage:(NSString *)msg{

    
}

@end

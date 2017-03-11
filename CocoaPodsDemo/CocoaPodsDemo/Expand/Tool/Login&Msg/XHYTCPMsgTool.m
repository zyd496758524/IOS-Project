//
//  XHYTCPMsgTool.m
//  XHYSparxSmart
//
//  Created by  XHY on 2017/2/22.
//  Copyright © 2017年 XHY_SmartLife. All rights reserved.
//

#import "XHYTCPMsgTool.h"

static XHYTCPMsgTool *TCPMsgTool = nil;

@implementation XHYTCPMsgTool

+ (instancetype)shareTCPMsgTool{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!TCPMsgTool){
            
            TCPMsgTool = [[XHYTCPMsgTool alloc] init];
        }
    });
    return TCPMsgTool;
}

#pragma mark -----

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

- (NSData *)getFormatterTCPMsg:(NSData *)msgData{

    if ([msgData length]){
        return nil;
    }
    
    char header[2] = {0};
    header[0] = 0xfe;
    header[1] = 0xef;
    
    char temp[4] = {0};
    for (int i = 0; i < 4; i++){
        
        temp[i] = 0x00;
    }
    
    const char *msgChar;
    msgChar = (const char *)[msgData bytes];
    
    int msglength = (int)msgData.length;
    int allTength = 10 + 4 + msglength;
    
    char *tempArr1 = [self transforHex:allTength];
    char allDataheader2[10] = {0};
    memcpy(allDataheader2, tempArr1,4);
    memcpy(allDataheader2 + 4, temp, 4);
    allDataheader2[8] = 0x01;
    allDataheader2[9] = 0x01;
    
    char bodyHeader[4] = {0};
    char *tempArr2 = [self transforHex:msglength + 4];
    memcpy(bodyHeader, tempArr2, 4);
    
    char footer[1] = {0};
    footer[0] = 0xff;
    
    char *finalChar = (char *)malloc(sizeof(char) * (allTength + 3));
    
    memcpy(finalChar, header, sizeof(header));
    memcpy(finalChar + sizeof(header), allDataheader2, sizeof(allDataheader2));
    
    memcpy(finalChar + sizeof(header) + sizeof(allDataheader2), bodyHeader, sizeof(bodyHeader));
    memcpy(finalChar + sizeof(header) + sizeof(allDataheader2) + sizeof(bodyHeader), msgChar, msglength);
    memcpy(finalChar + sizeof(header) + sizeof(allDataheader2) + sizeof(bodyHeader) + msglength, footer, sizeof(footer));
    
    NSData *sendMsgData = [NSData dataWithBytes:finalChar length:allTength + 3];
    return sendMsgData;
}

- (NSData *)getFormatterTCPMsgForLogin:(NSString *)account andPassword:(NSString *)pwd{

    if ([account length]){
        
        return nil;
    }
    
    NSData *accountData = [account dataUsingEncoding:NSUTF8StringEncoding];
    NSData *pwdData = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    
    char header[2] = {0};
    header[0] = 0xfe;
    header[1] = 0xef;
    
    char temp[4] = {0};
    for (int i = 0; i < 4; i++){
        
        temp[i] = 0x00;
    }
    
    const char *accountChar;
    accountChar = (const char *)[accountData bytes];
    
    const char *pwdChar;
    pwdChar = (const char *)[pwdData bytes];
    
    int accountlength = (int)accountData.length;
    int pwdlength = (int)pwdData.length;
    
    int allLength = 10 + 4 + accountlength + 4 + pwdlength;
    
    char *tempArr1 = [self transforHex:allLength];
    char allMsgLength[10] = {0};
    memcpy(allMsgLength, tempArr1,4);
    memcpy(allMsgLength + 4, temp, 4);
    allMsgLength[8] = 0x02;
    allMsgLength[9] = 0x02;
    
    char accountHeader[4] = {0};
    char *tempAccount = [self transforHex:accountlength + 4];
    memcpy(accountHeader, tempAccount, 4);
    
    char pwdHeader[4] = {0};
    char *tempPwd = [self transforHex:pwdlength + 4];
    memcpy(pwdHeader, tempPwd, 4);
    
    char footer[1] = {0};
    footer[0] = 0xff;
    
    char *finalChar = (char *)malloc(sizeof(char) * (allLength + 3));
    
    /*
     拼接报文
    */
    //拼接报头 0xfe 0xef
    memcpy(finalChar, header, sizeof(header));
    
    //长度 + 保留字 + cmd
    memcpy(finalChar + sizeof(header), allMsgLength, sizeof(allMsgLength));
    
    //len0 + data0 账号
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength), accountHeader, 4);
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader), accountChar, accountlength);
    
    //len1 + data1 密码
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader) + accountlength , pwdHeader, 4);
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader) + accountlength + sizeof(pwdHeader), pwdChar, pwdlength);
    
    //报尾
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader) + accountlength + sizeof(pwdHeader) + pwdlength, footer, sizeof(footer));
    
    NSData *msgData = [NSData dataWithBytes:finalChar length:allLength + 3];
    return msgData;
}

- (NSData *)getFormatterTCPMsgForConfigurateGateway:(NSString *)SSID andPassword:(NSString *)pwd andencryptType:(int)encrypt{

    NSData *accountData = [SSID dataUsingEncoding:NSUTF8StringEncoding];
    NSData *pwdData0 =  [pwd dataUsingEncoding:NSUTF8StringEncoding];
    
    char tempEncrypt[1] = {0};
    tempEncrypt[0] = encrypt;
    NSData *tempEn = [NSData dataWithBytes:tempEncrypt length:1];
    NSMutableData *pwdData = [[NSMutableData alloc] initWithData:tempEn];
    [pwdData appendData:pwdData0];
    
    char header[2] = {0};
    header[0] = 0xfe;
    header[1] = 0xef;
    
    char temp[4] = {0};
    for (int i = 0; i < 4; i++){
        
        temp[i] = 0x00;
    }
    
    const char *accountChar;
    accountChar = (const char *)[accountData bytes];
    
    const char *pwdChar;
    pwdChar = (const char *)[pwdData bytes];
    
    int accountlength = (int)accountData.length;
    int pwdlength = (int)pwdData.length;
    
    int allLength = 10 + 4 + accountlength + 4 + pwdlength;
    
    char *tempArr1 = [self transforHex:allLength];
    char allMsgLength[10] = {0};
    memcpy(allMsgLength, tempArr1,4);
    memcpy(allMsgLength + 4, temp, 4);
    allMsgLength[8] = 0x02;
    allMsgLength[9] = 0x02;
    
    char accountHeader[4] = {0};
    char *tempAccount = [self transforHex:accountlength + 4];
    memcpy(accountHeader, tempAccount, 4);
    
    char pwdHeader[4] = {0};
    char *tempPwd = [self transforHex:pwdlength + 4];
    memcpy(pwdHeader, tempPwd, 4);
    
    char footer[1] = {0};
    footer[0] = 0xff;
    
    char *finalChar = (char *)malloc(sizeof(char) * (allLength + 3));
    
    /*
     拼接报文
     */
    //拼接报头 0xfe 0xef
    memcpy(finalChar, header, sizeof(header));
    
    //长度 + 保留字 + cmd
    memcpy(finalChar + sizeof(header), allMsgLength, sizeof(allMsgLength));
    
    //len0 + data0 账号
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength), accountHeader, 4);
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader), accountChar, accountlength);
    
    //len1 + data1 密码
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader) + accountlength , pwdHeader, 4);
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader) + accountlength + sizeof(pwdHeader), pwdChar, pwdlength);
    
    //报尾
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader) + accountlength + sizeof(pwdHeader) + pwdlength, footer, sizeof(footer));
    
    NSData *msgData = [NSData dataWithBytes:finalChar length:allLength + 3];
    return msgData;
}

@end

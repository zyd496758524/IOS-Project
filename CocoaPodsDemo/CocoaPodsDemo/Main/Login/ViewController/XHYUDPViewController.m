//
//  XHYUDPViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2017/2/9.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYUDPViewController.h"
#import "XHYFontTool.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "XHYCameraConfigureTool.h"
#import "XHYLoginField.h"
#import "UIImage+makeColor.h"
#import "UIView+Toast.h"

@interface XHYUDPViewController ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate,UITextFieldDelegate>{
    
    NSTimer *loginTimer;
    NSMutableData *reviceData;
}

@property(nonatomic,strong)GCDAsyncSocket *asyncTCPSocket;
@property(nonatomic,strong)GCDAsyncUdpSocket *asyncUDPSocket;

@property(nonatomic,strong) XHYLoginField *wifiTextField;
@property(nonatomic,strong) XHYLoginField *pwdTextField;
@property(nonatomic,strong) UIButton *senderBtn;

@end

static const long kTCPMsgTag = 200;

@implementation XHYUDPViewController

- (GCDAsyncSocket *)asyncTCPSocket{

    if (!_asyncTCPSocket){
    
        _asyncTCPSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _asyncTCPSocket;
}

- (GCDAsyncUdpSocket *)asyncUDPSocket{

    if (!_asyncUDPSocket){
        
        _asyncUDPSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _asyncUDPSocket;
}

- (UITextField *)wifiTextField{

    if (!_wifiTextField){
        
        _wifiTextField = [[XHYLoginField alloc] initWithFrame:CGRectZero];
        _wifiTextField.delegate = self;
        _wifiTextField.backgroundColor = [UIColor clearColor];
        _wifiTextField.borderStyle = UITextBorderStyleNone;
        _wifiTextField.layer.borderColor = MainColor.CGColor;
        _wifiTextField.layer.borderWidth = 0.6f;
        _wifiTextField.layer.cornerRadius = 6.0f;
        _wifiTextField.textColor = BackgroudColor;
        _wifiTextField.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:18.0f];
        _wifiTextField.keyboardType = UIKeyboardTypeDefault;
        _wifiTextField.returnKeyType = UIReturnKeyDone;
        
        _wifiTextField.leftViewMode = UITextFieldViewModeAlways;
        _wifiTextField.leftView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"login_account"] imageMaskWithColor:MainColor]];
    }
    
    return _wifiTextField;
}

- (UITextField *)pwdTextField{
    
    if (!_pwdTextField){
        
        _pwdTextField = [[XHYLoginField alloc] initWithFrame:CGRectZero];
        _pwdTextField.delegate = self;
        _pwdTextField.backgroundColor = [UIColor clearColor];
        _pwdTextField.borderStyle = UITextBorderStyleNone;
        _pwdTextField.layer.borderColor = MainColor.CGColor;
        _pwdTextField.layer.borderWidth = 0.6f;
        _pwdTextField.layer.cornerRadius = 6.0f;
        _pwdTextField.textColor = BackgroudColor;
        _pwdTextField.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:18.0f];
        _pwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _pwdTextField.returnKeyType = UIReturnKeyDone;
        
        _pwdTextField.leftViewMode = UITextFieldViewModeAlways;
        _pwdTextField.leftView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"login_password"] imageMaskWithColor:MainColor]];

    }
    
    return _pwdTextField;
}

- (UIButton *)senderBtn{
    
    if (!_senderBtn) {
        
        _senderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _senderBtn.backgroundColor = [UIColor clearColor];
        _senderBtn.layer.cornerRadius = 6.0f;
        _senderBtn.layer.borderColor = MainColor.CGColor;
        _senderBtn.layer.borderWidth = 0.6f;
        [_senderBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
        [_senderBtn.titleLabel setTextColor:MainColor];
        [_senderBtn.titleLabel setFont:[XHYFontTool getDeaultFontBaseLanguageWithSize:20.0f]];
        [_senderBtn setTitleColor:BackgroudColor forState:UIControlStateNormal];
        [_senderBtn addTarget:self action:@selector(sendUDP) forControlEvents:UIControlEventTouchUpInside];
        
        //_senderBtn.custom_acceptEventInterval = 1.5f;
        /*
         [_loginBtn addTarget:self action:@selector(loginBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
         [_loginBtn addTarget:self action:@selector(loginBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
         [_loginBtn addTarget:self action:@selector(loginBtnTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
         */
    }
    
    return _senderBtn;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.wifiTextField];
    [self.view addSubview:self.pwdTextField];
    [self.view addSubview:self.senderBtn];
    @JZWeakObj(self);
    [self.wifiTextField mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.top.mas_equalTo(selfWeak.view.mas_top).offset(30);
        make.left.mas_equalTo(selfWeak.view.mas_left).offset(30);
        make.right.mas_equalTo(selfWeak.view.mas_right).offset(-30);
        make.height.mas_equalTo(40.0f);
    }];
    [self.pwdTextField mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.top.mas_equalTo(selfWeak.wifiTextField.mas_bottom).offset(30);
        make.centerX.mas_equalTo(selfWeak.wifiTextField.mas_centerX);
        make.width.mas_equalTo(selfWeak.wifiTextField.mas_width);
        make.height.mas_equalTo(selfWeak.wifiTextField.mas_height);
    }];
    [self.senderBtn mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.top.mas_equalTo(selfWeak.pwdTextField.mas_bottom).offset(30);
        make.centerX.mas_equalTo(selfWeak.pwdTextField.mas_centerX);
        make.width.mas_equalTo(selfWeak.pwdTextField.mas_width);
        make.height.mas_equalTo(selfWeak.pwdTextField.mas_height);
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendUDP{

    [self.asyncUDPSocket localPort];
    NSTimeInterval timeout = 5000;
    NSString *request = @"GETIP";
    NSData *data = [NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    UInt16 port = 9090;
    
    NSError *error;
    [self.asyncUDPSocket enableBroadcast:YES error:&error];
    [self.asyncUDPSocket sendData:data toHost:@"255.255.255.255" port:port withTimeout:timeout tag:1];
    [self.asyncUDPSocket beginReceiving:&error];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setMinimumDismissTimeInterval:20.0f];
    [SVProgressHUD setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8f]];
    [SVProgressHUD showWithStatus:@"正在UDP广播"];
    
    if (loginTimer) {
        
        [loginTimer invalidate];
        loginTimer = nil;
    }
    
    loginTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(xmppLoginTimeOut:) userInfo:nil repeats:NO];
    [loginTimer fireDate];
}

- (void)xmppLoginTimeOut:(NSTimer *)timer{
    
    [SVProgressHUD dismiss];
    [self.view makeToast:@"连接超时" duration:1.0F position:CSToastPositionBottom];
    
    [loginTimer invalidate];
    loginTimer = nil;
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
    if (error) {
        
        NSLog(@"udpSocketDidClose:%@",error.localizedDescription);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        [SVProgressHUD dismissWithDelay:1.0f];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    
    NSLog(@"didNotSendDataWithTag:");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{

    NSLog(@"didSendDataWithTag:");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(nullable id)filterContext{

    NSString *result;
    result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    //NSString *getwayAddress = [[NSString alloc] initWithData:address encoding:NSASCIIStringEncoding];
    NSLog(@"udpSocket didReceiveData:%@,%@",result,address);
    u_int16_t port = 8002;
    NSError *error = nil;
    BOOL isContect = [self.asyncTCPSocket connectToHost:result onPort:port error:&error];
    
    if (error) {
        
        NSLog(@"%@",error.localizedDescription);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        [SVProgressHUD dismissWithDelay:1.0f];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在TCP连接"];
    if (isContect){
        [sock close];
        reviceData = [NSMutableData data];
    }
}


#pragma mark -----
#pragma mark ----- GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"TCP连接成功");
    NSError *error = nil;
    [sock acceptOnPort:port error:&error];
    [self localAreaNetworkLogin:self.wifiTextField.text andPassword:self.pwdTextField.text];
    [sock readDataWithTimeout:-1 tag:kTCPMsgTag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    [sock readDataWithTimeout:-1 tag:tag];
    
    NSUInteger nLen = [data length];
    if(nLen <= 0){
        
        return;
    }
    if (!reviceData) {
        
        reviceData = [NSMutableData data];
    }
    
    //接收到数据后直接往缓存区追加
    [reviceData appendData:data];
    
    NSLog(@"tag--->%ld didReadData--->%@",tag,reviceData);
    /*
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
    */
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
    [sock readDataWithTimeout:-1 tag:tag];
    
}


- (void)handleReviceTCPData:(NSData *)data{

}

#pragma mark ----- 截取出有效消息

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

- (void)localAreaNetworkLogin:(NSString *)account andPassword:(NSString *)pwd{
    
    NSData *accountData = [account dataUsingEncoding:NSUTF8StringEncoding];
    NSData *pwdData = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    
    char header[2] = {0};
    header[0] = 0xfe;
    header[1] = 0xef;
    
    const char *accountChar;
    accountChar = (const char *)[accountData bytes];
    
    const char *pwdChar;
    pwdChar = (const char *)[pwdData bytes];
    
    int accountlength = (int)accountData.length;
    int pwdlength = (int)pwdData.length;
    
    int allLength = 4 + 1 + 4 + accountlength + 4 + pwdlength;
    
    char *tempArr1 = [self transforHex:allLength];
    char allMsgLength[5] = {0};
    memcpy(allMsgLength, tempArr1,4);
    allMsgLength[4] = 0x03;
    
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
    
    //长度 + cmd
    memcpy(finalChar + sizeof(header), allMsgLength, 4 + 1);
    
    //len0 + data0 账号
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength), accountHeader, 4);
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader), accountChar, accountlength);
    
    //len1 + data1 密码
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader) + accountlength , pwdHeader, 4);
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader) + accountlength + sizeof(pwdHeader), pwdChar, pwdlength);
    
    //报尾
    memcpy(finalChar + sizeof(header) + sizeof(allMsgLength) + sizeof(accountHeader) + accountlength + sizeof(pwdHeader) + pwdlength, footer, sizeof(footer));
    
    NSData *msgData = [NSData dataWithBytes:finalChar length:allLength + 3];
    [self.asyncTCPSocket writeData:msgData withTimeout:-1 tag:kTCPMsgTag];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

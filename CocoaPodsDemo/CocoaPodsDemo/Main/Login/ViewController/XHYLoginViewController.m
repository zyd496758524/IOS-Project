//
//  XHYLoginViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/11.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYLoginViewController.h"
#import "XHYLoginField.h"
#import "Masonry.h"
#import "UIView+Toast.h"
#import "UIColor+JKHEX.h"
#import "UIImage+JKGIF.h"
#import "UIImage+Color.h"
#import "UIImage+Blur.h"
#import "UIImage+makeColor.h"
#import "UIImage+RoundedCorner.h"
#import "UIControl+Custom.h"
#import "UITextField+Shake.h"
#import "UITextField+History.h"
#import "XHYLoginManager.h"
#import "XHYFontTool.h"

#import "XHYQrScanViewController.h"
#import "MMDrawerController.h"
#import "XHYRootTabBarController.h"
#import "XHYCenterViewController.h"
#import "XHYUDPViewController.h"

#import "SVProgressHUD.h"
#import <SAMKeychain/SAMKeychain.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

static const CGFloat spaceX = 25.0f;
static const CGFloat spaceY = 25.0f;

@interface XHYLoginViewController ()<UITextFieldDelegate>{

    NSTimer *loginTimer;
}

@property(nonatomic,strong) UIImageView *logoImageView;
@property(nonatomic,strong) XHYLoginField *accountField;
@property(nonatomic,strong) XHYLoginField *passwordField;
@property(nonatomic,strong) UIButton *loginBtn;

@end

@implementation XHYLoginViewController

#pragma mark ----- getters

- (UIImageView *)logoImageView{

    if (!_logoImageView) {
        
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.image = [UIImage imageNamed:@"logo.png"];
    }
    
    return _logoImageView;
}

- (XHYLoginField *)accountField{

    if (!_accountField) {
        
        _accountField = [[XHYLoginField alloc] initWithFrame:CGRectZero];
        _accountField.delegate = self;
        _accountField.backgroundColor = [UIColor clearColor];
        _accountField.borderStyle = UITextBorderStyleNone;
        _accountField.layer.borderColor = MainColor.CGColor;
        _accountField.layer.borderWidth = 0.6f;
        _accountField.layer.cornerRadius = 6.0f;
        _accountField.textColor = BackgroudColor;
        _accountField.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:18.0f];
        _accountField.keyboardType = UIKeyboardTypeDefault;
        _accountField.returnKeyType = UIReturnKeyDone;
        _accountField.leftViewMode = UITextFieldViewModeAlways;
        _accountField.leftView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"login_account"] imageMaskWithColor:MainColor]];
        _accountField.rightViewMode = UITextFieldViewModeAlways;
        UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [scanBtn setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        [scanBtn setImage:[[UIImage imageNamed:@"login_qrcode"] imageMaskWithColor:MainColor] forState:UIControlStateNormal];
        [scanBtn addTarget:self action:@selector(scanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _accountField.rightView = scanBtn;
        _accountField.identify = @"XHYACCOUNT";
    }
    
    return _accountField;
}

- (XHYLoginField *)passwordField{
    
    if (!_passwordField) {
        
        _passwordField = [[XHYLoginField alloc] initWithFrame:CGRectZero];
        _passwordField.delegate = self;
        _passwordField.backgroundColor = [UIColor clearColor];
        _passwordField.borderStyle = UITextBorderStyleNone;
        _passwordField.layer.borderColor = MainColor.CGColor;
        _passwordField.layer.borderWidth = 0.6f;
        _passwordField.layer.cornerRadius = 6.0f;
        _passwordField.textColor = BackgroudColor;
        _passwordField.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:18.0f];
        _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
        _passwordField.returnKeyType = UIReturnKeyDone;
        _passwordField.leftViewMode = UITextFieldViewModeAlways;
        _passwordField.leftView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"login_password"] imageMaskWithColor:MainColor]];
        _passwordField.rightViewMode = UITextFieldViewModeAlways;
        UIButton *privacyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [privacyBtn setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        [privacyBtn addTarget:self action:@selector(privacyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _passwordField.rightView = privacyBtn;
        BOOL visible = [XHYPasswordVisible boolValue];
        _passwordField.secureTextEntry = visible;
        [privacyBtn setImage:[[UIImage imageNamed:visible?@"login_noDisplay":@"login_display"] imageMaskWithColor:MainColor] forState:UIControlStateNormal];
    }
    
    return _passwordField;
}

- (UIButton *)loginBtn{

    if (!_loginBtn) {
        
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.backgroundColor = [UIColor clearColor];
        _loginBtn.layer.cornerRadius = 6.0f;
        _loginBtn.layer.borderColor = MainColor.CGColor;
        _loginBtn.layer.borderWidth = 0.6f;
        [_loginBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
        [_loginBtn.titleLabel setTextColor:MainColor];
        [_loginBtn.titleLabel setFont:[XHYFontTool getDeaultFontBaseLanguageWithSize:20.0f]];
        [_loginBtn setTitleColor:BackgroudColor forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage imageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6f]] forState:UIControlStateHighlighted];
        [_loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.custom_acceptEventInterval = 1.5f;
    }
    
    return _loginBtn;
}

- (void)setupSubViews{
    
    //self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"loginBackgroud.jpg"].CGImage);
    self.view.layer.contents = (__bridge id _Nullable)([[UIImage imageNamed:@"loginBackgroud.jpg"] lightImage].CGImage);
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.accountField];
    [self.view addSubview:self.passwordField];
    [self.view addSubview:self.loginBtn];
    
    @JZWeakObj(self);
    
    if (IS_IPAD) {
        
        CGFloat logoSize = 200.0f;
        
        [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(selfWeak.view.mas_top).offset(84.0f);
            make.centerX.mas_equalTo(selfWeak.view.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(logoSize, logoSize));
        }];
        
        [self.accountField mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(selfWeak.logoImageView.mas_bottom).offset(20.0f);
            make.centerX.mas_equalTo(selfWeak.logoImageView.mas_centerX);
            make.width.mas_equalTo(logoSize * 3);
            make.height.mas_equalTo(50.0f);
        }];
        
        [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(selfWeak.accountField.mas_bottom).offset(20.0f);
            make.centerX.mas_equalTo(selfWeak.logoImageView.mas_centerX);
            make.width.mas_equalTo(selfWeak.accountField.mas_width);
            make.height.mas_equalTo(selfWeak.accountField.mas_height);
        }];
        
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(selfWeak.passwordField.mas_bottom).offset(20.0f);
            make.centerX.mas_equalTo(selfWeak.logoImageView.mas_centerX);
            make.width.mas_equalTo(selfWeak.passwordField.mas_width);
            make.height.mas_equalTo(selfWeak.passwordField.mas_height);
        }];
        
    }else if (IS_IPHONE){
        
        CGFloat logoSize = 100.0f;
        
        [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make){
            
            make.top.mas_equalTo(selfWeak.view.mas_top).offset(84.0f);
            make.centerX.mas_equalTo(selfWeak.view.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(logoSize, logoSize));
        }];
        
        [self.accountField mas_makeConstraints:^(MASConstraintMaker *make){
            
            make.top.mas_equalTo(selfWeak.logoImageView.mas_bottom).offset(spaceY);
            make.left.mas_equalTo(selfWeak.view.mas_left).offset(spaceX);
            make.right.mas_equalTo(selfWeak.view.mas_right).offset(-spaceX);
            make.centerX.mas_equalTo(selfWeak.logoImageView.mas_centerX);
            make.height.mas_equalTo(40.0f);
        }];
        
        [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make){
            
            make.top.mas_equalTo(selfWeak.accountField.mas_bottom).offset(spaceY);
            make.centerX.mas_equalTo(selfWeak.logoImageView.mas_centerX);
            make.width.mas_equalTo(selfWeak.accountField.mas_width);
            make.height.mas_equalTo(selfWeak.accountField.mas_height);
        }];
        
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make){
            
            make.top.mas_equalTo(selfWeak.passwordField.mas_bottom).offset(spaceY);
            make.centerX.mas_equalTo(selfWeak.logoImageView.mas_centerX);
            make.width.mas_equalTo(selfWeak.passwordField.mas_width);
            make.height.mas_equalTo(selfWeak.passwordField.mas_height);
        }];
    }
}

#pragma mark -----
#pragma mark ----- life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化 subViews
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if([currentAccount length]){
     
        self.accountField.text = currentAccount;
        self.passwordField.text = [SAMKeychain passwordForService:keychainService account:currentAccount];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
    [self.accountField hideHistroy];
}

/*
- (void)saveImageToAlbum{

    __block NSString *createdAssetId = nil;
    // 添加图片到【所有相片】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageNamed:@"loginBackgroud.jpg"]].placeholderForCreatedAsset.localIdentifier;
        
    } error:nil];
    // 在保存完毕后取出图片
    PHFetchResult<PHAsset *> *createdAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
    
    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHAssetCollection *tagertCollection = nil;
    
    for (PHAssetCollection *collection in collections) {
        
        if ([collection.localizedTitle isEqualToString:title]){
            
            tagertCollection = collection;
            break;
        }
    }
    
    if (tagertCollection) {
        
        NSError *error = nil;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:tagertCollection];
            [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
            
        } error:&error];
        
        // 保存结果
        if (error){
            
            [SVProgressHUD showErrorWithStatus:@"保存失败！"];
            
        } else {
            
            [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
        }
    }
}
*/

#pragma mark -----
#pragma mark ----- 登录按钮响应事件

- (void)loginBtnClick:(id)sender{
    
    /*
    NSURL *url = [NSURL URLWithString:@"sparxsmart://?wetChatID=123abct&registered=1"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        [[UIApplication sharedApplication] openURL:url];
        return;
    }
    */
    /*
     XMPP登录网关逻辑
     1、发送账号和密码 登录openFire服务器(根据xmpp协议组对应的JID)
     2、通过xmpp身份验证后，发送获取App所需的数据的请求(设备列表、联动数据、模式数据、设备自定义名、楼层数据等)
     3、接收各类信息
     4、接收到设备列表信息后，则表示为登录成功，跳转界面
     */
    [self.view endEditing:YES];
    
    //账号密码检查
    if (![self.accountField.text length]){
     
        [self.view makeToast:NSLocalizedString(@"User name cannot be empty", nil) duration:1.0F position:CSToastPositionCenter];
        [self.accountField shake:5.0F withDelta:1.5F completion:^{
     
            if ([self.accountField canResignFirstResponder]) {
     
                [self.accountField resignFirstResponder];
            }
        }];
        return;
    }
    
    if (![self.passwordField.text length]){
        
        [self.view makeToast:NSLocalizedString(@"Password cannot be empty", nil) duration:1.0F position:CSToastPositionCenter];
        [self.passwordField shake:5.0F withDelta:1.5F completion:^{
            
            if ([self.passwordField canResignFirstResponder]){
                
                [self.passwordField resignFirstResponder];
            }
        }];
        return;
    }
    
    //网络监测
    [GLobalRealReachability reachabilityWithBlock:^(ReachabilityStatus status){

        switch (status){
                
            case RealStatusUnknown:
            case RealStatusNotReachable:{
                
                [self.view makeToast:@"当前网络状态不可用" duration:2.0f position:CSToastPositionBottom];
            }
                break;
                
            case RealStatusViaWiFi:
            case RealStatusViaWWAN:{
                
                if (loginTimer){
                    
                    [loginTimer invalidate];
                    loginTimer = nil;
                }
                
                loginTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(xmppLoginTimeOut:) userInfo:nil repeats:NO];
                [loginTimer fireDate];
                
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
                [SVProgressHUD setMinimumDismissTimeInterval:20.0f];
                [SVProgressHUD setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8f]];
                [SVProgressHUD showImage:[[UIImage jk_animatedGIFNamed:@"loading"] jk_animatedImageByScalingAndCroppingToSize:CGSizeMake(50.0F, 50.0F)] status:NSLocalizedString(@"logining", nil)];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
                    
                    /*
                     XMPP互联网登录
                    */
                    
                    NSString *jid = [NSString stringWithFormat:@"c%@",self.accountField.text];
                    NSString *pwd = self.passwordField.text;
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CURRENTACCOUNT"];
                    [[NSUserDefaults standardUserDefaults] setObject:self.accountField.text forKey:@"CURRENTACCOUNT"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    XHYLoginManager *loginManager = [XHYLoginManager defaultLoginManager];
                    [loginManager connectXMPP:jid andPassword:pwd loginSuccess:^{
                        
                        [loginTimer invalidate];
                        loginTimer = nil;
                    
                        if ([SAMKeychain setPassword:self.passwordField.text forService:keychainService account:self.accountField.text]){
                            
                            [self.accountField synchronize];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [SVProgressHUD dismiss];
                            
                            XHYRootTabBarController *rootTabBarController = [[XHYRootTabBarController alloc] init];
                            XHYCenterViewController *centerViewControlelr = [[XHYCenterViewController alloc] init];
                            
                            MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:rootTabBarController leftDrawerViewController:centerViewControlelr];
                            [drawerController setShowsShadow:NO];
                            [drawerController setMaximumLeftDrawerWidth:0.8 * ScreenWidth];
                            [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar|MMOpenDrawerGestureModeBezelPanningCenterView];
                            [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
                            [self.navigationController presentViewController:drawerController animated:YES completion:^{
                                
                            }];
                        });
                        
                    } loginFailure:^(NSString *errorDescription){
                        
                        [loginTimer invalidate];
                        loginTimer = nil;
                        
                        [[XHYDataContainer defaultDataContainer] clearAllData];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [SVProgressHUD dismiss];
                            [self.view makeToast:errorDescription duration:2.0F position:CSToastPositionBottom];
                        });
                    }];
                    
                    /*
                     本地局域网登录
                    */
                    /*
                    XHYLoginManager *loginManager = [XHYLoginManager defaultLoginManager];
                    [loginManager LocalAreaNetwork:self.accountField.text andPassword:self.passwordField.text LoginSuccess:^{
                        
                        [loginTimer invalidate];
                        loginTimer = nil;
                        
                        if ([SAMKeychain setPassword:self.passwordField.text forService:keychainService account:self.accountField.text]){
                            
                            [self.accountField synchronize];
                        }
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [SVProgressHUD dismiss];
                            
                            XHYRootTabBarController *rootTabBarController = [[XHYRootTabBarController alloc] init];
                            XHYCenterViewController *centerViewControlelr = [[XHYCenterViewController alloc] init];
                            
                            MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:rootTabBarController leftDrawerViewController:centerViewControlelr];
                            [drawerController setShowsShadow:NO];
                            [drawerController setMaximumLeftDrawerWidth:0.8 * ScreenWidth];
                            [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar|MMOpenDrawerGestureModeBezelPanningCenterView];
                            [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
                            [self.navigationController presentViewController:drawerController animated:YES completion:^{
                                
                            }];
                        });
                        
                    } loginFailure:^(NSString *errorDescription) {
                        
                        [loginTimer invalidate];
                        loginTimer = nil;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [SVProgressHUD dismiss];
                            [self.view makeToast:errorDescription duration:1.0F position:CSToastPositionCenter];
                        });

                    }];
                    */
                    /*
                     安眼摄像头登录
                     */
                    /*
                     XHYLoginManager *loginManager = [XHYLoginManager defaultLoginManager];
                     [loginManager loginAnYan:self.accountField.text andPassword:self.passwordField.text LoginSuccess:^{
                     
                         [loginTimer invalidate];
                         loginTimer = nil;
                         
                         [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CURRENTACCOUNT"];
                         [[NSUserDefaults standardUserDefaults] setObject:self.accountField.text forKey:@"CURRENTACCOUNT"];
                         [[NSUserDefaults standardUserDefaults] synchronize];

                         if ([SAMKeychain setPassword:self.passwordField.text forService:keychainService account:self.accountField.text]){
                         
                             [self.accountField synchronize];
                         }
                         
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             
                             [SVProgressHUD dismiss];
                             
                             XHYRootTabBarController *rootTabBarController = [[XHYRootTabBarController alloc] init];
                             XHYCenterViewController *centerViewControlelr = [[XHYCenterViewController alloc] init];
                             
                             MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:rootTabBarController leftDrawerViewController:centerViewControlelr];
                             [drawerController setShowsShadow:NO];
                             [drawerController setMaximumLeftDrawerWidth:0.8 * ScreenWidth];
                             [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar|MMOpenDrawerGestureModeBezelPanningCenterView];
                             [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
                             [self.navigationController presentViewController:drawerController animated:YES completion:^{
                             
                             }];
                         });
                     
                     } loginFailure:^(NSString *errorDescription) {
                     
                         [loginTimer invalidate];
                         loginTimer = nil;
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                         
                             [SVProgressHUD dismiss];
                             [self.view makeToast:errorDescription duration:1.0F position:CSToastPositionCenter];
                         });
                     }];
                     */
                });
            }
                break;
                
            default:
                break;
        }
    }];
}

- (void)xmppLoginTimeOut:(NSTimer *)timer{

    [SVProgressHUD dismiss];
    [[XHYDataContainer defaultDataContainer] clearAllData];
    [[XHYLoginManager defaultLoginManager] disconnect];
    [self.view makeToast:@"登录超时,请检查网关是否在线" duration:1.0F position:CSToastPositionBottom];
    
    [loginTimer invalidate];
    loginTimer = nil;
}

#pragma mark -----
#pragma mark ----- 扫描按钮响应事件

- (void)scanBtnClick:(id)sender{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        
        // 获取摄像头失败
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction0 = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:alertAction0];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
        
    }else{
        
        // 获取摄像头成功
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
            if(granted){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    XHYQrScanViewController *scanViewController = [[XHYQrScanViewController alloc] init];
                    [self.navigationController pushViewController:scanViewController animated:YES];
                });
                
            }else {
                
                // 获取摄像头失败
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction0 = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertController addAction:alertAction0];
                [self.navigationController presentViewController:alertController animated:YES completion:nil];
            }
        }];
    }
}

#pragma mark -----
#pragma mark -----  显示或隐藏密码

- (void)privacyBtnClick:(id)sender{
    
    _passwordField.secureTextEntry = !_passwordField.secureTextEntry;
    UIButton *privacyBtn = (UIButton *)_passwordField.rightView;
    
    if (_passwordField.secureTextEntry){
        
        [privacyBtn setImage:[[UIImage imageNamed:@"login_noDisplay"] imageMaskWithColor:MainColor] forState:UIControlStateNormal];
        
    }else{
        
        [privacyBtn setImage:[[UIImage imageNamed:@"login_display"] imageMaskWithColor:MainColor] forState:UIControlStateNormal];
    }
    [[NSUserDefaults standardUserDefaults] setObject:_passwordField.secureTextEntry?@"YES":@"NO" forKey:@"XHYPASSWORDVISIBLE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -----
#pragma mark ----- UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{

    if ([textField isEqual:self.accountField]){
        
        [self.accountField showHistory];
        self.passwordField.text = nil;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{

    if ([textField isEqual:self.accountField]){
        
        if ([self.accountField.text length]){
            
            NSString *pwd = [SAMKeychain passwordForService:keychainService account:self.accountField.text];
            self.passwordField.text = pwd;
        }
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    if ([textField isEqual:self.accountField]){
        
        if ([self.accountField.text length]){
            
            NSString *pwd = [SAMKeychain passwordForService:keychainService account:self.accountField.text];
            self.passwordField.text = pwd;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if([textField isEqual:self.accountField]){
        
        if (string.length == 0) return YES;
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        
        if (existedLength - selectedLength + replaceLength > 16){
            
            [self.view makeToast:NSLocalizedString(@"Account is not more than 16 bytes", nil) duration:1.0f position:CSToastPositionCenter];
            return NO;
        }
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    return [textField resignFirstResponder];
}

@end

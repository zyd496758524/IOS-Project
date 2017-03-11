//
//  XHYAYCameraPlayViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYAYCameraPlayViewController.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"
#import "XHYCameraLiveView.h"
#import <YYDispatchQueuePool/YYDispatchQueuePool.h>
#import "SVProgressHUD.h"

@interface XHYAYCameraPlayViewController ()<UAnYanDelegate,XHYCameraLiveViewDelegate,AyMovieGLViewProtocol>
{
    AYClient_CameraChannelInfo *acci;
}

@property(nonatomic,strong) XHYCameraLiveView *playView;
@property(nonatomic,strong) UIActivityIndicatorView *loadingIndicatorView;
@property(nonatomic,strong) YYDispatchQueuePool *queuePool;

@end

@implementation XHYAYCameraPlayViewController

- (YYDispatchQueuePool *)queuePool{

    if (!_queuePool) {
        
        _queuePool = [[YYDispatchQueuePool alloc] initWithName:@"camera.live" queueCount:5 qos:NSQualityOfServiceBackground];
    }
    
    return _queuePool;
}

- (XHYCameraLiveView *)playView{

    if (!_playView) {
        
        _playView = [[XHYCameraLiveView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, 300.0f)];
        _playView.claritydelegate = self;
        _playView.delegate = self;
        _playView.backgroundColor = [UIColor blackColor];
    }
    
    return _playView;
}

- (void)setVideoFormat:(S_VIDEO_FORMAT*)foamat{
    
    NSLog(@"setVideoFormat");
}

- (void)renderVideo: (S_VIDEO_BUFFER *) frame{
    
    NSLog(@"renderVideo");
}

- (void)startRender{
    
    NSLog(@"startRender");
}

// 0 标清 1 高清
- (void)clarityValueSelect:(NSInteger)clarity{  }

- (UIActivityIndicatorView *)loadingIndicatorView{

    if (!_loadingIndicatorView) {
        
        _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingIndicatorView.center = CGPointMake(ScreenWidth/2, 300.0f/2);
    }
    
    return _loadingIndicatorView;
}

#pragma mark ----- Life Cycle

- (instancetype)initWithCameraInfo:(AYClient_Device_Baseinfo *)playCamera{

    if (self = [super init]) {
        
        _playCamera = playCamera;
        isPlaying = NO;
        [[UAnYanAPI sharedSingleton] setOemID:100];
        [[UAnYanAPI sharedSingleton] setCurrentDevice:playCamera];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _playCamera.device_name;
    
    [self.view addSubview:self.playView];
    [self.playView addSubview:self.loadingIndicatorView];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backCameraList)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    /*
    [[UAnYanAPI sharedSingleton] generateSignatureWithSecretID:<#(NSString *)#> secretKey:<#(NSString *)#> forInterval:<#(NSUInteger)#> returnSignature:<#(NSMutableString *)#>:];
    
    [[UAnYanAPI sharedSingleton] getDevicePlayInfoWithDeviceID:<#(NSString *)#> channelID:<#(NSUInteger)#> signature:<#(NSString *)#> returningDevInf:<#(AYClient_Device_Baseinfo *)#> andChannelInfo:<#(NSMutableArray *)#>]
    */
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if (_playCamera&&![UAnYanAPI sharedSingleton].isPlaying){
        
        [self tryBeginLivePlay];
    }
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----- 开始播放视频

- (void)tryBeginLivePlay{
    
    [self.loadingIndicatorView startAnimating];
    
    dispatch_queue_t queue = [self.queuePool queue];
    dispatch_async(queue, ^{
        
        if ([[UAnYanAPI sharedSingleton] checkDeviceOnlineWithSN:_playCamera.device_sn]){
            
            NSMutableArray *channel_list = [[NSMutableArray alloc] init];
            
            if ([[UAnYanAPI sharedSingleton] queryDeviceDetailInfoWithBaseInfo:_playCamera returningChannelInfo:channel_list]){
                
                if(!acci){
                    
                    acci = [[AYClient_CameraChannelInfo alloc] init];
                }
                
                NSLog(@"%@",channel_list);
                
                if ([channel_list count]) {
                    
                    AYClient_Device_Channelinfo *deviceChannelInfo = [channel_list objectAtIndex:0];
                    
                    acci.channel_index = deviceChannelInfo.channel_index;    //deviceChannelInfo.channel_index;//device_obj.
                    acci.device_id = _playCamera.device_sn;
                    
                    AYClient_RateSetting *bitRate = [_playCamera.rates objectAtIndex:0];
                    acci.upload_rate = bitRate.rate_value;
                    
                }else{
                    
                    acci.channel_index = 1;
                    acci.device_id = _playCamera.device_sn;
                    
                    //get bitrate from deviceBaseInfo
                    if([_playCamera.rates count] > 0){
                        
                        AYClient_RateSetting *bitRate = [_playCamera.rates objectAtIndex:0];
                        acci.upload_rate = bitRate.rate_value;
                        
                    }else{
                        
                        return ;
                    }
                }
                
                [self.playView setPlayMode:1];
                
                [UAnYanAPI sharedSingleton].delegate = self;
                
                if ([[UAnYanAPI sharedSingleton] startPlayWithCameraChannel:acci deviceToken:_playCamera.token playView:self.playView]){
                    
                }
            }
            
        }else{
            
            [self.playView makeToast:@"设备不在线" duration:1.0f position:CSToastPositionCenter];
        }
    });
}

#pragma mark ----- 退出 停止播放

- (void)backCameraList{
    
    UAnYanAPI *anyan = [UAnYanAPI sharedSingleton];
    
    if(anyan.isPlaying){
        
        dispatch_async([self.queuePool queue], ^{
            
            if ([[UAnYanAPI sharedSingleton] quitPlay]){
                
                [UAnYanAPI sharedSingleton].delegate = nil;
                
                isPlaying = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD dismiss];
                    acci = nil;
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        });
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark ----- UAnYanDelegate

- (BOOL)onMsgNotify:(NSInteger)statusCode msg:(NSString *)msg{

    return YES;
}
//播放状态
- (void)onPlaystateChange:(AYClient_CameraChannelInfo*)dc with_state:(int)state with_msg:(NSString*)msg{

    NSLog(@"onPlaystateChange --->%d %@",state,msg);
    NSLog(@"AYClient_CameraChannelInfo: channel_index--->%d,upload_rate--->%d,device_id--->%@",dc.channel_index,dc.upload_rate,dc.device_id);

    if (302 == state) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.playView.speedLabel setText:msg];
        });
        
    }else if (115 == state){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.playView makeToast:msg duration:1.0f position:CSToastPositionCenter];
        });
    }
}

- (void)startSession{

    NSLog(@"startSession");
}

- (void)sessionConnectFaild{

    NSLog(@"连接失败");
}

- (void)sessionLoginSuccess:(BOOL)isSuccess{

    if (isSuccess) {
        
        NSLog(@"登录成功");
        
    }else{
        
        NSLog(@"登录失败");
    }
}

- (void)sessionDisconnect{

    NSLog(@"回话断开连接");
}

//接受第一个关键帧，标志着有视频数据过来，加载完成。
- (void)sessionRecvFirstKeyFrameFrom:(AYClient_CameraChannelInfo*)cci{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.loadingIndicatorView isAnimating]) {
            
            [self.loadingIndicatorView stopAnimating];
        }
    });
}

//缺失 Token
- (void)hasNoToken{
    
    [[UAnYanAPI sharedSingleton] stopPlay];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.view makeToast:@"缺失Token" duration:1.0f position:CSToastPositionCenter];
    });
}

//强制断开
-(void)forceOffline{
    
    [[UAnYanAPI sharedSingleton] stopPlay];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.view makeToast:@"强制断开" duration:1.0f position:CSToastPositionCenter];
    });
}

//无视频数据
-(void)noVideoData{
    
    [[UAnYanAPI sharedSingleton] stopPlay];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.view makeToast:@"无视频数据" duration:1.0f position:CSToastPositionCenter];
    });
}

@end

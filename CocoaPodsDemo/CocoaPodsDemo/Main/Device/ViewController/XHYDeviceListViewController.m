//
//  XHYDeviceListViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/11.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYDeviceListViewController.h"
#import "YPTabBar.h"
#import "UIColor+JKHEX.h"
#import "UIImage+makeColor.m"
#import "PopViewLikeQQView.h"
#import "YBPopupMenu.h"
#import "XHYCameraLiveView.h"
#import "XHYSmartDeviceCell.h"
#import "XHYSmartDevice.h"
#import "XHYDeviceHelper.h"
#import "XHYFontTool.h"
#import "MJRefresh.h"
#import "XHYDeviceScrollView.h"
//添加设备
#import "XHYDeviceAddViewController.h"
//设备控制
#import "XHYLightControlViewController.h"
#import "XHYMusicControlViewController.h"
#import "XHYCurtainControlViewController.h"
#import "XHYCenterControlViewController.h"
#import "XHYSensorMsgViewController.h"

#import "XHYLocationManager.h"

@interface XHYDeviceListViewController ()<YPTabBarDelegate,XHYDeviceScrollViewDelegate,YBPopupMenuDelegate>{
    
    NSMutableArray *floorArray;
}
//顶部房间
@property(nonatomic,strong) NSMutableArray *roomNames;
@property(nonatomic,strong) NSMutableArray *roomArray;

@property(nonatomic,strong) UIView *roomView;
@property(nonatomic,strong) YPTabBar *roomTabBar;
@property(nonatomic,strong) XHYDeviceScrollView *scrollView;
//默认排序方式
@property(nonatomic,assign) NSComparator deviceSort;

@end

@implementation XHYDeviceListViewController

- (NSComparator)deviceSort{
    
    _deviceSort = ^(XHYSmartDevice *obj1, XHYSmartDevice *obj2){
        
        if ([obj1 getDefaultSortNum] > [obj2 getDefaultSortNum]){
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 getDefaultSortNum] < [obj2 getDefaultSortNum]){
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    return _deviceSort;
}

- (NSMutableArray *)roomNames{

    if (!_roomNames) {
        
         _roomNames = [NSMutableArray array];
    }
    
    return _roomNames;
}

- (NSMutableArray *)roomArray{

    if (!_roomArray) {
        
        _roomArray = [NSMutableArray array];
    }
    
    return _roomArray;
}

- (UIView *)roomView{

    if (!_roomView) {
     
        _roomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, 40.0f)];
        _roomView.backgroundColor = BackgroudColor;
        
        UIButton *changeFloorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [changeFloorBtn setImage:[[UIImage imageNamed:@"more"] imageMaskWithColor:MainColor] forState:UIControlStateNormal];
        [changeFloorBtn setBackgroundColor:[UIColor clearColor]];
        [changeFloorBtn addTarget:self action:@selector(changeFloorBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_roomView addSubview:changeFloorBtn];
        
        [changeFloorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.mas_equalTo(_roomView.mas_centerY);
            make.right.mas_equalTo(_roomView.mas_right).offset(-5);
            make.size.mas_equalTo(CGSizeMake(30.0f, 30.0f));
        }];
    }
    
    return _roomView;
}

- (YPTabBar *)roomTabBar{

    if (!_roomTabBar) {
        
        _roomTabBar = [[YPTabBar alloc] init];
        [_roomTabBar setFrame:CGRectMake(0.0f, 0.0f, ScreenWidth - 40.0f, 40.0f)];
        _roomTabBar.backgroundColor = [UIColor clearColor];
        _roomTabBar.itemTitleFont = [UIFont systemFontOfSize:18.0f];
        _roomTabBar.itemTitleColor = [UIColor grayColor];
        _roomTabBar.itemTitleSelectedColor = MainColor;
        [_roomTabBar setScrollEnabledAndItemFitTextWidthWithSpacing:16.0f];
        [_roomTabBar setItemSeparatorColor:[UIColor whiteColor] width:1.0f marginTop:2.0f marginBottom:2.0f];
        _roomTabBar.leftAndRightSpacing = 5.0f;
        _roomTabBar.delegate = self;
    }
    
    return _roomTabBar;
}

- (XHYDeviceScrollView *)scrollView{

    if (!_scrollView) {
        
        _scrollView = [[XHYDeviceScrollView alloc] init];
        _scrollView.delegate = self;
    }
    
    return _scrollView;
}

- (void)setupDeviceSubViews{

    [self.roomView addSubview:self.roomTabBar];
    
    [self.view addSubview:self.roomView];
    [self.view addSubview:self.scrollView];
    [self.roomView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_equalTo(40.0);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.mas_equalTo(self.roomView.mas_bottom);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

#pragma mark ----- Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self setupDeviceSubViews];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonItemAddDevice:)];

    if ([[XHYDataContainer defaultDataContainer].allFloorDataArray count]){
        
        NSDictionary *floorDict = [[XHYDataContainer defaultDataContainer].allFloorDataArray firstObject];
        NSString *currentFloor = [floorDict objectForKey:@"name"];
        [self displayAllDeviceForFloor:currentFloor];
    }
    
    @JZWeakObj(self);
    //设备工作状态改变
    [self xw_addNotificationForName:XHYDeviceWorkStatusChanged block:^(NSNotification * _Nonnull notification){
        
        NSDictionary *dic = [notification object];
        XHYSmartDevice *msgDevice = dic[@"device"];
        [selfWeak.scrollView reloadDeviceDetailInfo:msgDevice needStick:![XHYForbidStickDevice boolValue]];
    }];
    //账号楼层信息改变
    [self xw_addNotificationForName:XHYDeviceFloorInfoChanged block:^(NSNotification * _Nonnull notification){
        
        NSMutableArray *allFloorArray = [XHYDataContainer defaultDataContainer].allFloorDataArray;
        if ([allFloorArray count]){
            
            floorArray = [NSMutableArray arrayWithCapacity:[allFloorArray count]];
            [allFloorArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop){
                
                NSString *floorName = obj[@"name"];
                [floorArray addObject:floorName];
            }];
        }
        
        [selfWeak displayAllDeviceForFloor:floorArray[0]];
    }];
    //设备重命名
    [self xw_addNotificationForName:XHYDeviceNameChanged block:^(NSNotification * _Nonnull notification){
        
        if ([notification object]){
            
            XHYSmartDevice *tempSmartDevice = [notification object];
            [selfWeak.scrollView reloadDeviceDetailInfo:tempSmartDevice needStick:![XHYForbidStickDevice boolValue]];
        }
    }];
    
    [[XHYLocationManager shareInstance] startSystemLocationWithRes:^(CLLocation *loction, NSError *error){
        
        if (loction){
            
            NSLog(@"当前海拔 %f",loction.altitude);
            NSLog(@"行走速度 %f",loction.speed);
            NSLog(@"当前经纬度 %f %f",loction.coordinate.latitude,loction.coordinate.longitude);
            NSLog(@"当前楼层 %ld",loction.floor.level);
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----- 添加设备

- (void)rightBarButtonItemAddDevice:(id)sender{

    XHYDeviceAddViewController *deviceAddViewController = [[XHYDeviceAddViewController alloc] init];
    [deviceAddViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:deviceAddViewController animated:YES];
}

#pragma mark ----- 修改楼层

- (void)changeFloorBtnClick:(UIButton *)sender{

    NSMutableArray *allFloorArray = [XHYDataContainer defaultDataContainer].allFloorDataArray;
    if ([allFloorArray count]){
        
        floorArray = [NSMutableArray arrayWithCapacity:[allFloorArray count]];
        [allFloorArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop){
            
            NSString *floorName = obj[@"name"];
            [floorArray addObject:floorName];
        }];
        [YBPopupMenu showRelyOnView:sender titles:floorArray icons:nil menuWidth:120 delegate:self];
    }
}

#pragma mark - YBPopupMenuDelegate

- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu{
    
    [self displayAllDeviceForFloor:floorArray[index]];
}

//切换楼层
- (void)displayAllDeviceForFloor:(NSString *)floorName{

    if (![floorName length]){
        return;
    }
    
    NSArray *tempFloorArray = [XHYDataContainer defaultDataContainer].allFloorDataArray;
    [self.roomNames removeAllObjects];
    [self.roomArray removeAllObjects];
    
    [SVProgressHUD show];
    
    @JZWeakObj(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [tempFloorArray enumerateObjectsUsingBlock:^(NSDictionary *floorDict, NSUInteger idx, BOOL * _Nonnull stop){
            
            NSString *tempFloorName = floorDict[@"name"];
            
            if ([floorName isEqualToString:tempFloorName]) {
                
                NSArray *roomArray = floorDict[@"scences"];
                NSMutableArray *allDeviceArray = [NSMutableArray arrayWithCapacity:[roomArray count]];
                [roomArray enumerateObjectsUsingBlock:^(NSDictionary *roomDict, NSUInteger idx, BOOL * _Nonnull stop){
                    
                    [selfWeak.roomNames addObject:roomDict[@"scenceName"]];
                    NSArray *deviceArray = roomDict[@"mDevcieData"];
                    NSMutableArray *tempDeviceArray = [NSMutableArray arrayWithCapacity:[deviceArray count]];
                    [deviceArray enumerateObjectsUsingBlock:^(NSDictionary *devDic, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        NSString *IEEEAddr = devDic[@"iEEEAddr"];
                        NSString *endPoint = devDic[@"endPoint"];
                        XHYSmartDevice *tempSmartDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:IEEEAddr andEndPoint:endPoint];
                        if (tempSmartDevice){
                            
                            [tempDeviceArray addObject:tempSmartDevice];
                        }
                    }];
                    
                    NSMutableArray *sortDeviceArray = [NSMutableArray arrayWithArray:[tempDeviceArray sortedArrayUsingComparator:self.deviceSort]];
                    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:sortDeviceArray,roomDict[@"scenceName"],nil];
                    [allDeviceArray addObject:tempDict];
                }];
                
                selfWeak.roomArray = allDeviceArray;
                *stop = YES;
            }
        }];
        
        NSMutableArray *sortAllDeviceArray = [NSMutableArray arrayWithArray:[[XHYDataContainer defaultDataContainer].allSmartDeviceArray sortedArrayUsingComparator:self.deviceSort]];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:sortAllDeviceArray,@"全部",nil];
        [self.roomNames insertObject:@"全部" atIndex:0];
        [self.roomArray insertObject:dict atIndex:0];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            NSString *titleName = [NSString stringWithFormat:@"设备(%@)",floorName];
            self.navigationItem.title = titleName;
            
            self.scrollView.roomArray = self.roomArray;
            [self.scrollView setCurrentPage:0];
            [self.roomTabBar setSelectedItemIndex:0];
            [self.roomTabBar setTitles:self.roomNames];
            [self.roomTabBar setSelectedItemIndex:0];
        });
    });
}

#pragma mark ----- YPTabBarDelegate

- (void)yp_tabBar:(YPTabBar *)tabBar didSelectedItemAtIndex:(NSInteger)index{

    [self.scrollView setCurrentPage:index];
}

#pragma mark ----- XHYDeviceScrollViewDelegate

- (void)xhy_deviceScrollView:(XHYDeviceScrollView *)scrollView didScrollToItemAtIndex:(NSInteger)index{
    
    [self.roomTabBar setSelectedItemIndex:index];
}

- (void)xhy_deviceScrollView:(XHYDeviceScrollView *)scrollView didSelectItem:(XHYSmartDevice *)smartDecice{
    
    //摄像头
    if (smartDecice.deviceID == XHY_DEVICE_Camera){
        
        XHYCameraLiveView *cameraLiveView = [XHYCameraLiveView defaultCameraLiveView];
        [[UIApplication sharedApplication].keyWindow addSubview:cameraLiveView];
        return;
    }
    
    //窗帘控制界面
    if (smartDecice.deviceID == XHY_DEVICE_Curtain){
        
        XHYCurtainControlViewController *curtainControlViewController = [[XHYCurtainControlViewController alloc] init];
        curtainControlViewController.controlSmartDevice = smartDecice;
        [curtainControlViewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:curtainControlViewController animated:YES];
        return;
    }
    
    //开关、插座控制界面
    if (smartDecice.deviceID == XHY_DEVICE_Light||smartDecice.deviceID == XHY_DEVICE_Switch){
        
        XHYLightControlViewController *lightControlViewController = [[XHYLightControlViewController alloc] init];
        lightControlViewController.controlSmartDevice = smartDecice;
        [lightControlViewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:lightControlViewController animated:YES];
        return;
    }
    
    //XHYCenterControlViewController.h
    if (smartDecice.deviceID == XHY_DEVICE_CenterControlOne||smartDecice.deviceID == XHY_DEVICE_CenterControlTwo||smartDecice.deviceID == XHY_DEVICE_CenterControlThree){
        
        XHYCenterControlViewController *centerControlViewController = [[XHYCenterControlViewController alloc] init];
        centerControlViewController.controlSmartDevice = smartDecice;
        [centerControlViewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:centerControlViewController animated:YES];
        return;
    }

    //传感设备 显示消息记录
    if ([smartDecice isSensorDevice]){
        
        //XHYSensorMsgViewController
        XHYSensorMsgViewController *sensorMsgViewController = [[XHYSensorMsgViewController alloc] init];
        sensorMsgViewController.controlSmartDevice = smartDecice;
        [sensorMsgViewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:sensorMsgViewController animated:YES];
        return;
    }
    
    XHYMusicControlViewController *musicControlViewController = [[XHYMusicControlViewController alloc] init];
    musicControlViewController.controlSmartDevice = smartDecice;
    [musicControlViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:musicControlViewController animated:YES];
}

@end

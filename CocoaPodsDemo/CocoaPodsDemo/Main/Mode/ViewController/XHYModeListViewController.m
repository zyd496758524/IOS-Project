//
//  XHYModeListViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/11.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYModeListViewController.h"
#import "XHYModeListCell.h"
#import "XHYModeItem.h"
#import "XHYSmartDevice.h"
#import "XHYDeviceHelper.h"
#import "XHYSmartLinkage.h"
#import "AppDelegate.h"

#import "XHYModeEditViewController.h"
#import "PopViewLikeQQView.h"
#import "XHYDataContainer.h"

@interface XHYModeListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView *modeTableView;
@property(nonatomic,strong) NSMutableArray *modeArray;

@end

@implementation XHYModeListViewController

- (UITableView *)modeTableView{

    if (!_modeTableView){
        
        _modeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _modeTableView.backgroundColor = [UIColor clearColor];
        _modeTableView.dataSource = self;
        _modeTableView.delegate = self;
        _modeTableView.rowHeight = 92.0f;
        _modeTableView.estimatedRowHeight = 92.0f;
        _modeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _modeTableView;
}

- (NSMutableArray *)modeArray{

    if (!_modeArray){
    
        _modeArray = [NSMutableArray array];
    }
    
    return _modeArray;
}

#pragma mark ----- Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"模式";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonItemAddAction:)];
    
    [self.view addSubview:self.modeTableView];
    @JZWeakObj(self);
    [self.modeTableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(selfWeak.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self formattFormDataContainerDictDataToModeItemObject];
    [self.modeTableView reloadData];
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----

//将总数据源中模式的JSON数据转为 app内部逻辑处理中的 XHYModeItem 对象
- (void)formattFormDataContainerDictDataToModeItemObject{
    
    NSMutableArray *tempModeArray = [XHYDataContainer defaultDataContainer].allModeDataArray;
    
    if (![tempModeArray count]){
        
        return;
    }
    if ([self.modeArray count]){
        
        [self.modeArray removeAllObjects];
    }

    @JZWeakObj(self);
    
    [tempModeArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *modeDict, NSUInteger idx, BOOL * _Nonnull stop){
       
        XHYModeItem *indexModeItem = [[XHYModeItem alloc] init];
        indexModeItem.modeName = modeDict[@"modeName"];
        indexModeItem.modeID = modeDict[@"uniqueID"];
        
        //设备数组
        NSArray *indexDeviceArray = modeDict[@"mOrdinery"];
        NSMutableArray *deviceArray = [NSMutableArray array];
        if ([indexDeviceArray count]){
            
            [indexDeviceArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *deviceDict, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *iEEEAddr = deviceDict[@"iEEEAddr"];
                NSNumber *endPoint = deviceDict[@"endPoint"];
                NSString *actionValue = deviceDict[@"modeState"];
                
                XHYSmartDevice *indexDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:iEEEAddr andEndPoint:[NSString stringWithFormat:@"%@",endPoint]];
                
                if (indexDevice){
                    
                    NSMutableDictionary *modeDeviceDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:indexDevice,@"device",actionValue,@"linkedState",nil];
                    [deviceArray addObject:modeDeviceDict];
                }
            }];
        }
        indexModeItem.deviceArray = deviceArray;
        
        //联动数组
        NSArray *indexLinkageArray = modeDict[@"mLinkdata"];
        NSMutableArray *linkageArray = [NSMutableArray array];
        if ([indexLinkageArray count]){
            
            [indexLinkageArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *linkageDict, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *iEEEAddr = linkageDict[@"iEEEAddr"];
                NSString *endPoint = linkageDict[@"endPoint"];
                NSString *linkValue = linkageDict[@"linkedState"];
                
                XHYSmartDevice *indexDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:iEEEAddr andEndPoint:endPoint];
                if (indexDevice){
                    
                    XHYSmartLinkage *indexLinkage = [[XHYSmartLinkage alloc] init];
                    indexLinkage.linkageName = linkageDict[@"name"];
                    indexLinkage.triggerDevice = indexDevice;
                    indexLinkage.triggerValue = linkValue;
                    [linkageArray addObject:indexLinkage];
                }
            }];
        }
        
        indexModeItem.linkageArray = linkageArray;
        [selfWeak.modeArray insertObject:indexModeItem atIndex:0];
    }];
}

#pragma mark ----- Add action

- (void)rightBarButtonItemAddAction:(id)sender{

    [PopViewLikeQQView configCustomPopViewWithFrame:CGRectMake(ScreenWidth - 120.0f, 64.0f, 120.0f, 120.0f) imagesArr:nil dataSourceArr:@[@"添加联动",@"添加模式",@"添加联动"] anchorPoint:CGPointMake(1,0) seletedRowForIndex:^(NSInteger index) {
        
    } animation:YES timeForCome:0.3f timeForGo:0.3f];
}

#pragma mark ----- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.modeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    XHYModeListCell *modeListCell = [XHYModeListCell dequeueModeListCellFromRootTableView:tableView];
    XHYModeItem *indexMode = self.modeArray[indexPath.row];
    modeListCell.modeNameLabel.text = indexMode.modeName;
    
    /*
    AYClient_Device_Baseinfo *device_Baseinfo = self.modeArray[indexPath.row];
    modeListCell.modeNameLabel.text = device_Baseinfo.device_name;
    */
    /*
    NSString *modeIconName = nil;
    NSString *modeTypeValue = indexMode.modeID;
    
    if (0 == [modeTypeValue integerValue]){
        
        modeIconName = @"mode_indoor.png";
        
    }else if (1 == [modeTypeValue integerValue]){
        
        modeIconName = @"mode_outdoor.png";
        
    }else if (2 == [modeTypeValue integerValue]){
        
        modeIconName = @"mode_custom.png";
    }
    
    if ([modeIconName length]) {
        
        modeListCell.iconImageView.image = [UIImage imageNamed:modeIconName];
    }
    */
    modeListCell.iconImageView.image = [UIImage imageNamed:@"mode_indoor.png"];
    return modeListCell;
}

#pragma mark ----- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XHYModeItem *indexMode = self.modeArray[indexPath.row];
    XHYModeEditViewController *modeEditViewController = [[XHYModeEditViewController alloc] initWithModeEditType:ModeEdit];
    modeEditViewController.currentEditMode = indexMode;
    [modeEditViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:modeEditViewController animated:YES];
    
    /*
     AYClient_Device_Baseinfo *device_Baseinfo = self.modeArray[indexPath.row];
     XHYCameraLiveViewController *cameraLiveViewController = [[XHYCameraLiveViewController alloc] init];
     cameraLiveViewController.currentLiveDevice = device_Baseinfo;
     [cameraLiveViewController setHidesBottomBarWhenPushed:YES];
     [self.navigationController pushViewController:cameraLiveViewController animated:YES];
    */
}

@end

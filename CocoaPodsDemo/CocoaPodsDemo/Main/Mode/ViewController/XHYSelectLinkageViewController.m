//
//  XHYSelectLinkageViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYSelectLinkageViewController.h"
#import "Masonry.h"
#import "UIView+Toast.h"
#import "XHYLinkageSelectCell.h"
#import "XHYSmartLinkage.h"
#import "XHYLinkValueHelper.h"
#import "XHYDeviceHelper.h"

@interface XHYSelectLinkageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView *linkTableView;
@property(nonatomic,strong) NSMutableArray *allLinkageArray;
@property(nonatomic,strong) NSMutableArray *selectLinkageArray;

@end

@implementation XHYSelectLinkageViewController

- (UITableView *)linkTableView{
    
    if (!_linkTableView) {
        
        _linkTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _linkTableView.dataSource = self;
        _linkTableView.delegate = self;
        _linkTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _linkTableView.backgroundColor = [UIColor clearColor];
        _linkTableView.showsHorizontalScrollIndicator = NO;
        _linkTableView.showsVerticalScrollIndicator = NO;
        _linkTableView.rowHeight = 92.0f;
    }
    
    return _linkTableView;
}

- (NSMutableArray *)allLinkageArray{
    
    if (!_allLinkageArray) {
        
        _allLinkageArray = [NSMutableArray array];
    }
    
    return _allLinkageArray;
}

- (NSMutableArray *)selectLinkageArray{
    
    if (!_selectLinkageArray) {
        
        _selectLinkageArray = [NSMutableArray array];
    }
    
    return _selectLinkageArray;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"选择联动";
    @JZWeakObj(self);
    [self.view addSubview:self.linkTableView];
    [self.linkTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(selfWeak.view);
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelectLinkage:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(saveSelectLinkage:)];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [self formattFormDataContainerDictDataToSmartLinkageObject];
    [self.linkTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//将总数据源中的联动JSON数据 格式化为 对象数据
- (void)formattFormDataContainerDictDataToSmartLinkageObject{
    
    NSMutableArray *tempLinkageArray = [XHYDataContainer defaultDataContainer].allLinkageDataArray;
    
    if (![tempLinkageArray count]) {
        
        return;
    }
    
    if ([self.allLinkageArray count]) {
        
        [self.allLinkageArray removeAllObjects];
    }
    
    for (NSDictionary *dict in tempLinkageArray){
        
        XHYSmartLinkage *tempSmartLinkage = [[XHYSmartLinkage alloc] init];
        NSString *linkName = dict[@"device"][@"linkName"];
        tempSmartLinkage.linkageName = [linkName length]?linkName:dict[@"device"][@"name"];
        
        NSString *triggerIEEEAddr = dict[@"device"][@"iEEEAddr"];
        NSString *triggerEndPoint = dict[@"device"][@"endPoint"];
        XHYSmartDevice *triggerDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:triggerIEEEAddr andEndPoint:triggerEndPoint];
        
        //过滤 中控开关和遥控器的联动数据，不显示
        if (!triggerDevice||triggerDevice.deviceID == XHY_DEVICE_CenterControlTwo||triggerDevice.deviceID == XHY_DEVICE_CenterControlThree||triggerDevice.deviceID == XHY_DEVICE_SmartController){
            
            continue;
        }
        
        tempSmartLinkage.triggerDevice = triggerDevice;
        tempSmartLinkage.triggerValue = dict[@"device"][@"linkedState"];
        tempSmartLinkage.additionalValue = [NSString stringWithFormat:@"%@",dict[@"device"][@"extraValue"]];
        
        
        NSArray *responseDic = dict[@"mdevices"];
        NSMutableArray *responseArray = [NSMutableArray array];
        
        for (NSDictionary *tempDict in responseDic) {
            
            NSString *IEEEAddr = tempDict[@"iEEEAddr"];
            NSString *endPoint = tempDict[@"endPoint"];
            
            XHYSmartDevice *tempSmartDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:IEEEAddr andEndPoint:endPoint];
            if (tempSmartDevice) {
                
                NSMutableDictionary *linkDeviceDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempSmartDevice,@"device",tempDict[@"linkedState"],@"linkedState",nil];
                [responseArray addObject:linkDeviceDict];
            }
        }
        
        tempSmartLinkage.responseDeviceArray = responseArray;
        
        [self.allLinkageArray addObject:tempSmartLinkage];
        
        tempSmartLinkage = nil;
    }
}

- (void)cancelSelectLinkage:(id)sender{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSelectLinkage:(id)sender{
    
    if (![self.selectLinkageArray count]){
        
        [self.view makeToast:@"请选择设备" duration:1.0f position:CSToastPositionCenter];
        return;
    }
    
    if (self.linkageBlock){
        
        self.linkageBlock(self.selectLinkageArray);
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ----- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.allLinkageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XHYLinkageSelectCell *cell = [XHYLinkageSelectCell dequeueLinkageSelectCellFromRootTableView:tableView];
    XHYSmartLinkage *tempLinkage = self.allLinkageArray[indexPath.row];
    cell.linkName.text = tempLinkage.linkageName;
    
    NSString *triggerDeviceName = [tempLinkage.triggerDevice.customDeviceName length]? tempLinkage.triggerDevice.customDeviceName:tempLinkage.triggerDevice.deviceName;
    NSString *triggerString = [NSString stringWithFormat:@"%@ —— %@",triggerDeviceName,[XHYLinkValueHelper getActionDescriptionFromActionValue:tempLinkage.triggerValue]];
    
    [cell configDevice0Text:triggerString];
    
    if ([tempLinkage.responseDeviceArray count]) {
        
        NSDictionary *responDeviceDict = tempLinkage.responseDeviceArray[0];
        XHYSmartDevice *responDevice = responDeviceDict[@"device"];
        NSString *responValue = responDeviceDict[@"linkedState"];
        
        NSString *responDeviceName = [responDevice.customDeviceName length] ? responDevice.customDeviceName:responDevice.deviceName;
        NSString *responString = [NSString stringWithFormat:@"%@ —— %@",responDeviceName,[XHYLinkValueHelper getActionDescriptionFromActionValue:responValue]];
        cell.linkDevice1.text = responString;
    }
    
    [cell setLinkageSelect:[self.selectLinkageArray containsObject:tempLinkage]];
    return cell;
}

#pragma mark ----- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XHYSmartLinkage *tempLinkage = self.allLinkageArray[indexPath.row];
    
    if ([self.selectLinkageArray containsObject:tempLinkage]){
        
        [self.selectLinkageArray removeObject:tempLinkage];
        
    }else{
        
        [self.selectLinkageArray addObject:tempLinkage];
    }
    
    [self.linkTableView reloadData];
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

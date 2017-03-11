//
//  XHYLinkageManagerViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/1.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYLinkageManagerViewController.h"

#import "XHYDataContainer.h"
#import "XHYSmartLinkage.h"
#import "XHYLinkListCell.h"
#import "XHYDeviceHelper.h"
#import "XHYLinkValueHelper.h"
#import "XHYLinkageEditViewController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface XHYLinkageManagerViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property(nonatomic,strong) UITableView *linkageTableView;
@property(nonatomic,strong) NSMutableArray *linkageArray;

@end

@implementation XHYLinkageManagerViewController

- (UITableView *)linkageTableView{

    if (!_linkageTableView){
        
        _linkageTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _linkageTableView.dataSource = self;
        _linkageTableView.delegate = self;
        _linkageTableView.emptyDataSetSource = self;
        _linkageTableView.emptyDataSetDelegate = self;
        _linkageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _linkageTableView.backgroundColor = [UIColor clearColor];
        _linkageTableView.showsHorizontalScrollIndicator = NO;
        _linkageTableView.showsVerticalScrollIndicator = NO;
        _linkageTableView.rowHeight = 92.0f;
    }
    return _linkageTableView;
}

- (NSMutableArray *)linkageArray{

    if (!_linkageArray) {
        
        _linkageArray = [NSMutableArray array];
    }
    
    return _linkageArray;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"联动管理";
    [self.view addSubview:self.linkageTableView];
    @JZWeakObj(self);
    [self.linkageTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(selfWeak.view);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLinkage:)];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self formattFormDataContainerDictDataToSmartLinkageObject];
    [self.linkageTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//将总数据源中的联动JSON数据 格式化为 对象数据
- (void)formattFormDataContainerDictDataToSmartLinkageObject{

    NSMutableArray *tempLinkageArray = [XHYDataContainer defaultDataContainer].allLinkageDataArray;
    
    if(![tempLinkageArray count]){
        
        return;
    }
    
    if ([self.linkageArray count]){
        
        [self.linkageArray removeAllObjects];
    }
    
    for (NSDictionary *dict in tempLinkageArray){
        
        XHYSmartLinkage *tempSmartLinkage = [[XHYSmartLinkage alloc] init];
        NSString *linkName = dict[@"device"][@"linkName"];
        tempSmartLinkage.linkageName = [linkName length]?linkName:dict[@"device"][@"name"];
        
        NSString *triggerIEEEAddr = dict[@"device"][@"iEEEAddr"];
        NSNumber *triggerEndPoint = dict[@"device"][@"endPoint"];
        
        XHYSmartDevice *triggerDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:triggerIEEEAddr andEndPoint:[NSString stringWithFormat:@"%@",triggerEndPoint]];
        
        /*
         过滤掉中控开关和智能遥控器的联动数据
        */
        
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
        [self.linkageArray addObject:tempSmartLinkage];
        tempSmartLinkage = nil;
    }
}

#pragma mark ----- 添加联动

- (void)addLinkage:(id)sender{

    XHYLinkageEditViewController *linkageEditViewController = [[XHYLinkageEditViewController alloc] initWithLinkageManagerType:LinkageAdd];
    XHYSmartLinkage *addSmartLinkage = [[XHYSmartLinkage alloc] init];
    addSmartLinkage.responseDeviceArray = [NSMutableArray array];
    linkageEditViewController.editSmartLinkage = addSmartLinkage;
    [self.navigationController pushViewController:linkageEditViewController animated:YES];
}

#pragma mark -----
#pragma mark ----- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.linkageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifiler = @"XHYLinkListCell";
    XHYLinkListCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifiler];
    if (!cell) {
        
        cell = [[XHYLinkListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifiler];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    XHYSmartLinkage *tempLinkage = self.linkageArray[indexPath.row];
    cell.linkName.text = tempLinkage.linkageName;
    
    NSString *triggerDeviceName = [tempLinkage.triggerDevice.customDeviceName length]? tempLinkage.triggerDevice.customDeviceName:tempLinkage.triggerDevice.deviceName;
    NSString *triggerString = [NSString stringWithFormat:@"%@[%@]",triggerDeviceName,[XHYLinkValueHelper getActionDescriptionFromActionValue:tempLinkage.triggerValue]];
    
    [cell configDevice0Text:triggerString];
    if ([tempLinkage.responseDeviceArray count]){
        
        NSDictionary *responDeviceDict = tempLinkage.responseDeviceArray[0];
        XHYSmartDevice *responDevice = responDeviceDict[@"device"];
        NSString *responValue = responDeviceDict[@"linkedState"];
        NSString *responDeviceName = [responDevice.customDeviceName length] ? responDevice.customDeviceName:responDevice.deviceName;
        NSString *responString = [NSString stringWithFormat:@"%@[%@]",responDeviceName,[XHYLinkValueHelper getActionDescriptionFromActionValue:responValue]];
        cell.linkDevice1.text = responString;
    }
    return cell;
}

#pragma mark -----
#pragma mark ----- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        @JZWeakObj(self);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提醒" message:@"删除后，只能重新添加，确定删除？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction *replacelBtn = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //删除总数据源中此联动数据 并同步到云端
            XHYSmartLinkage *linkage = [self.linkageArray objectAtIndex:indexPath.row];
            NSMutableArray *tempDeleteArray = [NSMutableArray array];
            [[XHYDataContainer defaultDataContainer].allLinkageDataArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop){
                
                NSString *triggerIEEEAddr = dict[@"device"][@"iEEEAddr"];
                NSString *triggerEndPoint = dict[@"device"][@"endPoint"];
                NSString *triggerValue = dict[@"device"][@"linkedState"];
                
                XHYSmartDevice *tempDict = [[XHYSmartDevice alloc] initWithZigBeeIEEEAddr:triggerIEEEAddr andEndPoint:triggerEndPoint];
                if ([tempDict isEqual:linkage.triggerDevice] && [triggerValue isEqualToString:linkage.triggerValue]){
                    
                    [tempDeleteArray addObject:dict];
                    //*stop = YES;
                }
            }];
            
            if ([tempDeleteArray count]){
                
                [[XHYDataContainer defaultDataContainer].allLinkageDataArray removeObjectsInArray:tempDeleteArray];
                [[XHYDataContainer defaultDataContainer] startSyncLinkageData];
            }
            tempDeleteArray = nil;
            
            //将此联动 从模式中删除
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                
                __block BOOL isChange = NO;
                
                @try {
                    
                    [[XHYDataContainer defaultDataContainer].allModeDataArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop){
                        
                        NSMutableArray *mLinkdata = dic[@"mLinkdata"];
                        
                        [mLinkdata enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *statedic, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            NSString *iEEEAddr = statedic[@"iEEEAddr"];
                            NSNumber *endPoint = statedic[@"endPoint"];
                            NSString *linkedState = statedic[@"linkedState"];
                            
                            XHYSmartDevice *tempDict = [[XHYSmartDevice alloc] initWithZigBeeIEEEAddr:iEEEAddr andEndPoint:[NSString stringWithFormat:@"%@",endPoint]];
                            if([tempDict isEqual:linkage.triggerDevice] && [linkedState isEqualToString:linkage.triggerValue]){
                                
                                [mLinkdata removeObject:statedic];
                                isChange = YES;
                            }
                            
                            tempDict = nil;
                        }];
                    }];
                    
                } @catch (NSException *exception) {
                    
                    NSLog(@"%@",exception.reason);
                    
                } @finally {
                    
                    if (isChange) {
                        
                        [[XHYDataContainer defaultDataContainer] startSyncModeData];
                    }
                }
            });

            [selfWeak.linkageArray removeObjectAtIndex:indexPath.row];
            [selfWeak.linkageTableView beginUpdates];
            [selfWeak.linkageTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [selfWeak.linkageTableView reloadData];
            [selfWeak.linkageTableView endUpdates];
        }];
        
        [alertController addAction:cancelBtn];
        [alertController addAction:replacelBtn];
        [self presentViewController:alertController animated:YES completion:^{}];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XHYSmartLinkage *tempLinkage = self.linkageArray[indexPath.row];
    XHYLinkageEditViewController *linkageEditViewController = [[XHYLinkageEditViewController alloc] initWithLinkageManagerType:LinkageEdit];
    linkageEditViewController.editSmartLinkage = tempLinkage;
    
    [self.navigationController pushViewController:linkageEditViewController animated:YES];
}

#pragma mark -----
#pragma mark ----- DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    
    NSString *text = @"没有任何联动呢";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    
    NSString *text = @"点击添加";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
}


#pragma mark -----
#pragma mark ----- DZNEmptyDataSetDelegate

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView{
    
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView{
    
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    
    return NO;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{

    XHYLinkageEditViewController *linkageEditViewController = [[XHYLinkageEditViewController alloc] initWithLinkageManagerType:LinkageAdd];
    XHYSmartLinkage *addSmartLinkage = [[XHYSmartLinkage alloc] init];
    addSmartLinkage.responseDeviceArray = [NSMutableArray array];
    linkageEditViewController.editSmartLinkage = addSmartLinkage;
    
    [self.navigationController pushViewController:linkageEditViewController animated:YES];
}

@end

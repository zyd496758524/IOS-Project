//
//  XHYLinkageEditViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/16.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYLinkageEditViewController.h"

#import "XHYLinkNameEditCell.h"
#import "XHYLinkEditCell.h"
#import "XHYLinkValueHelper.h"
#import "XHYDeviceHelper.h"
#import "XHYFooterAddView.h"
#import "ValuePickerView.h"
#import "XHYLinkValueHelper.h"

#import "UIView+Toast.h"
#import "XHYSelectDeviceViewController.h"

@interface XHYLinkageEditViewController ()<UITableViewDataSource,UITableViewDelegate,XHYLinkEditCellDelegate,ValuePickerViewDataSource,XHYFooterAddViewDelegate>{
    
    LinkageMangaerType _managerType;
    NSArray *actionValueArray;
}

@property(nonatomic,strong) UITableView *linkEditTableView;

@end

@implementation XHYLinkageEditViewController

- (UITableView *)linkEditTableView{

    if (!_linkEditTableView){
     
        _linkEditTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _linkEditTableView.backgroundColor = [UIColor clearColor];
        _linkEditTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _linkEditTableView.dataSource = self;
        _linkEditTableView.delegate = self;
    }
    return _linkEditTableView;
}

- (instancetype)initWithLinkageManagerType:(LinkageMangaerType)managerType{

    if (self = [super init]) {
        
        _managerType = managerType;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.linkEditTableView];
    [self.linkEditTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveLinkageData:)];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    switch (_managerType) {
            
        case LinkageEdit:
            self.navigationItem.title = @"联动编辑";
            break;
        case LinkageAdd:
            self.navigationItem.title = @"添加联动";
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveLinkageData:(id)sender{

    [self.view endEditing:YES];
    
    XHYLinkNameEditCell *cell = [self.linkEditTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *tempLinkName = nil;
    if ([cell.linkNameField.text length]){
        
        tempLinkName = cell.linkNameField.text;
    }
    if (![tempLinkName length]) {
        
        tempLinkName = [self.editSmartLinkage.triggerDevice.customDeviceName length]? self.editSmartLinkage.triggerDevice.customDeviceName:self.editSmartLinkage.triggerDevice.deviceName;
    }
    self.editSmartLinkage.linkageName = tempLinkName;
    
    if (!self.editSmartLinkage.triggerDevice.deviceID) {
        
        [self.view makeToast:@"请选择触发设备" duration:1.0f position:CSToastPositionCenter];
        return;
    }
    
    if (![self.editSmartLinkage.responseDeviceArray count]) {
        
        [self.view makeToast:@"请选择响应设备" duration:1.0f position:CSToastPositionCenter];
        return;
    }
    
    __block BOOL isExist = NO;
    __block NSUInteger existIndex;
    @JZWeakObj(self);
    
    [[XHYDataContainer defaultDataContainer].allLinkageDataArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *triggerIEEEAddr = obj[@"device"][@"iEEEAddr"];
        NSString *triggerEndPoint = obj[@"device"][@"endPoint"];
        XHYSmartDevice *triggerDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:triggerIEEEAddr andEndPoint:triggerEndPoint];
        NSString *linkValue = obj[@"device"][@"linkedState"];
        if ([selfWeak.editSmartLinkage.triggerDevice isEqual:triggerDevice] && [selfWeak.editSmartLinkage.triggerValue isEqualToString:linkValue]) {
            
            isExist = YES;
            existIndex = idx;
            *stop = YES;
        }
    }];
    
    if (isExist) {
     
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"冲突提醒" message:@"已存在相同的联动，是否替换" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction *replacelBtn = [UIAlertAction actionWithTitle:@"替换" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[XHYDataContainer defaultDataContainer].allLinkageDataArray removeObjectAtIndex:existIndex];
            [[XHYDataContainer defaultDataContainer].allLinkageDataArray addObject:[self.editSmartLinkage formatterSendLinkage]];
            [[XHYDataContainer defaultDataContainer] startSyncLinkageData];
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alertController addAction:cancelBtn];
        [alertController addAction:replacelBtn];
        
        [self presentViewController:alertController animated:YES completion:^{}];
        
    }else{
    
        [[XHYDataContainer defaultDataContainer].allLinkageDataArray addObject:[self.editSmartLinkage formatterSendLinkage]];
        [[XHYDataContainer defaultDataContainer] startSyncLinkageData];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark ----- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (0 == section) {
        
        return 1;
        
    }else if ( 1 == section){
    
        return 1;
        
    }else{
    
        return [self.editSmartLinkage.responseDeviceArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (!indexPath.section) {
        
        static NSString *editNameIdentifier = @"XHYLinkNameEditCell";
        
        XHYLinkNameEditCell *cell = [tableView dequeueReusableCellWithIdentifier:editNameIdentifier];
        
        if (!cell) {
            
            cell = [[XHYLinkNameEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editNameIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.linkEditName.text = @"联动名称";
        if (_managerType == LinkageEdit){
            
            cell.linkNameField.text = self.editSmartLinkage.linkageName;
        }
        
        return cell;
        
    }else{
        
        static NSString *linkIdentifier = @"XHYLinkEditCell";
        XHYLinkEditCell *cell = [tableView dequeueReusableCellWithIdentifier:linkIdentifier];
        
        if (!cell) {
            
            cell = [[XHYLinkEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:linkIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (1 == indexPath.section) {
            
            [cell setEditForDelete:NO];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            cell.deviceName.text = [self.editSmartLinkage.triggerDevice.customDeviceName length]?self.editSmartLinkage.triggerDevice.customDeviceName:self.editSmartLinkage.triggerDevice.deviceName;
            cell.actionName.text = [XHYLinkValueHelper getActionDescriptionFromActionValue:self.editSmartLinkage.triggerValue];
            
            return cell;
            
        }else{
            
            [cell setEditForDelete:YES];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            NSMutableDictionary *dic = self.editSmartLinkage.responseDeviceArray[indexPath.row];
            XHYSmartDevice *tempSmartDevice = dic[@"device"];
            NSString *chainValue = dic[@"linkedState"];
            
            cell.deviceName.text = [tempSmartDevice.customDeviceName length]?tempSmartDevice.customDeviceName:tempSmartDevice.deviceName;
            cell.actionName.text = [XHYLinkValueHelper getActionDescriptionFromActionValue:chainValue];
            
            return cell;
        }
    }
}

#pragma mark ----- UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    if (0 == section) {
        
        return nil;
        
    }else if(1 == section){
        
        return @"触发设备";
        
    }else{
        
        return @"响应设备";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    if (2 == section) {
        
        return 80.0f;
    }
    
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    if (2 == section) {
        
        XHYFooterAddView *footerView = [XHYFooterAddView dequeueFooterAddViewFromRootTableView:tableView];
        footerView.delegate = self;
        footerView.tag = section;
        return footerView;
        
    }else{
    
        return nil;
    }
}

#pragma mark ----- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}

#pragma mark ----- XHYFooterAddViewDelegate
//添加被动设备
- (void)XHYFooterAddViewAddBtnClick:(XHYFooterAddView *)footerView{
    
    XHYSelectDeviceViewController *selectDeviceViewController = [[XHYSelectDeviceViewController alloc] initWithDeviceSelectType:XHYDeviceSelect_Multi];
    selectDeviceViewController.deviceBlock = ^(NSArray *selectDeviceArray){
        
        if (![selectDeviceArray count]) {
            
            return;
        }
        
        [selectDeviceArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(XHYSmartDevice *obj,NSUInteger idx, BOOL * _Nonnull stop) {
            
            __block BOOL isExist = NO;
            
            if ([self.editSmartLinkage.responseDeviceArray count]){
                
                [self.editSmartLinkage.responseDeviceArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSDictionary *responDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    XHYSmartDevice *tempSmart = responDevice[@"device"];
                    
                    if ([tempSmart isEqual:obj]) {
                        
                        isExist = YES;
                    }
                }];
            }
            
            if (isExist) {
                
            }else{
                
                NSMutableDictionary *linkDeviceDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:obj,@"device",[obj getAllActionValueForCenterControl:NO][0],@"linkedState",nil];
                [self.editSmartLinkage.responseDeviceArray addObject:linkDeviceDict];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_linkEditTableView beginUpdates];
            [_linkEditTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            [_linkEditTableView endUpdates];
        });
    };
    
    UINavigationController *selectNavi = [[UINavigationController alloc] initWithRootViewController:selectDeviceViewController];
    [self.navigationController presentViewController:selectNavi animated:YES completion:nil];
}

#pragma mark ----- XHYLinkEditCellDelegate

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell didDeleteLink:(NSIndexPath *)indexPath{

    [self.view endEditing:YES];
    
    [self.editSmartLinkage.responseDeviceArray removeObjectAtIndex:indexPath.row];
    
    [self.linkEditTableView beginUpdates];
    [self.linkEditTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.linkEditTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.linkEditTableView endUpdates];
}

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell actionDidSelectLink:(NSIndexPath *)indexPath{
    
    [self.view endEditing:YES];
    
    if (1 == indexPath.section) {
        
        if (self.editSmartLinkage.triggerDevice){
            
            NSArray *actionArray = [self.editSmartLinkage.triggerDevice getAllActionValueForCenterControl:NO];
            NSString *defaultAction = self.editSmartLinkage.triggerValue;
            
            if ([actionArray count]) {
                
                actionValueArray = [NSMutableArray arrayWithArray:actionArray];
                
                ValuePickerView *valuePickerView = [[ValuePickerView alloc] init];
                valuePickerView.datasource = self;
                valuePickerView.dataSource = actionValueArray;
                
                if ([actionValueArray containsObject:defaultAction]){
                    
                    valuePickerView.defaultStr = defaultAction;
                }
                
                @JZWeakObj(self);
                valuePickerView.valueDidSelect = ^(NSString *value){
                    
                    selfWeak.editSmartLinkage.triggerValue = value;
                    
                    //判断触发事件是否需要输入阈值
                    if ([XHYLinkValueHelper needAdditionalValueForActionValue:value]){
                        
                        NSLog(@"需要额外条件 输入阈值");
                        
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"阈值条件" message:@"需要额外条件 输入阈值" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            
                        }];
                        
                        UIAlertAction *replacelBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        
                        [alertController addAction:cancelBtn];
                        [alertController addAction:replacelBtn];
                        
                        [self presentViewController:alertController animated:YES completion:^{}];
                    }
                    
                    [selfWeak.linkEditTableView beginUpdates];
                    [selfWeak.linkEditTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [selfWeak.linkEditTableView endUpdates];
                };
                
                [valuePickerView show];
                
            }else{
                
            }
        }
        
    }else{
    
        NSDictionary *dict = self.editSmartLinkage.responseDeviceArray[indexPath.row];
        
        XHYSmartDevice *data = dict[@"device"];
        NSArray *actionArray = [data getAllActionValueForCenterControl:NO];
        NSString *defaultAction = dict[@"linkedState"];
        
        if ([actionArray count]) {
            
            actionValueArray = [NSMutableArray arrayWithArray:actionArray];
            
            ValuePickerView *valuePickerView = [[ValuePickerView alloc] init];
            valuePickerView.datasource = self;
            valuePickerView.dataSource = actionArray;
            
            if ([actionArray containsObject:defaultAction]){
                
                valuePickerView.defaultStr = defaultAction;
            }
            
            @JZWeakObj(self);
            valuePickerView.valueDidSelect = ^(NSString *value){
                
                NSArray * stateArr = [value componentsSeparatedByString:@"/"];
                
                NSMutableDictionary *indexDict = self.editSmartLinkage.responseDeviceArray[indexPath.row];
                indexDict[@"linkedState"] = [stateArr firstObject];
                
                [selfWeak.linkEditTableView beginUpdates];
                [selfWeak.linkEditTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [selfWeak.linkEditTableView endUpdates];
            };
            
            [valuePickerView show];
            
        }else{
            
        }
    }
}

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell deviceDidSelectLink:(NSIndexPath *)indexPath{

    [self.view endEditing:YES];
    
    if (1 == indexPath.section && _managerType == LinkageAdd) {
        
        XHYSelectDeviceViewController *selectDeviceViewController = [[XHYSelectDeviceViewController alloc] initWithDeviceSelectType:XHYDeviceSelect_Radio];
        
        @JZWeakObj(self);
        selectDeviceViewController.deviceBlock = ^(NSArray *selectDeviceArray){
        
            XHYSmartDevice *tempTriggerDevice = [selectDeviceArray firstObject];
            selfWeak.editSmartLinkage.triggerDevice = tempTriggerDevice;
            selfWeak.editSmartLinkage.triggerValue = [[tempTriggerDevice getAllActionValueForCenterControl:NO] firstObject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [selfWeak.linkEditTableView beginUpdates];
                [selfWeak.linkEditTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [selfWeak.linkEditTableView endUpdates];
            });
        };
        
        UINavigationController *selectNavi = [[UINavigationController alloc] initWithRootViewController:selectDeviceViewController];
        [self.navigationController presentViewController:selectNavi animated:YES completion:nil];
    }
}

#pragma mark ----- ValuePickerViewDataSource

- (NSString *)valuePickerView:(ValuePickerView *)valuePickerView titleForRow:(NSInteger)row{

    NSString *value = actionValueArray[row];
    return [XHYLinkValueHelper getActionDescriptionFromActionValue:value];
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

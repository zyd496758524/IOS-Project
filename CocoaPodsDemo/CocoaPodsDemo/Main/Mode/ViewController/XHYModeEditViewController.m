//
//  XHYModeEditViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/23.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYModeEditViewController.h"
#import "Masonry.h"

#import "XHYHeaderExpandView.h"
#import "XHYFooterAddView.h"

#import "XHYLinkEditCell.h"
#import "XHYLinkNameEditCell.h"

#import "XHYSmartDevice.h"
#import "XHYSmartLinkage.h"
#import "XHYLinkValueHelper.h"

#import "ValuePickerView.h"

#import "XHYSelectDeviceViewController.h"
#import "XHYSelectLinkageViewController.h"

@interface XHYModeEditViewController ()<UITableViewDataSource,UITableViewDelegate,XHYLinkEditCellDelegate,ValuePickerViewDataSource,XHYHeaderExpandViewDelegate,XHYFooterAddViewDelegate>{
    ModeMangaerType _currentModeEidtType;
    
    NSArray *deviceValueArray;
}

@property(nonatomic,strong) UITableView *modeEditTableView;

@end

@implementation XHYModeEditViewController

- (UITableView *)modeEditTableView{
    
    if (!_modeEditTableView){
        
        _modeEditTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _modeEditTableView.backgroundColor = [UIColor clearColor];
        _modeEditTableView.dataSource = self;
        _modeEditTableView.delegate = self;
        _modeEditTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _modeEditTableView;
}

- (instancetype)initWithModeEditType:(ModeMangaerType)modeEditType{

    if (self = [super init]) {
        
        _currentModeEidtType = modeEditType;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.modeEditTableView];
    @JZWeakObj(self);
    [self.modeEditTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(selfWeak.view);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveModeData:)];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    switch (_currentModeEidtType) {
            
        case ModeEdit:
            self.navigationItem.title = @"模式编辑";
            break;
            
        case ModeAdd:
            self.navigationItem.title = @"添加模式";
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveModeData:(id)sender{

}

#pragma mark ----- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (0 == section) {
        
        return 1;
        
    }else if (1 == section){
        //设备区
        return [self.currentEditMode.deviceArray count];
        
    }else if (2 == section){
        //联动区
        return [self.currentEditMode.linkageArray count];
        
    }else if (3 == section){
        
        return 5;
        
    }else if (4 == section){
    
        return 3;
        
    }else{
    
        return 0;
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
        
        cell.linkEditName.text = @"模式名称";
        cell.linkNameField.text = self.currentEditMode.modeName;
        
        return cell;
        
    }else{
        
        static NSString *linkIdentifier = @"XHYLinkEditCell";
        XHYLinkEditCell *cell = [tableView dequeueReusableCellWithIdentifier:linkIdentifier];
        
        if (!cell) {
            
            cell = [[XHYLinkEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:linkIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (1 == indexPath.section) {
            
            [cell setEditForDelete:YES];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            NSMutableDictionary *dic = self.currentEditMode.deviceArray[indexPath.row];
            
            XHYSmartDevice *tempSmartDevice = dic[@"device"];
            NSString *chainValue = dic[@"linkedState"];
            
            cell.deviceName.text = [tempSmartDevice.customDeviceName length]?tempSmartDevice.customDeviceName:tempSmartDevice.deviceName;
            cell.actionName.text = [XHYLinkValueHelper getActionDescriptionFromActionValue:chainValue];
            return cell;
            
        }else if (2 == indexPath.section) {
            
            [cell setEditForDelete:YES];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            XHYSmartLinkage *tempLinkage = self.currentEditMode.linkageArray[indexPath.row];
            
            cell.deviceName.text = [tempLinkage.triggerDevice.customDeviceName length]?tempLinkage.triggerDevice.customDeviceName:tempLinkage.triggerDevice.deviceName;
            
            cell.actionName.text = [XHYLinkValueHelper getActionDescriptionFromActionValue:tempLinkage.triggerValue];
            
            return cell;
            
        }{
            
            [cell setEditForDelete:YES];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            /*
            NSMutableDictionary *dic = self.editSmartLinkage.responseDeviceArray[indexPath.row];
            
            XHYSmartDevice *tempSmartDevice = dic[@"device"];
            NSString *chainValue = dic[@"linkedState"];
            
            cell.deviceName.text = [tempSmartDevice.customDeviceName length]?tempSmartDevice.customDeviceName:tempSmartDevice.deviceName;
            cell.actionName.text = [XHYLinkValueHelper getActionDescriptionFromActionValue:chainValue];
            */
            
            return cell;
        }
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!section) {
        
        return nil;
    }
    
    XHYHeaderExpandView *headerView = [XHYHeaderExpandView dequeueHeaderExpandViewFromRootTableView:tableView];
    headerView.delegate = self;
    
//    XHYFloorItem *tempFloor = self.floorArray[section];
//    headerView.titleLabel.text = tempFloor.floorName;
//    headerView.isExpend = tempFloor.isExpend;
//    headerView.isSelect = tempFloor.isSelect;
    
    headerView.tag = section;
    [headerView beginSelect:tableView.editing];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    if (!section) {
        
        return nil;
    }
    
    XHYFooterAddView *footerView = [XHYFooterAddView dequeueFooterAddViewFromRootTableView:tableView];
    footerView.delegate = self;
    footerView.tag = section;
    return footerView;
}

#pragma mark ----- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (!section) {
        
        return 20.0f;
        
    }else{
    
        return 60.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    if (!section) {
        
        return 20.0f;
        
    }else{
        
        return 80.0f;
    }
}

#pragma mark ----- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    [self.view endEditing:YES];
}

#pragma mark ----- XHYFooterAddViewDelegate

- (void)XHYFooterAddViewAddBtnClick:(XHYFooterAddView *)footerView{

    NSInteger section = footerView.tag;
    
    if (1 == section) {
        
        XHYSelectDeviceViewController *selectDeviceViewController = [[XHYSelectDeviceViewController alloc] initWithDeviceSelectType:XHYDeviceSelect_Multi];
        
        @JZWeakObj(self);
        
        selectDeviceViewController.deviceBlock = ^(NSArray *selectDeviceArray){
            
            if (![selectDeviceArray count]) {
                
                return;
            }
            
            [selectDeviceArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(XHYSmartDevice *obj,NSUInteger idx, BOOL * _Nonnull stop) {
                
                __block BOOL isExist = NO;
                
                if ([selfWeak.currentEditMode.deviceArray count]){
                    
                    [selfWeak.currentEditMode.deviceArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *responDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        XHYSmartDevice *tempSmart = responDevice[@"device"];
                        
                        if ([tempSmart isEqual:obj]) {
                            
                            isExist = YES;
                        }
                    }];
                }
                
                if (isExist) {
                    
                }else{
                    
                    NSMutableDictionary *linkDeviceDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:obj,@"device",[obj getAllActionValueForCenterControl:NO][0],@"linkedState",nil];
                    [selfWeak.currentEditMode.deviceArray addObject:linkDeviceDict];
                }
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [selfWeak.modeEditTableView beginUpdates];
                [selfWeak.modeEditTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
                [selfWeak.modeEditTableView endUpdates];
            });
        };
        
        UINavigationController *selectNavi = [[UINavigationController alloc] initWithRootViewController:selectDeviceViewController];
        [self.navigationController presentViewController:selectNavi animated:YES completion:nil];
        
    }else if (2 == section){
        
        XHYSelectLinkageViewController *selectLinkageViewController = [[XHYSelectLinkageViewController alloc] init];
        
        @JZWeakObj(self);
        
        selectLinkageViewController.linkageBlock = ^(NSArray *selectLinkageArray){
            
            if (![selectLinkageArray count]) {
                
                return;
            }
            
            [selectLinkageArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(XHYSmartLinkage *obj,NSUInteger idx, BOOL * _Nonnull stop) {
                
                __block BOOL isExist = NO;
                
                if ([selfWeak.currentEditMode.linkageArray count]){
                    
                    [selfWeak.currentEditMode.linkageArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XHYSmartLinkage *smartLinkage, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if ([smartLinkage isEqual:obj]){
                            
                            isExist = YES;
                        }
                    }];
                }
                
                if (isExist) {
                    
                }else{
                    
                    [selfWeak.currentEditMode.linkageArray addObject:obj];
                }
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [selfWeak.modeEditTableView beginUpdates];
                [selfWeak.modeEditTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
                [selfWeak.modeEditTableView endUpdates];
            });
        };
        
        UINavigationController *selectNavi = [[UINavigationController alloc] initWithRootViewController:selectLinkageViewController];
        [self.navigationController presentViewController:selectNavi animated:YES completion:nil];
    }
}

#pragma mark ----- XHYHeaderExpandViewDelegate

- (void)XHYHeaderExpandViewExpend:(XHYHeaderExpandView *)headerView{

}

- (void)XHYHeaderExpandView:(XHYHeaderExpandView *)headerView didSelectBtn:(BOOL)select{

}

#pragma mark ----- XHYLinkEditCellDelegate

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell didDeleteLink:(NSIndexPath *)indexPath{
    
    if (1 == indexPath.section) {
        
        [self.currentEditMode.deviceArray removeObjectAtIndex:indexPath.row];
        
    }else if ( 2 == indexPath.section){
        
        [self.currentEditMode.linkageArray removeObjectAtIndex:indexPath.row];
    }
    
    [self.modeEditTableView beginUpdates];
    [self.modeEditTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.modeEditTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.modeEditTableView endUpdates];
}

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell actionDidSelectLink:(NSIndexPath *)indexPath{

    if (1 == indexPath.section) {
        
        NSMutableDictionary *dict = self.currentEditMode.deviceArray[indexPath.row];;
        
        XHYSmartDevice *data = dict[@"device"];
        NSArray *actionArray = [data getAllActionValueForCenterControl:NO];
        NSString *defaultAction = dict[@"linkedState"];
        
        if ([actionArray count]) {
            
            deviceValueArray = [NSMutableArray arrayWithArray:actionArray];
            
            ValuePickerView *valuePickerView = [[ValuePickerView alloc] init];
            valuePickerView.datasource = self;
            valuePickerView.dataSource = actionArray;
            
            if ([actionArray containsObject:defaultAction]){
                
                valuePickerView.defaultStr = defaultAction;
            }
            
            @JZWeakObj(self);
            valuePickerView.valueDidSelect = ^(NSString *value){
                
                NSArray * stateArr = [value componentsSeparatedByString:@"/"];
                dict[@"linkedState"] = [stateArr firstObject];
                
                [selfWeak.modeEditTableView beginUpdates];
                [selfWeak.modeEditTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [selfWeak.modeEditTableView endUpdates];
            };
            
            [valuePickerView show];
            
        }else{
            
        }
    }
}

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell deviceDidSelectLink:(NSIndexPath *)indexPath{

}

#pragma mark ----- ValuePickerViewDataSource

- (NSString *)valuePickerView:(ValuePickerView *)valuePickerView titleForRow:(NSInteger)row{
    
    NSString *value = [deviceValueArray objectAtIndex:row];
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

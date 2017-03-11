//
//  XHYCenterControlEditViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/21.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYCenterControlEditViewController.h"

#import "XHYSmartLinkage.h"

#import "XHYLinkNameEditCell.h"
#import "XHYLinkEditCell.h"
#import "XHYLinkValueHelper.h"
#import "XHYDeviceHelper.h"

#import "ValuePickerView.h"
#import "XHYLinkValueHelper.h"

#import "XHYSelectDeviceViewController.h"

@interface XHYCenterControlEditViewController ()<UITableViewDataSource,UITableViewDelegate,ValuePickerViewDataSource,XHYLinkEditCellDelegate>{

    NSArray *actionValueArray;
}

@property(nonatomic,strong) UITableView *centerTableView;

@property(nonatomic,strong) XHYSmartLinkage *firstCenterLinkage;
@property(nonatomic,strong) XHYSmartLinkage *secondCenterLinkage;
@property(nonatomic,strong) XHYSmartLinkage *thirdCenterLinkage;

@end

@implementation XHYCenterControlEditViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (0 == section) {
        
        return 1;
        
    }else if ( 1 == section){
        
        return [self.firstCenterLinkage.responseDeviceArray count];
        
    }else if ( 2 == section){
        
        return [self.secondCenterLinkage.responseDeviceArray count];
        
    }else if ( 3 == section){
        
        return [self.thirdCenterLinkage.responseDeviceArray count];
        
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
        
        cell.linkEditName.text = @"联动名称";
        return cell;
        
    }else{
        
        static NSString *linkIdentifier = @"XHYLinkEditCell";
        XHYLinkEditCell *cell = [tableView dequeueReusableCellWithIdentifier:linkIdentifier];
        
        if (!cell) {
            
            cell = [[XHYLinkEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:linkIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (1 == indexPath.section){
            
            [cell setEditForDelete:YES];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            NSMutableDictionary *dic = self.firstCenterLinkage.responseDeviceArray[indexPath.row];
            
            XHYSmartDevice *tempSmartDevice = dic[@"device"];
            NSString *chainValue = dic[@"linkedState"];
            
            cell.deviceName.text = [tempSmartDevice.customDeviceName length]?tempSmartDevice.customDeviceName:tempSmartDevice.deviceName;
            cell.actionName.text = [XHYLinkValueHelper getActionDescriptionFromActionValue:chainValue];
            
            return cell;
            
        }else if (2 == indexPath.section){
            
            [cell setEditForDelete:YES];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            NSMutableDictionary *dic = self.secondCenterLinkage.responseDeviceArray[indexPath.row];
            
            XHYSmartDevice *tempSmartDevice = dic[@"device"];
            NSString *chainValue = dic[@"linkedState"];
            
            cell.deviceName.text = [tempSmartDevice.customDeviceName length]?tempSmartDevice.customDeviceName:tempSmartDevice.deviceName;
            cell.actionName.text = [XHYLinkValueHelper getActionDescriptionFromActionValue:chainValue];
            
            return cell;

        }else if (3 == indexPath.section){
            
            [cell setEditForDelete:YES];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            NSMutableDictionary *dic = self.thirdCenterLinkage.responseDeviceArray[indexPath.row];
            
            XHYSmartDevice *tempSmartDevice = dic[@"device"];
            NSString *chainValue = dic[@"linkedState"];
            
            cell.deviceName.text = [tempSmartDevice.customDeviceName length]?tempSmartDevice.customDeviceName:tempSmartDevice.deviceName;
            cell.actionName.text = [XHYLinkValueHelper getActionDescriptionFromActionValue:chainValue];
            
            return cell;

        }else{
        
            return nil;
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
    
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (2 == section) {
        
        return 50.0f;
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (2 == section) {
        
        UIView *addView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, 50.0f)];
        addView.backgroundColor = [UIColor redColor];
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setFrame:CGRectMake(ScreenWidth - 50.0f, 10.0f, 30.0f, 30.0f)];
        [addBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addResponDevice:) forControlEvents:UIControlEventTouchUpInside];
        [addView addSubview:addBtn];
        
        return addView;
        
    }else{
        
        return nil;
    }
}

//添加被动设备

- (void)addResponDevice:(id)sender{
    
    XHYSelectDeviceViewController *selectDeviceViewController = [[XHYSelectDeviceViewController alloc] initWithDeviceSelectType:XHYDeviceSelect_Multi];
    
    /*
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
                
                NSMutableDictionary *linkDeviceDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:obj,@"device",[obj getAllActionValue][0],@"linkedState",nil];
                [self.editSmartLinkage.responseDeviceArray addObject:linkDeviceDict];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_linkEditTableView beginUpdates];
            [_linkEditTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            [_linkEditTableView endUpdates];
        });
    };
    */
    
    UINavigationController *selectNavi = [[UINavigationController alloc] initWithRootViewController:selectDeviceViewController];
    [self.navigationController presentViewController:selectNavi animated:YES completion:nil];
}

#pragma mark ----- XHYLinkEditCellDelegate

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell didDeleteLink:(NSIndexPath *)indexPath{
    
    if (1 == indexPath.section) {
        
        [self.firstCenterLinkage.responseDeviceArray removeObjectAtIndex:indexPath.row];
        
    }else if (2 == indexPath.section){
        
        [self.secondCenterLinkage.responseDeviceArray removeObjectAtIndex:indexPath.row];
        
    }else if (3 == indexPath.section){
        
        [self.thirdCenterLinkage.responseDeviceArray removeObjectAtIndex:indexPath.row];
    }
    
    [self.centerTableView beginUpdates];
    [self.centerTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.centerTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self.centerTableView endUpdates];
}

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell actionDidSelectLink:(NSIndexPath *)indexPath{
    
    XHYSmartLinkage *editLinkage = nil;
    
    if (1 == indexPath.section) {
    
        editLinkage = self.firstCenterLinkage;
        
    }else if (2 == indexPath.section){
        
        editLinkage = self.secondCenterLinkage;
        
    }else if (3 == indexPath.section){
        
        editLinkage = self.thirdCenterLinkage;
    }
    
    NSDictionary *dict = editLinkage.responseDeviceArray[indexPath.row];
    XHYSmartDevice *data = dict[@"device"];
    
    if (!data) {
        
        return;
    }
    
    NSArray *actionArray = [data getAllActionValueForCenterControl:YES];
    NSString *defaultAction = dict[@"linkedState"];
    
    if ([actionArray count]) {
        
        actionValueArray = [NSArray arrayWithArray:actionArray];
        
        ValuePickerView *valuePickerView = [[ValuePickerView alloc] init];
        valuePickerView.datasource = self;
        valuePickerView.dataSource = actionArray;
        
        if ([actionArray containsObject:defaultAction]){
            
            valuePickerView.defaultStr = defaultAction;
        }
        
        @JZWeakObj(self);
        valuePickerView.valueDidSelect = ^(NSString *value){
            
            NSArray * stateArr = [value componentsSeparatedByString:@"/"];
            
            NSMutableDictionary *indexDict = editLinkage.responseDeviceArray[indexPath.row];
            indexDict[@"linkedState"] = [stateArr firstObject];
            
            [selfWeak.centerTableView beginUpdates];
            [selfWeak.centerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [selfWeak.centerTableView endUpdates];
        };
        
        [valuePickerView show];
        
    }else{
        
    }

}

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell deviceDidSelectLink:(NSIndexPath *)indexPath{
    
    /*
    if (1 == indexPath.section) {
        
        XHYSelectDeviceViewController *selectDeviceViewController = [[XHYSelectDeviceViewController alloc] initWithDeviceSelectType:XHYDeviceSelect_Radio];
        
        @JZWeakObj(self);
        
        selectDeviceViewController.deviceBlock = ^(NSArray *selectDeviceArray){
            
            XHYSmartDevice *tempTriggerDevice = [selectDeviceArray firstObject];
            selfWeak.editSmartLinkage.triggerDevice = tempTriggerDevice;
            selfWeak.editSmartLinkage.triggerValue = [[tempTriggerDevice getAllActionValue] firstObject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [selfWeak.linkEditTableView beginUpdates];
                [selfWeak.linkEditTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [selfWeak.linkEditTableView endUpdates];
            });
            
        };
        
        UINavigationController *selectNavi = [[UINavigationController alloc] initWithRootViewController:selectDeviceViewController];
        [self.navigationController presentViewController:selectNavi animated:YES completion:nil];
    }
    */
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

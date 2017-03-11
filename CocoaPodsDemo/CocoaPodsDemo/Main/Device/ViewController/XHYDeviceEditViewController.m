//
//  XHYDeviceEditViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYDeviceEditViewController.h"
#import "Masonry.h"

#import "XHYDeviceHelper.h"
#import "XHYRoomSelectView.h"
#import "XHYLinkNameEditCell.h"
#import "XHYRoomInfoCell.h"

#import "XHYEditDeviceNameViewController.h"

@interface XHYDeviceEditViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    UIButton *deleteDeviceBtn;
}

@property(nonatomic,strong) UITableView *deviceInfoTableView;
@property(nonatomic,strong) UIView *deleteDeviceView;
@property(nonatomic,strong) NSArray *deviceManagerItemArray;

@end

@implementation XHYDeviceEditViewController

- (UITableView *)deviceInfoTableView{

    if (!_deviceInfoTableView) {
    
        _deviceInfoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _deviceInfoTableView.dataSource = self;
        _deviceInfoTableView.delegate = self;
        _deviceInfoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _deviceInfoTableView.backgroundColor = [UIColor clearColor];
        _deviceInfoTableView.rowHeight = 60.0f;
    }
    return _deviceInfoTableView;
}

- (UIView *)deleteDeviceView{

    if (!_deleteDeviceView){
    
        _deleteDeviceView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, 100.0f)];
        _deleteDeviceView.backgroundColor = [UIColor clearColor];
        
        deleteDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteDeviceBtn.backgroundColor = [UIColor redColor];
        deleteDeviceBtn.layer.cornerRadius = 6.0f;
        [deleteDeviceBtn setTitle:NSLocalizedString(@"remove device", nil) forState:UIControlStateNormal];
        [deleteDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteDeviceBtn addTarget:self action:@selector(deleteDeviceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_deleteDeviceView addSubview:deleteDeviceBtn];
        [deleteDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make){
           
            make.centerX.mas_equalTo(_deleteDeviceView.mas_centerX);
            make.centerY.mas_equalTo(_deleteDeviceView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(ScreenWidth - 2 * 30, 40.0f));
        }];
    }
    return _deleteDeviceView;
}

- (NSArray *)deviceManagerItemArray{

    if (!_deviceManagerItemArray){

        NSArray *item0 = [NSArray arrayWithObjects:NSLocalizedString(@"device custom name", nil),NSLocalizedString(@"current location", nil),nil];
        NSArray *item1 = [NSArray arrayWithObjects:NSLocalizedString(@"detailed information", nil),NSLocalizedString(@"FAQ", nil),nil];
        _deviceManagerItemArray = [NSArray arrayWithObjects:item0,item1,nil];
    }
    return _deviceManagerItemArray;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"device information", nil);
    self.deviceInfoTableView.tableFooterView = self.deleteDeviceView;
    [self.view addSubview:self.deviceInfoTableView];
    @JZWeakObj(self);
    [self.deviceInfoTableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(selfWeak.view);
    }];
    [self xw_addNotificationForName:XHYDeviceNameChanged block:^(NSNotification * _Nonnull notification){
        
        XHYSmartDevice *tempSmartDevice = [notification object];
        selfWeak.editSmartDevice.customDeviceName = tempSmartDevice.customDeviceName;
        [selfWeak.deviceInfoTableView beginUpdates];
        [selfWeak.deviceInfoTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [selfWeak.deviceInfoTableView endUpdates];
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deleteDeviceBtnClick:(id)sender{

    UIAlertController *deleteAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Remove equipment instructions", nil) message:NSLocalizedString(@"Device removed, such as reuse, need to add back into the net, whether to remove?", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction0 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){}];
    
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"remove", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self sendDeleteCommandToGateway];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD show];
            });
        });
        @JZWeakObj(self);
        [self xw_addNotificationForName:XHYDeviceDelete block:^(NSNotification * _Nonnull notification){
            
            [SVProgressHUD dismiss];
            [selfWeak xw_removeNotificationForName:XHYDeviceDelete];
            [selfWeak.navigationController popToRootViewControllerAnimated:YES];
        }];
    }];
    
    [deleteAlertController addAction:alertAction0];
    [deleteAlertController addAction:alertAction1];
    [self presentViewController:deleteAlertController animated:YES completion:^{}];
}

//发送删除命令到网关
- (void)sendDeleteCommandToGateway{
    
    NSDictionary *deleteDict = [NSDictionary dictionaryWithObjectsAndKeys:self.editSmartDevice.IEEEAddr,@"iEEEAddr",[NSNumber numberWithUnsignedChar:self.editSmartDevice.endPoint],@"endPoint",nil];
    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:deleteDict],@"devices",nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:tempDict options:0 error:nil];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    char buffer[50*1024] = {0};
    const char *des = [result UTF8String];
    sendDeviceDelCmd((char*)des, (int)strlen(des), buffer);
    NSString *tempStr = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendDeviceControlMsg:tempStr];
}

- (void)saveDeviceFloorInfoData:(id)sender{
    
    [self.view endEditing:YES];
}

#pragma mark -----  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return [self.deviceManagerItemArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.deviceManagerItemArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *roomCellIdentifiler = @"XHYRoomInfoCell";
    XHYRoomInfoCell *roomInfoCell = [tableView dequeueReusableCellWithIdentifier:roomCellIdentifiler];
    if (!roomInfoCell){
        
        roomInfoCell = [[XHYRoomInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roomCellIdentifiler];
        roomInfoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    roomInfoCell.roomTitleLabel.text = self.deviceManagerItemArray[indexPath.section][indexPath.row];
    if (!indexPath.section){
        
        if (!indexPath.row){
            
            roomInfoCell.roomLabel.text = [self.editSmartDevice.customDeviceName length] ? self.editSmartDevice.customDeviceName:self.editSmartDevice.deviceName;
        }else{
            
            roomInfoCell.roomLabel.text = [self.editSmartDevice getFloorRoomDescription];
        }
        
    }else{
        
        roomInfoCell.roomLabel.text = nil;
    }
    return roomInfoCell;
}

#pragma mark -----  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!indexPath.section && !indexPath.row){
        
        XHYEditDeviceNameViewController *editDeviceNameViewController = [[XHYEditDeviceNameViewController alloc] init];
        editDeviceNameViewController.editNameSmartDevice = self.editSmartDevice;
        [self.navigationController pushViewController:editDeviceNameViewController animated:YES];
    }
    
    if (!indexPath.section && indexPath.row == 1){
        
        [self.view endEditing:YES];
        XHYRoomSelectView *roomSelectView = [[XHYRoomSelectView alloc] init];
        roomSelectView.dataSource = [XHYDataContainer defaultDataContainer].allFloorDataArray;
        [roomSelectView setDefaultStr:[self.editSmartDevice getFloorRoomDescription]];
        @JZWeakObj(self);
        [roomSelectView setRoomDidSelect:^(NSString *roomName){
            NSLog(@"%@",roomName);
            if ([roomName length]){
                
                NSArray *tempArray = [roomName componentsSeparatedByString:@"/"];
                if ([tempArray count] == 2){
                    
                    NSString *tempFloor = tempArray[0];
                    NSString *tempRoom = tempArray[1];
                    if ([tempFloor length]&&[tempRoom length]){
                        
                        //如果设备已有房间信息 则删除房间信息
                        if ([selfWeak.editSmartDevice getFloorRoomDescription]){
                            
                            [[XHYDataContainer defaultDataContainer].allFloorDataArray enumerateObjectsUsingBlock:^(NSDictionary *floorDict, NSUInteger idx, BOOL * _Nonnull stop){
                                
                                NSString *floorName = floorDict[@"name"];
                                
                                if ([floorName isEqualToString:selfWeak.editSmartDevice.floor]){
                                    
                                    NSArray *roomeArray = floorDict[@"scences"];
                                    [roomeArray enumerateObjectsUsingBlock:^(NSDictionary *roomDict, NSUInteger idx, BOOL * _Nonnull stop){
                                        
                                        NSString *roomName = roomDict[@"scenceName"];
                                        if ([roomName isEqualToString:selfWeak.editSmartDevice.room]){
                                            
                                            NSMutableArray *deviceArray = roomDict[@"mDevcieData"];
                                            [deviceArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *deviceDict, NSUInteger idx, BOOL * _Nonnull stop) {
                                                
                                                NSString *IEEEAddr = deviceDict[@"iEEEAddr"];
                                                NSString *endPoint = deviceDict[@"endPoint"];
                                                
                                                XHYSmartDevice *tempDevice = [XHYDeviceHelper findSmartDeviceIEEEAddr:IEEEAddr andEndPoint:endPoint];
                                                
                                                if ([tempDevice isEqual:selfWeak.editSmartDevice]){
                                                    
                                                    [deviceArray removeObject:deviceDict];
                                                    *stop = YES;
                                                }
                                            }];
                                        }
                                    }];
                                    
                                }
                            }];
                        }
                        
                        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:selfWeak.editSmartDevice.IEEEAddr,@"iEEEAddr",[NSNumber numberWithChar:selfWeak.editSmartDevice.endPoint],@"endPoint", nil];
                        //往总数据源中更新信息
                        [[XHYDataContainer defaultDataContainer].allFloorDataArray enumerateObjectsUsingBlock:^(NSDictionary *floorDict, NSUInteger idx, BOOL * _Nonnull stop){
                            
                            NSString *floorName = floorDict[@"name"];
                            if ([floorName isEqualToString:tempFloor]){
                                
                                NSArray *roomeArray = floorDict[@"scences"];
                                [roomeArray enumerateObjectsUsingBlock:^(NSDictionary *roomDict, NSUInteger idx, BOOL * _Nonnull stop){
                                    
                                    NSString *roomName = roomDict[@"scenceName"];
                                    if ([roomName isEqualToString:tempRoom]){
                                        
                                        NSMutableArray *deviceArray = roomDict[@"mDevcieData"];
                                        [deviceArray addObject:tempDict];
                                        *stop = YES;
                                    }
                                }];
                            }
                        }];
                        
                        selfWeak.editSmartDevice.floor = tempFloor;
                        selfWeak.editSmartDevice.room = tempRoom;
                        
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            
                            //同步至云服务器
                            [[XHYDataContainer defaultDataContainer] startSyncFloorData];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //发送广播消息 设备列表首页刷新
                                [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceFloorInfoChanged object:nil];
                                [selfWeak.deviceInfoTableView beginUpdates];
                                [selfWeak.deviceInfoTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                                [selfWeak.deviceInfoTableView endUpdates];
                            });
                        });
                    }
                }
            }
        }];
        [roomSelectView show];
    }
}

#pragma mark ----- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}

@end

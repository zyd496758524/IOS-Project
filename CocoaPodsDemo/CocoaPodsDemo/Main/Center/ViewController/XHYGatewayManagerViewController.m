//
//  XHYGatewayManagerViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/1.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYGatewayManagerViewController.h"
#import "XHYRoomInfoCell.h"

@interface XHYGatewayManagerViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView *gateWayTableView;
@property(nonatomic,strong) NSArray *gateWayManagerItemArray;

@end

@implementation XHYGatewayManagerViewController

- (UITableView *)gateWayTableView{

    if (!_gateWayTableView){
        
        _gateWayTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _gateWayTableView.backgroundColor = [UIColor clearColor];
        _gateWayTableView.dataSource = self;
        _gateWayTableView.delegate = self;
        _gateWayTableView.rowHeight = 60.0f;
        _gateWayTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    return _gateWayTableView;
}

- (NSArray *)gateWayManagerItemArray{

    if (!_gateWayManagerItemArray){
        
        NSArray *item0 = [NSArray arrayWithObjects:@"网关版本",@"网关升级",@"详细信息",nil];
        NSArray *item1 = [NSArray arrayWithObjects:@"修改密码",@"网关复位",@"网关重启",nil];
        _gateWayManagerItemArray = [NSArray arrayWithObjects:item0,item1,nil];
    }
    return _gateWayManagerItemArray;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"网关管理";
    @JZWeakObj(self);
    [self.view addSubview:self.gateWayTableView];
    [self.gateWayTableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.mas_equalTo(selfWeak.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return [self.gateWayManagerItemArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.gateWayManagerItemArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *roomCellIdentifiler = @"XHYRoomInfoCell";
    XHYRoomInfoCell *roomInfoCell = [tableView dequeueReusableCellWithIdentifier:roomCellIdentifiler];
    if (!roomInfoCell){
        
        roomInfoCell = [[XHYRoomInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roomCellIdentifiler];
        roomInfoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    roomInfoCell.roomTitleLabel.text = self.gateWayManagerItemArray[indexPath.section][indexPath.row];
    if (!indexPath.section&&!indexPath.row){
        
        roomInfoCell.roomLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:currentAccount];
        roomInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else{
        
        roomInfoCell.roomLabel.text = nil;
        roomInfoCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return roomInfoCell;
}

#pragma mark -----  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.section && 1 == indexPath.row){
        
        [self checkServiceGatewayVersion];
    }
    
    if (1 == indexPath.section && 1 == indexPath.row){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"网关复位将清除所有的设备信息,是否复位?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        }];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"复位" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            [self sendCommandForGatewayRestorate];
        }];
        
        [alertController addAction:action0];
        [alertController addAction:action1];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
}

//检查服务器内固件版本

- (void)checkServiceGatewayVersion{

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/smartlife/gateway/update.md5",mainIP]]];
    [SVProgressHUD show];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if ([data length]){
            
            NSError *serialError = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serialError];
            
            if (dict&&!serialError){
                
                NSNumber *main = dict[@"main"];
                NSNumber *sec = dict[@"sec"];
                NSNumber *thr = dict[@"thr"];
                NSString *versionGateway = [NSString stringWithFormat:@"v%d.%.2d.%.2d",main.intValue,sec.intValue,thr.intValue];
                NSLog(@"服务器上网关固件版本为 %@",versionGateway);
                NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:currentAccount];
                //用当前的版本与服务器上版本对比
                NSComparisonResult res = [currentVersion compare:versionGateway options:NSNumericSearch];
                
                switch (res){
                        
                    case NSOrderedAscending:{
                        
                        NSString *msg = [NSString stringWithFormat:@"当前最新的网关固件版本为%@,是否升级？",versionGateway];
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"固件升级" message:msg preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            
                        }];
                        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self sendCommandForGatewayOTAUpdate];
                        }];
                        
                        [alertController addAction:action0];
                        [alertController addAction:action1];
                        [self.navigationController presentViewController:alertController animated:YES completion:nil];
                    }
                        break;
                        
                    case NSOrderedSame:
                    case NSOrderedDescending:{
                        
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"固件升级" message:@"当前固件版本已是最新" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        [alertController addAction:action0];
                        [self.navigationController presentViewController:alertController animated:YES completion:nil];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }];
    [dataTask resume];
}

//发送OTA升级命令
- (void)sendCommandForGatewayOTAUpdate{
    
    char buffer[1024] = {0};
    sendFwOTAUpdate(buffer);
    NSString *OTACommand = [NSString stringWithCString:(const char *)buffer encoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendDeviceControlMsg:OTACommand];
}

//发送网关复位命令
- (void)sendCommandForGatewayRestorate{
    
    char buffer[100] = {0};
    sendDoFactory(buffer);
    NSString *restorateCommand=[NSString stringWithCString:(const char *)buffer encoding:NSUTF8StringEncoding];
    [XHYMsgSendTool sendDeviceControlMsg:restorateCommand];
}

@end

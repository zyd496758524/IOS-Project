//
//  XHYSettingViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/11.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYSettingViewController.h"
#import "XHYSwitchCell.h"

@interface XHYSettingViewController ()<UITableViewDataSource,UITableViewDelegate,XHYSwitchCellDelegate>

@property(nonatomic,strong) UITableView *settingTableView;
@property(nonatomic,strong) NSArray *setItemArray;
@end

@implementation XHYSettingViewController

- (UITableView *)settingTableView{
    
    if (!_settingTableView){
        
        _settingTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _settingTableView.dataSource = self;
        _settingTableView.delegate = self;
        _settingTableView.rowHeight = 60.0f;
        _settingTableView.estimatedRowHeight = 60.0f;
        _settingTableView.backgroundColor = [UIColor clearColor];
        _settingTableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _settingTableView;
}

- (NSArray *)getItemArray{
    
    NSArray *item0 = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"接收消息",@"title",XHYFORBIDMSG,@"value", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"声音提醒",@"title",XHYFORBIDVOICE,@"value", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"振动提醒",@"title",XHYFORBIDSHAKE,@"value", nil],nil];
    
    NSArray *item1 = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"状态栏通知显示",@"title",XHYForbidStatusBarNotification,@"value", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"设备状态刷新置顶",@"title",XHYForbidStickDevice,@"value", nil],nil];
   return [NSArray arrayWithObjects:item0,item1,nil];
}

#pragma mark ----- Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"设置";
    [self.view addSubview:self.settingTableView];
    @JZWeakObj(self);
    [self.settingTableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(selfWeak.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.setItemArray = [self getItemArray];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return [self.setItemArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.setItemArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Indentifier = @"XHYSwitchCell";
    XHYSwitchCell *cell = (XHYSwitchCell *)[tableView dequeueReusableCellWithIdentifier:Indentifier];
    if (!cell) {
        
        cell = [[XHYSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Indentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSDictionary *tempDic = self.setItemArray[indexPath.section][indexPath.row];
    cell.setItemTitleLabel.text = tempDic[@"title"];
    cell.valueSwitch.on = ![tempDic[@"value"] boolValue];
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

#pragma mark ----- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ----- XHYSwitchCellDelegate

- (void)XHYYWarningSetCell:(XHYSwitchCell *)switchCell ValueChange:(BOOL)value indexPath:(NSIndexPath *)index{

    if (0 == index.section){
    
        if (0 == index.row) {
            
            [[NSUserDefaults standardUserDefaults] setValue:value?@"NO":@"YES" forKey:@"XHYFORBIDMSG"];
            
            
        }else if ( 1 == index.row){
            
            [[NSUserDefaults standardUserDefaults] setValue:value?@"NO":@"YES" forKey:@"XHYFORBIDVOICE"];
           
            
        }else if (2 == index.row){
            
            [[NSUserDefaults standardUserDefaults] setValue:value?@"NO":@"YES" forKey:@"XHYFORBIDSHAKE"];
        }
        
    }else if (1 == index.section){
        
        if (0 == index.row){
            
            [[NSUserDefaults standardUserDefaults] setValue:value?@"NO":@"YES" forKey:@"XHYFORBIDSTATUSBARNOTIFICATION"];
            
        }else if ( 1 == index.row){
            
            [[NSUserDefaults standardUserDefaults] setValue:value?@"NO":@"YES" forKey:@"XHYFORBIDSTICKDEVICE"];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.setItemArray = [self getItemArray];
    
    [self.settingTableView beginUpdates];
    [self.settingTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    [self.settingTableView endUpdates];
}

@end

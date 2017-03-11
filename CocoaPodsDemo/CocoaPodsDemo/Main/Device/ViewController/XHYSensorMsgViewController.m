//
//  XHYSensorMsgViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2017/1/21.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYSensorMsgViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "XHYMsg.h"
#import "XHYMsgListCell.h"

@interface XHYSensorMsgViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource>

@property(nonatomic,strong) UITableView *sensorMsgTableView;
@property(nonatomic,strong) NSMutableArray *msgArray;

@end

@implementation XHYSensorMsgViewController

#pragma mark ----- getter

- (NSMutableArray *)msgArray{
    
    if (!_msgArray){
        
        _msgArray = [NSMutableArray array];
    }
    
    return _msgArray;
}

- (UITableView *)sensorMsgTableView{
    
    if (!_sensorMsgTableView){
        
        _sensorMsgTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _sensorMsgTableView.dataSource = self;
        _sensorMsgTableView.delegate = self;
        _sensorMsgTableView.emptyDataSetSource = self;
        _sensorMsgTableView.backgroundColor = [UIColor clearColor];
        _sensorMsgTableView.rowHeight = 92.0f;
        _sensorMsgTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _sensorMsgTableView;
}

#pragma mark ----- Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.sensorMsgTableView];
    @JZWeakObj(self);
    self.sensorMsgTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        
        XHYMsg *lastMsg = [self.msgArray lastObject];
        NSArray *tempMsgArray = [XHYMsg selectDeviceMsgBefore:lastMsg];
        if ([tempMsgArray count]){
            
            [self.msgArray addObjectsFromArray:tempMsgArray];
            [selfWeak.sensorMsgTableView reloadData];
        }
        [selfWeak.sensorMsgTableView.mj_footer endRefreshing];
    }];
    [self.sensorMsgTableView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.edges.equalTo(selfWeak.view);
    }];
    [self xw_addNotificationForName:XHYReceiveNeedDisplayMessage block:^(NSNotification * _Nonnull notification){
        
        XHYMsg *tempMsg = [notification object];
        if ([tempMsg.deviceNwkAddr isEqualToString:self.controlSmartDevice.deviceNwkAddrIdentifier]){
            
            [selfWeak.msgArray insertObject:tempMsg atIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [selfWeak.sensorMsgTableView reloadData];
            });
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    self.msgArray = [NSMutableArray arrayWithArray:[XHYMsg selectAllMsgForDevice:self.controlSmartDevice]];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----- UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"删除";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.msgArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XHYMsgListCell *cell = [XHYMsgListCell dequeueMsgListCellFromRootTableView:tableView];
    XHYMsg *tempMsg = self.msgArray[indexPath.row];
    cell.displayMsg = tempMsg;
    return cell;
}

#pragma mark ----- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.msgArray removeObjectAtIndex:indexPath.row];
    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

#pragma mark -----
#pragma mark ----- DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    
    NSString *text = @"没有任何消息呢";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end

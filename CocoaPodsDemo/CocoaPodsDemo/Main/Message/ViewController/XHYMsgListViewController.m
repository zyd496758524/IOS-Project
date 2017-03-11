//
//  XHYMsgListViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/11.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYMsgListViewController.h"
#import "XHYMsg.h"
#import "XHYMsgListCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "XHYMsgSearchResultViewController.h"
#import "PYSearch.h"

@interface XHYMsgListViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,PYSearchViewControllerDelegate,PYSearchViewControllerDataSource>

@property(nonatomic, strong) UITableView *msgTableView;
@property(nonatomic, strong) NSMutableArray *msgArray;

@end

@implementation XHYMsgListViewController

- (NSMutableArray *)msgArray{

    if (!_msgArray){
        
        _msgArray = [NSMutableArray array];
    }
    
    return _msgArray;
}

- (UITableView *)msgTableView{

    if (!_msgTableView){
        
        _msgTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _msgTableView.dataSource = self;
        _msgTableView.delegate = self;
        _msgTableView.emptyDataSetSource = self;
        _msgTableView.backgroundColor = [UIColor clearColor];
        _msgTableView.rowHeight = 92.0f;
        _msgTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _msgTableView;
}

#pragma mark ----- Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"消息";
    
    [self.view addSubview:self.msgTableView];
    @JZWeakObj(self);
    self.msgTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        
        XHYMsg *lastMsg = [self.msgArray lastObject];
        NSArray *tempMsgArray = [XHYMsg selectMsgBefore:lastMsg];
        if ([tempMsgArray count]){
            
            [self.msgArray addObjectsFromArray:tempMsgArray];
            [selfWeak.msgTableView reloadData];
        }
        [selfWeak.msgTableView.mj_footer endRefreshing];
    }];
    [self.msgTableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(selfWeak.view);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(beginSearchMsg:)];
    
    [self xw_addNotificationForName:XHYReceiveNeedDisplayMessage block:^(NSNotification * _Nonnull notification){
       
        XHYMsg *tempMsg = [notification object];
        [selfWeak.msgArray insertObject:tempMsg atIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [selfWeak.msgTableView reloadData];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [[UINavigationBar appearance] setBarTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
    self.msgArray = [NSMutableArray arrayWithArray:[XHYMsg selectAllMsg]];
    [self.msgTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)beginSearchMsg:(id)sender{
    
    PYSearchViewController *msgSearchViewController = [PYSearchViewController searchViewControllerWithHotSearches:nil searchBarPlaceholder:@"输入设备名称"];
    msgSearchViewController.showHotSearch = NO;
    msgSearchViewController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:msgSearchViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark ----- PYSearchViewControllerDelegate

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

//
//  XHYAreaManagerViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/1.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYAreaManagerViewController.h"
#import "Masonry.h"
#import "XHYDataContainer.h"
#import "XHYFloorItem.h"

#import "XHYHeaderExpandView.h"
#import "UIViewController+MMDrawerController.h"

@interface XHYAreaManagerViewController ()<UITableViewDataSource,UITableViewDelegate,XHYHeaderExpandViewDelegate>

@property(nonatomic,strong) UITableView *floorListTableView;
@property(nonatomic,strong) NSMutableArray *floorArray;

@end

@implementation XHYAreaManagerViewController

- (UITableView *)floorListTableView{
    
    if (!_floorListTableView) {
        
        _floorListTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _floorListTableView.dataSource = self;
        _floorListTableView.delegate = self;
        _floorListTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _floorListTableView.backgroundColor = [UIColor clearColor];
        _floorListTableView.showsHorizontalScrollIndicator = NO;
        _floorListTableView.showsVerticalScrollIndicator = NO;
        _floorListTableView.rowHeight = 60.0f;
    }
    
    return _floorListTableView;
}

- (NSMutableArray *)floorArray{

    if (!_floorArray) {
        
        _floorArray = [NSMutableArray array];
    }
    
    return _floorArray;
}

#pragma mark ----- Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"区域管理";
    [self.view addSubview:self.floorListTableView];
    
    @JZWeakObj(self);
    [self.floorListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.view.mas_left);
        make.right.mas_equalTo(selfWeak.view.mas_right);
        make.bottom.mas_equalTo(selfWeak.view.mas_bottom);
        make.top.mas_equalTo(selfWeak.view.mas_top).offset(20.0f);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(startEditFloor:)];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self getFloorInfoFromDataContainer];
    
     [self.mm_drawerController setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
        return NO;
    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFloorInfoFromDataContainer{

    @JZWeakObj(self);
    [self.floorArray removeAllObjects];
    [[XHYDataContainer defaultDataContainer].allFloorDataArray enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        XHYFloorItem *tempFloorItem = [[XHYFloorItem alloc] init];
        tempFloorItem.floorName = [obj objectForKey:@"name"];
        tempFloorItem.isExpend = NO;
        tempFloorItem.isSelect = NO;
        tempFloorItem.roomArray = [NSMutableArray arrayWithArray:[obj objectForKey:@"scences"]];
        [selfWeak.floorArray addObject:tempFloorItem];
    }];
    
    [self.floorListTableView reloadData];
}

#pragma mark ----- 

- (void)startEditFloor:(id)sender{

    [self.floorListTableView setEditing:!self.floorListTableView.editing animated:YES];
    
    [self.floorListTableView reloadData];
}

#pragma mark ----- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return [self.floorArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    XHYFloorItem *floorItem = self.floorArray[section];
    return floorItem.isExpend?[floorItem.roomArray count]:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *Identifiler = @"FLOORCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifiler];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifiler];
    }
    
    XHYFloorItem *tempFloor = self.floorArray[indexPath.section];
    NSDictionary *roomDict = tempFloor.roomArray[indexPath.row];
    cell.textLabel.text = roomDict[@"scenceName"];
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    XHYHeaderExpandView *headerView = [XHYHeaderExpandView dequeueHeaderExpandViewFromRootTableView:tableView];
    headerView.delegate = self;
    XHYFloorItem *tempFloor = self.floorArray[section];
    headerView.titleLabel.text = tempFloor.floorName;
    headerView.isExpend = tempFloor.isExpend;
    headerView.isSelect = tempFloor.isSelect;
    headerView.tag = section;
    [headerView beginSelect:tableView.editing];
    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    //NSLog(@"sourceIndexPath--->%@  destinationIndexPath--->%@",sourceIndexPath,destinationIndexPath);
    
    if (destinationIndexPath.section == sourceIndexPath.section){
        
        //同楼层内房间排序
        XHYFloorItem *floorItem = self.floorArray[destinationIndexPath.section];
        [floorItem.roomArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        
    }else{
    
        //不同楼层内房间
    }
}

#pragma mark ----- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 20.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ----- XHYHeaderExpandViewDelegate

- (void)XHYHeaderExpandViewExpend:(XHYHeaderExpandView *)headerView{
    
    XHYFloorItem *tempFloor = self.floorArray[headerView.tag];
    tempFloor.isExpend = !tempFloor.isExpend;
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:headerView.tag];
    [self.floorListTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

- (void)XHYHeaderExpandView:(XHYHeaderExpandView *)headerView didSelectBtn:(BOOL)select{

    XHYFloorItem *tempFloor = self.floorArray[headerView.tag];
    tempFloor.isSelect = select;
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:headerView.tag];
    [self.floorListTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
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

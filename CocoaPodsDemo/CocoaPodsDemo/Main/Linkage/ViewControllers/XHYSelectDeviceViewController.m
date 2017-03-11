//
//  XHYSelectDeviceViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/18.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYSelectDeviceViewController.h"
#import "XHYSmartDeviceSelectCell.h"

#import "UIView+Toast.h"

@interface XHYSelectDeviceViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    XHYDeviceSelectType currentSelectType;
}

@property(nonatomic,strong) UITableView *deviceTableView;
@property(nonatomic,strong) NSMutableArray *allDeviceArray;
@property(nonatomic,strong) NSMutableArray *selectDeviceArray;

@property(nonatomic,assign) NSComparator selectDeviceSort;

@end

@implementation XHYSelectDeviceViewController

- (NSComparator)selectDeviceSort{
    
    _selectDeviceSort = ^(XHYSmartDevice *obj1, XHYSmartDevice *obj2){
        
        if ([obj1 getDefaultSortNum] > [obj2 getDefaultSortNum]){
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 getDefaultSortNum] < [obj2 getDefaultSortNum]){
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    return _selectDeviceSort;
}

- (UITableView *)deviceTableView{
    
    if (!_deviceTableView) {
        
        _deviceTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _deviceTableView.dataSource = self;
        _deviceTableView.delegate = self;
        _deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _deviceTableView.backgroundColor = [UIColor clearColor];
        _deviceTableView.showsHorizontalScrollIndicator = NO;
        _deviceTableView.showsVerticalScrollIndicator = NO;
        _deviceTableView.rowHeight = 82.0f;
    }
    
    return _deviceTableView;
}

- (NSMutableArray *)allDeviceArray{

    if (!_allDeviceArray) {
     
        _allDeviceArray = [NSMutableArray array];
    }
    
    return _allDeviceArray;
}

- (NSMutableArray *)selectDeviceArray{

    if (!_selectDeviceArray) {
     
        _selectDeviceArray = [NSMutableArray array];
    }
    
    return _selectDeviceArray;
}

- (instancetype)initWithDeviceSelectType:(XHYDeviceSelectType)selectType{

    if (self = [super init]){
        
        currentSelectType = selectType;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.deviceTableView];
    @JZWeakObj(self);
    [self.deviceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(selfWeak.view);
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelect:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(saveSelect:)];
    
    
    NSMutableArray *tempDeviceArray = [NSMutableArray array];
    
    @JZWeakObj(tempDeviceArray);
    
    switch (currentSelectType) {
            
        case XHYDeviceSelect_Multi:{
            
            self.navigationItem.title = @"选择响应设备";
            
            NSMutableArray *tempDeviceArray = [XHYDataContainer defaultDataContainer].allSmartDeviceArray;
            
            if ([tempDeviceArray count]){
                
                [tempDeviceArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XHYSmartDevice *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([obj isResponseDevice]) {
                        
                        [tempDeviceArrayWeak addObject:obj];
                    }
                }];
            }
        }
            break;
            
        case XHYDeviceSelect_Radio:{
            
            self.navigationItem.title = @"选择触发设备";
            
            NSMutableArray *tempDeviceArray = [XHYDataContainer defaultDataContainer].allSmartDeviceArray;
            
            if ([tempDeviceArray count]){
                
                [tempDeviceArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XHYSmartDevice *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([obj isTriggerDevice]){
                        
                        [tempDeviceArrayWeak addObject:obj];
                    }
                }];
            }
        }
            break;
            
        default:
            break;
    }
    
    
    if ([tempDeviceArray count]){
        
        self.allDeviceArray = [NSMutableArray arrayWithArray:[tempDeviceArray sortedArrayUsingComparator:self.selectDeviceSort]];
    }
}

- (void)cancelSelect:(id)sender{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSelect:(id)sender{
    
    if (![self.selectDeviceArray count]){
        
        [self.view makeToast:@"请选择设备" duration:1.0f position:CSToastPositionCenter];
        return;
    }
    
    if (self.deviceBlock){
        
        self.deviceBlock(self.selectDeviceArray);
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.allDeviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XHYSmartDeviceSelectCell *cell = [XHYSmartDeviceSelectCell dequeueSmartDeviceCellFromRootTableView:tableView];
    
    XHYSmartDevice *tempDevice = [self.allDeviceArray objectAtIndex:indexPath.row];
    [cell setDisplaySmartDevice:tempDevice];
    cell.workStatusImageView.hidden = YES;
    
    [cell setDeviceSelect:[self.selectDeviceArray containsObject:tempDevice]];
    
    return cell;
}

#pragma mark ----- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XHYSmartDevice *tempDevice = [self.allDeviceArray objectAtIndex:indexPath.row];
    
    switch (currentSelectType) {
            
        case XHYDeviceSelect_Radio:{
            
            [self.selectDeviceArray removeAllObjects];
            [self.selectDeviceArray addObject:tempDevice];
            [self.deviceTableView reloadData];
        }
            break;
            
        case XHYDeviceSelect_Multi:{
            
            if ([self.selectDeviceArray containsObject:tempDevice]){
                
                [self.selectDeviceArray removeObject:tempDevice];
                
            }else{
                
                [self.selectDeviceArray addObject:tempDevice];
            }
            
            [self.deviceTableView reloadData];
        }
            break;
            
        default:
            break;
    }
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

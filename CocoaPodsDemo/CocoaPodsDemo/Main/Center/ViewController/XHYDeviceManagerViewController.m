//
//  XHYDeviceManagerViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/1.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYDeviceManagerViewController.h"
#import "XHYHorizontalScrollCell.h"
#import "XHYCameraListCell.h"
#import "XHYSmartDevice.h"

@interface XHYDeviceManagerViewController ()<UITableViewDataSource,UITableViewDelegate,HorizontalScrollCellDeleagte>

@property(nonatomic,strong) UITableView *deviceListTableView;
@property(nonatomic,strong) NSMutableArray *cameraArray;

@end

 NSString *const cameraCellIdentifier = @"XHYCameraListCell";

@implementation XHYDeviceManagerViewController

- (UITableView *)deviceListTableView{
    
    if (!_deviceListTableView) {
        
        _deviceListTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _deviceListTableView.dataSource = self;
        _deviceListTableView.delegate = self;
        _deviceListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _deviceListTableView.backgroundColor = [UIColor clearColor];
        _deviceListTableView.showsHorizontalScrollIndicator = NO;
        _deviceListTableView.showsVerticalScrollIndicator = NO;
        _deviceListTableView.rowHeight = 100.0f;
        //[_deviceListTableView registerClass:[XHYHorizontalScrollCell class] forCellReuseIdentifier:cellIdentifier];
    }
    
    return _deviceListTableView;
}

- (NSMutableArray *)cameraArray{

    if (!_cameraArray) {
     
        _cameraArray = [NSMutableArray array];
        
        [[XHYDataContainer defaultDataContainer].allSmartDeviceArray enumerateObjectsUsingBlock:^(XHYSmartDevice *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj.deviceID == ZCL_HA_DEVICEID_CAMERA) {
                
                [_cameraArray addObject:obj];
            }
        }];
        
    }
    return _cameraArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"设备管理";
    [self.view addSubview:self.deviceListTableView];
    
    @JZWeakObj(self);
    [self.deviceListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.view.mas_left);
        make.right.mas_equalTo(selfWeak.view.mas_right);
        make.bottom.mas_equalTo(selfWeak.view.mas_bottom);
        make.top.mas_equalTo(selfWeak.view.mas_top);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----
#pragma mark ----- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XHYHorizontalScrollCell *cell = (XHYHorizontalScrollCell *)[tableView dequeueReusableCellWithIdentifier:cameraCellIdentifier];
    
    if (!cell) {
        
        cell = [[XHYHorizontalScrollCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cameraCellIdentifier];
    }
    
    cell.delegate = self;
    cell.tableViewIndexPath = indexPath;
    
    return cell;
}

#pragma mark -----
#pragma mark ----- HorizontalScrollCellDeleagte

- (NSInteger)horizontalCellContentsView:(UICollectionView *)horizontalCellContentsView numberOfItemsInTableViewIndexPath:(NSIndexPath *)tableViewIndexPath{

    return 10;
}

- (UICollectionViewCell *)horizontalCellContentsView:(UICollectionView *)horizontalCellContentsView cellForItemAtContentIndexPath:(NSIndexPath *)contentIndexPath inTableViewIndexPath:(NSIndexPath *)tableViewIndexPath{

    XHYCameraListCell *cameraCell = [horizontalCellContentsView dequeueReusableCellWithReuseIdentifier:cameraCellIdentifier forIndexPath:contentIndexPath];
    
    return cameraCell;
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

//
//  XHYDeviceAddViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYDeviceAddViewController.h"
#import "XHYAddDeviceTypeCell.h"

@interface XHYDeviceAddViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView *addDeviceTableView;
@property(nonatomic,strong) NSArray *addDeviceTypeArray;

@end

@implementation XHYDeviceAddViewController

- (UITableView *)addDeviceTableView{

    if (!_addDeviceTableView){
        
        _addDeviceTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _addDeviceTableView.dataSource = self;
        _addDeviceTableView.delegate = self;
        _addDeviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _addDeviceTableView.backgroundColor = [UIColor clearColor];
        _addDeviceTableView.showsHorizontalScrollIndicator = NO;
        _addDeviceTableView.showsVerticalScrollIndicator = NO;
        _addDeviceTableView.rowHeight = 92.0f;
    }
    return _addDeviceTableView;
}

- (NSArray *)addDeviceTypeArray{

    if (!_addDeviceTypeArray){
     
        _addDeviceTypeArray = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"添加网络摄像头",@"Name",@"device_camera_online.png",@"ImageName", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"添加红外转发设备",@"Name",@"sensor_infraredrepeater_online.png",@"ImageName", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"添加普通智能设备",@"Name",@"device_light_online.png",@"ImageName", nil],nil];
    }
    
    return _addDeviceTypeArray;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"添加设备";
    
    @JZWeakObj(self);
    [self.view addSubview:self.addDeviceTableView];
    [self.addDeviceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(selfWeak.view);
    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.addDeviceTypeArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *addDeviceCellIdentifiler = @"addDeviceCellIdentifiler";
    
    XHYAddDeviceTypeCell *cell = (XHYAddDeviceTypeCell *)[tableView dequeueReusableCellWithIdentifier:addDeviceCellIdentifiler];
    
    if (!cell) {
        
        cell = [[XHYAddDeviceTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addDeviceCellIdentifiler];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *tempDict = self.addDeviceTypeArray[indexPath.row];
    
    cell.addDeviceLabel.text = [tempDict objectForKey:@"Name"];
    cell.addDeviceIconImageView.image = [UIImage imageNamed:[tempDict objectForKey:@"ImageName"]];
    
    
    return cell;
}

#pragma mark -----  UITableViewDelegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  XHYCenterViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/11.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYCenterViewController.h"
#import "Masonry.h"
#import "UIViewController+MMDrawerController.m"
#import "XHYFontTool.h"
#import "AppDelegate.h"
#import "XHYLoginManager.h"
#import "UIImage+Color.h"
#import "UIImage+makeColor.h"

#import "XHYRootTabBarController.h"
#import "XHYGatewayManagerViewController.h"
#import "XHYAreaManagerViewController.h"
#import "XHYDeviceManagerViewController.h"
#import "XHYLinkageManagerViewController.h"
#import "XHYSettingViewController.h"

static const CGFloat BgImageHeight = 200.0f;

@interface XHYCenterViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray *iconArray;
}

@property(nonatomic,strong) NSArray *itemArray;
@property(nonatomic,strong) UIImageView *backImageView;
@property(nonatomic,strong) UITableView *centerTableView;

@end

@implementation XHYCenterViewController

#pragma mark -----
#pragma mark ----- getter

- (NSArray *)itemArray{

    if (!_itemArray){
        
        _itemArray = [NSArray arrayWithObjects:NSLocalizedString(@"Gateway management", nil),NSLocalizedString(@"Regional management", nil),NSLocalizedString(@"Linkage management", nil),NSLocalizedString(@"Log out", nil),nil];
    }
    
    return _itemArray;
}

- (UIImageView *)backImageView{

    if(!_backImageView){
        
        _backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_topbg.png"]];
        [_backImageView setFrame:CGRectMake(0.0f,-BgImageHeight, ScreenWidth, BgImageHeight)];
    }
    return _backImageView;
}

- (UITableView *)centerTableView{

    if (!_centerTableView){
    
        _centerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ScreenWidth, ScreenHeight - 49.0f) style:UITableViewStylePlain];
        _centerTableView.dataSource = self;
        _centerTableView.delegate = self;
        _centerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _centerTableView.backgroundColor = [UIColor clearColor];
        _centerTableView.showsHorizontalScrollIndicator = NO;
        _centerTableView.showsVerticalScrollIndicator = NO;
        _centerTableView.rowHeight = 60.0f;
        _centerTableView.contentInset = UIEdgeInsetsMake(BgImageHeight, 0, 0, 0);
    }
    
    return _centerTableView;
}

#pragma mark -----
#pragma mark ----- Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BackgroudColor;
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
    
    iconArray = [NSArray arrayWithObjects:@"center_gateway",@"center_gateway",@"center_gateway",@"center_gateway",@"center_gateway",@"center_gateway",@"center_gateway",@"center_gateway",nil];
    
    [self.centerTableView addSubview:self.backImageView];
    [self.view addSubview:self.centerTableView];
    @JZWeakObj(self);
    [self.centerTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(selfWeak.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBtnAction:(id)sender{

    XHYSettingViewController *settingViewController = [[XHYSettingViewController alloc] init];
    [settingViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

#pragma mark -----
#pragma mark ----- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *Identifiler = @"centerTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifiler];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifiler];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.imageView.image = [UIImage imageNamed:[iconArray objectAtIndex:indexPath.row]];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
    cell.textLabel.text = self.itemArray[indexPath.row];
    
    return cell;
}

#pragma mark -----
#pragma mark ----- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.itemArray count] - 1 == indexPath.row){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否退出当前账号" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            
        }];
        
        UIAlertAction *replacelBtn = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            
            [[XHYLoginManager defaultLoginManager] disconnect];
            startReconnect();
            [self.mm_drawerController dismissViewControllerAnimated:YES completion:^{
                
                [[XHYDataContainer defaultDataContainer] clearAllData];
            }];
        }];
        
        [alertController addAction:cancelBtn];
        [alertController addAction:replacelBtn];
        [self presentViewController:alertController animated:YES completion:^{}];
        return;
        
    }else{
        
        [self.mm_drawerController closeDrawerAnimated:NO completion:^(BOOL finished) {
            
            XHYRootTabBarController *rootTabBarController = (XHYRootTabBarController *)self.mm_drawerController.centerViewController;
            UINavigationController *currentNavi = rootTabBarController.selectedViewController;
            
            if (0 == indexPath.row){
                
                //网关管理
                XHYGatewayManagerViewController *gatewayManagerViewController = [[XHYGatewayManagerViewController alloc] init];
                [gatewayManagerViewController setHidesBottomBarWhenPushed:YES];
                [currentNavi pushViewController:gatewayManagerViewController animated:YES];
                
            }else if (1 == indexPath.row){
                
                //区域管理
                XHYAreaManagerViewController *areaManagerViewController = [[XHYAreaManagerViewController alloc] init];
                [areaManagerViewController setHidesBottomBarWhenPushed:YES];
                [currentNavi pushViewController:areaManagerViewController animated:YES];
                
            }/*else if (2 == indexPath.row){
                
                //设备管理
                XHYDeviceManagerViewController *deviceManagerViewController = [[XHYDeviceManagerViewController alloc] init];
                [deviceManagerViewController setHidesBottomBarWhenPushed:YES];
                [currentNavi pushViewController:deviceManagerViewController animated:YES];
                
            }*/else if (2 == indexPath.row){
                
                //联动管理
                XHYLinkageManagerViewController *linkageManagerViewController = [[XHYLinkageManagerViewController alloc] init];
                [linkageManagerViewController setHidesBottomBarWhenPushed:YES];
                [currentNavi pushViewController:linkageManagerViewController animated:YES];
            }
        }];
    }
}

#pragma mark -----
#pragma mark ----- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat yOffset  = scrollView.contentOffset.y;
    CGFloat xOffset = (yOffset + BgImageHeight)/2;
    
    if (yOffset < -BgImageHeight) {
        
        CGRect rect = self.backImageView.frame;
        
        rect.origin.x = xOffset;
        rect.origin.y = yOffset;
        rect.size.height =  -yOffset ;
        rect.size.width = ScreenWidth + fabs(xOffset)*2;
        
        self.backImageView.frame = rect;
    }
    
    CGFloat alpha = (yOffset + BgImageHeight) / BgImageHeight;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[[UIColor blackColor] colorWithAlphaComponent:alpha]] forBarMetrics:UIBarMetricsDefault];
}

@end

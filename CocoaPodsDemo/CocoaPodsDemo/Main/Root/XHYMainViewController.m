//
//  XHYMainViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/8.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYMainViewController.h"

#import "UIViewController+MMDrawerController.h"
#import "XHYCenterViewController.h"

@interface XHYMainViewController ()

@end

@implementation XHYMainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BackgroudColor;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0.0f, 0.0f, 26.0f, 26.0f);
    [leftBtn setImage:[UIImage imageNamed:@"public_nav_left"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if (!self.mm_drawerController.leftDrawerViewController) {
        
         [self.mm_drawerController setLeftDrawerViewController:[[XHYCenterViewController alloc] init]];
    }
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
}

- (void)leftBtnClick:(id)sender{

    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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

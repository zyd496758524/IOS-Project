//
//  XHYBaseViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/1.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYBaseViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "UIImage+Color.h"
#import "UIColor+JKHEX.h"
@interface XHYBaseViewController ()

@end

@implementation XHYBaseViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BackgroudColor;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (self.navigationController){
        // 自定义左键，贴图，并重写返回方法
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 0, 24.0f, 24.0f);
        [leftBtn setImage:[UIImage imageNamed:@"back_all.png"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    }
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if (self.mm_drawerController.leftDrawerViewController){
        
        [self.mm_drawerController setLeftDrawerViewController:nil];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
}

- (void)leftBtnClick{
    
    if (self.navigationController) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
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

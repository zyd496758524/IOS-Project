//
//  XHYEditDeviceNameViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2017/2/17.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYEditDeviceNameViewController.h"
#import "XHYSmartDevice.h"
#import "XHYMsgSendTool.h"

@interface XHYEditDeviceNameViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITextField *changeNameField;
@property(nonatomic,strong) UITableView *changeNameTableView;

@end

@implementation XHYEditDeviceNameViewController

- (UITextField *)changeNameField{
    
    if (!_changeNameField){
        
        _changeNameField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 7.0f, [UIScreen mainScreen].bounds.size.width-30.0f, 30.0f)];
        _changeNameField.backgroundColor = [UIColor clearColor];
        _changeNameField.keyboardType = UIKeyboardTypeDefault;
        _changeNameField.secureTextEntry = NO;
        _changeNameField.borderStyle = UITextBorderStyleNone;
        _changeNameField.enabled = YES;
        _changeNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _changeNameField.text = [self.editNameSmartDevice.customDeviceName length] ? self.editNameSmartDevice.customDeviceName:self.editNameSmartDevice.deviceName;
    }
    
    return _changeNameField;
}

- (UITableView *)changeNameTableView{
    
    if (!_changeNameTableView) {
        
        _changeNameTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _changeNameTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _changeNameTableView.delegate = self;
        _changeNameTableView.dataSource = self;
        _changeNameTableView.rowHeight = 44.0f;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeNameEndEdit:)];
        tap.numberOfTapsRequired = 1;
        [_changeNameTableView addGestureRecognizer:tap];
    }
    return _changeNameTableView;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"修改设备名称";
    [self.view addSubview:self.changeNameTableView];
    @JZWeakObj(self);
    [self.changeNameTableView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.edges.equalTo(selfWeak.view);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveDeviceCustomName:)];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if ([self.changeNameField canBecomeFirstResponder]){
        
        [self.changeNameField becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

#pragma mark ----- 结束编辑

- (void)changeNameEndEdit:(UITapGestureRecognizer *)tap{
    
    [self.changeNameField resignFirstResponder];
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveDeviceCustomName:(id)sender{
    
    [self.view endEditing:YES];
    
    NSString *customName = self.changeNameField.text;
    if ([customName length]){
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [SVProgressHUD show];
            
            NSMutableDictionary *customDict = [NSMutableDictionary dictionaryWithDictionary:[XHYDataContainer defaultDataContainer].deviceNameDict];
            NSString *deviceKey = [NSString stringWithFormat:@"%d#%@",self.editNameSmartDevice.nwkAddr,self.editNameSmartDevice.deviceIEEEAddrIdentifier];
            //存在退换，不存在则添加
            [customDict setObject:customName forKey:deviceKey];
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:customDict options:0 error:nil];
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *result2 = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [XHYMsgSendTool sendIQData:@"DeviceName" msgContent:result2];
            self.editNameSmartDevice.customDeviceName = customName;
            [XHYDataContainer defaultDataContainer].deviceNameDict = customDict;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:XHYDeviceNameChanged object:self.editNameSmartDevice];
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    } else {
        
        [self.view makeToast:@"设备重命名不能为空" duration:1.0f position:CSToastPositionCenter];
    }
}

#pragma mark ----- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifier = @"XHYEditDeviceNameCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (!cell){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView *view in [cell.contentView subviews]){
        
        [view removeFromSuperview];
    }
    
    [cell.contentView addSubview:self.changeNameField];
    
    return cell;
}

#pragma mark ----- UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (0 == section){
        
        return @"修改设备名称";
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0f;
}

@end

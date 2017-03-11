//
//  XHYQrScanViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/18.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYQrScanViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "UIImage+mask.h"

static const CGFloat scanAreaSize = 260.0f;

@interface XHYQrScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>{

    CGRect scanRect;
}
//硬件设备
@property (nonatomic, strong) AVCaptureDevice *device;
//输入流
@property (nonatomic, strong) AVCaptureDeviceInput *input;
//协调输入输出流的数据
@property (nonatomic, strong) AVCaptureSession *session;
//预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
//输出流（扫描结果）
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;

@end

@implementation XHYQrScanViewController

#pragma mark ----- getters

- (AVCaptureDevice *)device{

    if (!_device) {
        
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input{
    
    if (_input == nil) {
        
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    }
    return _input;
}

- (AVCaptureSession *)session{
    
    if (_session == nil) {
        
        _session = [[AVCaptureSession alloc] init];
        if ([_session canAddInput:self.input]) {
            
            [_session addInput:self.input];
        }
        if ([_session canAddOutput:self.metadataOutput]) {
            
            [_session addOutput:self.metadataOutput];
        }
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer{
    
    if (_previewLayer == nil) {
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = self.view.layer.bounds;
    }
    return _previewLayer;
}

- (AVCaptureMetadataOutput *)metadataOutput{
    
    if (_metadataOutput == nil) {
        
        _metadataOutput = [[AVCaptureMetadataOutput alloc]init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //设置扫描区域
    }
    
    return _metadataOutput;
}

#pragma mark ----- life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"二维码";
    
    scanRect = CGRectMake((ScreenWidth - scanAreaSize)/2, (ScreenHeight - 64.0f - scanAreaSize)/2 - 30, scanAreaSize, scanAreaSize);
    
    UIImageView *maskView = [[UIImageView alloc] initWithFrame:self.previewLayer.bounds];
    maskView.image = [UIImage maskImageWithMaskRect:maskView.frame clearRect:scanRect];
    [self.previewLayer addSublayer:maskView.layer];
    
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                                AVMetadataObjectTypeEAN13Code,
                                                AVMetadataObjectTypeEAN8Code,
                                                AVMetadataObjectTypeCode128Code];
    //设置有效的扫描区域
    [self.metadataOutput setRectOfInterest:CGRectMake((ScreenHeight - scanAreaSize)/(2 * ScreenHeight), ((ScreenWidth - 64.0 - scanAreaSize)/2 - 30)/ScreenWidth, scanAreaSize / ScreenHeight, scanAreaSize / ScreenWidth)];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    [self.session startRunning];
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [self.session stopRunning];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark ----- AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count > 0 ){
        
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSLog(@"%@",metadataObject.stringValue);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

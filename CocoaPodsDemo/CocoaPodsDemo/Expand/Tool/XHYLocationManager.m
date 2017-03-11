//
//  XHYLocationManager.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2017/3/3.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYLocationManager.h"

@interface XHYLocationManager()<CLLocationManagerDelegate>{

}
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;
@property (nonatomic, readwrite, copy) KSystemLocationBlock kSystemLocationBlock;
@end

@implementation XHYLocationManager
+ (id)shareInstance{
    static id helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[XHYLocationManager alloc]  init];
    });
    return helper;
}

#pragma mark - 苹果
/**
 *  苹果系统自带地图定位
 */
- (void)startSystemLocationWithRes:(KSystemLocationBlock)systemLocationBlock{
    
    self.kSystemLocationBlock = systemLocationBlock;
    
    if(!self.locationManager){
        self.locationManager =[[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //        self.locationManager.distanceFilter=10;
        if ([UIDevice currentDevice].systemVersion.floatValue >=8) {
            [self.locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8定位需要）
        }
    }
    self.locationManager.delegate=self;
    [self.locationManager startUpdatingLocation];//开启定位
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currLocation=[locations lastObject];
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    
    self.kSystemLocationBlock(currLocation, nil);
}
/**
 *定位失败，回调此方法
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    
    self.kSystemLocationBlock(nil, error);
}

@end

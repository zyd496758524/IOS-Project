//
//  XHYSmartDeviceCell.h
//  XHYSparxSmart
//
//  Created by  XHY on 16/7/22.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XHYSmartDevice.h"
//主页显示设备信息

@interface XHYSmartDeviceCell : UITableViewCell

@property(nonatomic,strong) UIImageView *iconImageView;    //设备图标
@property(nonatomic,strong) UILabel *deviceNameLabel;      //设备名称

@property(nonatomic,strong) UIImageView *locationImageView;
@property(nonatomic,strong) UILabel *deviceFloorLabel;     //设备楼层

@property(nonatomic,strong) UIImageView *powerImageView;   //电量
@property(nonatomic,strong) UILabel *powerLabel;           //电量统计(弱电设备)
@property(nonatomic,strong) UIImageView *workStatusImageView; //设备工作状态
@property(nonatomic,strong) XHYSmartDevice *displaySmartDevice;

+ (instancetype)dequeueSmartDeviceCellFromRootTableView:(UITableView *)tableView;

@end

//
//  XHYSmartDeviceSelectCell.h
//  CocoaPodsDemo
//
//  Created by Zyd on 2017/1/16.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYSmartDeviceCell.h"

@interface XHYSmartDeviceSelectCell : XHYSmartDeviceCell

@property(nonatomic,strong) UIImageView *selectImageView;
@property(nonatomic,assign) BOOL deviceSelect;

+ (instancetype)dequeueSmartDeviceCellFromRootTableView:(UITableView *)tableView;

@end

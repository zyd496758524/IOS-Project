//
//  XHYMsgListCell.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/24.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHYMsg.h"

@interface XHYMsgListCell : UITableViewCell

@property(nonatomic,strong) UIImageView *iconImageView;
@property(nonatomic,strong) UILabel *deviceNameLabel;
@property(nonatomic,strong) UILabel *msgContentLabel;

@property(nonatomic,strong) UILabel *msgDateLabel;   //日期标签
@property(nonatomic,strong) UILabel *msgTimeLabel;   //时间标签
@property(nonatomic,strong) UILabel *lineLabel;

@property(nonatomic,strong) XHYMsg *displayMsg;

+ (instancetype)dequeueMsgListCellFromRootTableView:(UITableView *)tableView;

@end

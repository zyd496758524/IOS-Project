//
//  XHYModeListCell.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHYModeListCell : UITableViewCell

@property(nonatomic,strong) UIImageView *iconImageView;
@property(nonatomic,strong) UILabel *modeNameLabel;
@property(nonatomic,strong) UILabel *modeDescriptionLabel;

@property(nonatomic,strong) UIButton *selectBtn;

+ (instancetype)dequeueModeListCellFromRootTableView:(UITableView *)tableView;

@end

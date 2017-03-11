//
//  XHYWeekSelectCell.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/10/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHYWeekSelectCell : UITableViewCell

@property(nonatomic,strong) UILabel *weekLabel;
@property(nonatomic,strong) UIImageView *selectImageView;
@property(nonatomic,strong) UILabel *lineLabel;

@property(nonatomic,assign) BOOL cheak;

@end

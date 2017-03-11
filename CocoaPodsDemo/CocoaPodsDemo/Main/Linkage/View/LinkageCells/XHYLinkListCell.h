//
//  XHYLinkListCell.h
//  XHYSparxSmart
//
//  Created by  XHY on 2016/10/12.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHYLinkListCell : UITableViewCell

@property(nonatomic,strong) UIImageView *selectImageView;

@property(nonatomic,strong) UILabel *linkName;
@property(nonatomic,strong) UILabel *linkDevice0;
@property(nonatomic,strong) UIImageView *linkImageView;
@property(nonatomic,strong) UILabel *linkDevice1;
@property(nonatomic,assign) BOOL check;

- (void)setEditForSelect:(BOOL)edit;

- (void)configDevice0Text:(NSString *)text;

@end

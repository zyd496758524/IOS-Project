//
//  XHYHeaderExpandView.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/22.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHYHeaderExpandView;

// 定义一个 协议
@protocol XHYHeaderExpandViewDelegate <NSObject>

- (void)XHYHeaderExpandViewExpend:(XHYHeaderExpandView *)headerView;

- (void)XHYHeaderExpandView:(XHYHeaderExpandView *)headerView didSelectBtn:(BOOL)select;

@end


@interface XHYHeaderExpandView : UITableViewHeaderFooterView

@property (nonatomic, assign) id<XHYHeaderExpandViewDelegate> delegate;

@property(nonatomic,strong) UIButton *selectBtn;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIImageView *expendImageView;

@property(nonatomic,strong) UILabel *topLineLabel;
@property(nonatomic,strong) UILabel *bottomLineLabel;

@property(nonatomic,assign) BOOL isSelect;
@property(nonatomic,assign) BOOL isExpend;

+ (instancetype)dequeueHeaderExpandViewFromRootTableView:(UITableView *)tableView;

- (void)beginSelect:(BOOL)begin;

@end

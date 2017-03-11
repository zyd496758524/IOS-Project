//
//  XHYFooterAddView.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/24.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHYFooterAddView;

// 定义一个 协议
@protocol XHYFooterAddViewDelegate <NSObject>

- (void)XHYFooterAddViewAddBtnClick:(XHYFooterAddView *)footerView;

@end

@interface XHYFooterAddView : UITableViewHeaderFooterView

@property(nonatomic,weak) id<XHYFooterAddViewDelegate> delegate;

@property(nonatomic,strong) UIButton *addBtn;
@property(nonatomic,strong) UILabel *bottomLineLabel;

+ (instancetype)dequeueFooterAddViewFromRootTableView:(UITableView *)tableView;

@end

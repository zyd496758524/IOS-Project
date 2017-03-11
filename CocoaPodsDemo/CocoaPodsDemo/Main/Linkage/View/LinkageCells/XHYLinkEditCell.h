//
//  XHYLinkEditCell.h
//  XHYSparxSmart
//
//  Created by  XHY on 2016/10/12.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHYLinkEditCell;

@protocol XHYLinkEditCellDelegate <NSObject>

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell didDeleteLink:(NSIndexPath *)indexPath;

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell deviceDidSelectLink:(NSIndexPath *)indexPath;

- (void)XHYLinkEditCell:(XHYLinkEditCell *)linkEditCell actionDidSelectLink:(NSIndexPath *)indexPath;

@end

@interface XHYLinkEditCell : UITableViewCell

@property(nonatomic,assign) id<XHYLinkEditCellDelegate> delegate;
@property(nonatomic,strong) NSIndexPath *indexPath;

@property(nonatomic,strong) UIButton *deleteBtn;

@property(nonatomic,strong) UIImageView *deviceImageView;
@property(nonatomic,strong) UILabel *deviceName;
@property(nonatomic,strong) UIImageView *deviceIndicatorImageView;

@property(nonatomic,strong) UIImageView *actionImageView;
@property(nonatomic,strong) UILabel *actionName;
@property(nonatomic,strong) UIImageView *actionIndicatorImageView;

//隐藏动作部分视图（action）

- (void)setActionViewHidden:(BOOL)hidden;

- (void)setEditForDelete:(BOOL)edit;

@end

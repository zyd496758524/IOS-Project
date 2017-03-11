//
//  XHYSwitchCell.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2017/2/21.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHYSwitchCell;

@protocol XHYSwitchCellDelegate <NSObject>

- (void)XHYYWarningSetCell:(XHYSwitchCell *)switchCell ValueChange:(BOOL)value indexPath:(NSIndexPath *)index;

@end


@interface XHYSwitchCell : UITableViewCell

@property(nonatomic,weak) id<XHYSwitchCellDelegate> delegate;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,strong) UILabel *setItemTitleLabel;
@property(nonatomic,strong) UISwitch *valueSwitch;

@end

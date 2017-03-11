//
//  XHYLinkageSelectCell.h
//  CocoaPodsDemo
//
//  Created by Zyd on 2017/1/18.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYLinkListCell.h"

@interface XHYLinkageSelectCell : XHYLinkListCell

@property(nonatomic,strong) UIImageView *linkSelectImageView;
@property(nonatomic,assign) BOOL linkageSelect;

+ (instancetype)dequeueLinkageSelectCellFromRootTableView:(UITableView *)tableView;

@end

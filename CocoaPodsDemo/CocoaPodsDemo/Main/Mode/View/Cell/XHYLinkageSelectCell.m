//
//  XHYLinkageSelectCell.m
//  CocoaPodsDemo
//
//  Created by Zyd on 2017/1/18.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYLinkageSelectCell.h"

static NSString * const LinkageSelectCellIdentifier = @"LinkageSelectCellIdentifier";

@implementation XHYLinkageSelectCell

+ (instancetype)dequeueLinkageSelectCellFromRootTableView:(UITableView *)tableView{
    
    XHYLinkageSelectCell *cell = (XHYLinkageSelectCell *)[tableView dequeueReusableCellWithIdentifier:LinkageSelectCellIdentifier];
    
    if (!cell) {
        
        cell = [[XHYLinkageSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LinkageSelectCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}


- (UIImageView *)linkSelectImageView{
    
    if (!_linkSelectImageView) {
        
        _linkSelectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"device_check_normal"]];
        _linkSelectImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _linkSelectImageView;
}

- (void)setupLinkageSelectView{
    
    [self.contentView addSubview:self.linkSelectImageView];
    
    @JZWeakObj(self);
    [self.linkSelectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(selfWeak.contentView.mas_right).offset(-8);             //左 往右偏移 8
        make.centerY.mas_equalTo(selfWeak.linkName.mas_centerY);                      //垂直居中
        make.size.mas_equalTo(CGSizeMake(selectImageSize, selectImageSize));             //固定大小
    }];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self){
        
        [self setupLinkageSelectView];
    }
    
    return self;
}

- (void)setLinkageSelect:(BOOL)linkageSelect{
    
    if (linkageSelect){
        
        [self.linkSelectImageView setImage:[UIImage imageNamed:@"device_check_select"]];
        
    }else{
        
        [self.linkSelectImageView setImage:[UIImage imageNamed:@"device_check_normal"]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

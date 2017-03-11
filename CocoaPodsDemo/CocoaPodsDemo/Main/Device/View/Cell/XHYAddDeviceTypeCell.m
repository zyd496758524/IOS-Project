//
//  XHYAddDeviceTypeCell.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/5.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYAddDeviceTypeCell.h"
#import "XHYFontTool.h"

@implementation XHYAddDeviceTypeCell

- (UIImageView *)addDeviceIconImageView{

    if (!_addDeviceIconImageView) {
        
        _addDeviceIconImageView = [[UIImageView alloc] init];
        _addDeviceIconImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _addDeviceIconImageView;
}

- (UILabel *)addDeviceLabel{

    if (!_addDeviceLabel) {
        
        _addDeviceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addDeviceLabel.backgroundColor = [UIColor clearColor];
        _addDeviceLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _addDeviceLabel.textColor = [UIColor blackColor];
        _addDeviceLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return  _addDeviceLabel;
}

- (UIImageView *)addDeviceIndicatorImageView{

    if (!_addDeviceIndicatorImageView) {
        
        _addDeviceIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_disclosureIndicator"]];
        _addDeviceIndicatorImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _addDeviceIndicatorImageView;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    bounds.origin.x += 10;
    bounds.size.width -= 20;
    bounds.origin.y += 10;
    bounds.size.height -= 20;
    self.contentView.frame = bounds;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.layer.cornerRadius = 6.0f;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.clipsToBounds = YES;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        [self setupChildView];

    }
    
    return self;
}

- (void)setupChildView{

    [self.contentView addSubview:self.addDeviceLabel];
    [self.contentView addSubview:self.addDeviceIconImageView];
    [self.contentView addSubview:self.addDeviceIndicatorImageView];
    
    @JZWeakObj(self);
    
    [self.addDeviceIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.contentView.mas_left).offset(8);             //左 往右偏移 8
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);                      //垂直居中
        make.size.mas_equalTo(CGSizeMake(primaryIconSize, primaryIconSize));             //固定大小
    }];
    
    [self.addDeviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.left.mas_equalTo(selfWeak.addDeviceIconImageView.mas_right).offset(8);
        make.width.mas_equalTo(@200.0f);
        make.height.mas_equalTo(selfWeak.addDeviceIconImageView.mas_height);
    }];
    
    [self.addDeviceIndicatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.right.mas_equalTo(selfWeak.contentView.mas_right).offset(-8);
        make.size.mas_equalTo(CGSizeMake(9.0f, 14.0f));
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        
        [self.contentView setBackgroundColor:[UIColor grayColor]];
        
    }else{
        
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
}

@end

//
//  XHYModeListCell.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYModeListCell.h"
#import "XHYFontTool.h"
#import "UIColor+JKHEX.h"

//static const CGFloat modeIconSize = 30.0f;
static const CGFloat modeNameHeight = 20.0f;
static const CGFloat spaceX = 8.0f;
static NSString * const ModeListCellIdentifier = @"ModeListCellIdentifier";


@implementation XHYModeListCell

+ (instancetype)dequeueModeListCellFromRootTableView:(UITableView *)tableView{

    XHYModeListCell *cell = (XHYModeListCell *)[tableView dequeueReusableCellWithIdentifier:ModeListCellIdentifier];
    
    if (!cell) {
        
        cell = [[XHYModeListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ModeListCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (UIImageView *)iconImageView{
    
    if (!_iconImageView) {
        
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _iconImageView;
}

- (UILabel *)modeNameLabel{
    
    if (!_modeNameLabel) {
        
        _modeNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _modeNameLabel.backgroundColor = [UIColor clearColor];
        _modeNameLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _modeNameLabel.textColor = [UIColor blackColor];
        _modeNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _modeNameLabel;
}

- (UILabel *)modeDescriptionLabel{
    
    if (!_modeDescriptionLabel) {
        
        _modeDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _modeDescriptionLabel.backgroundColor = [UIColor clearColor];
        _modeDescriptionLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:12.0f];
    }
    
    return _modeDescriptionLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.layer.cornerRadius = 6.0f;
        self.contentView.backgroundColor = [UIColor whiteColor];

        [self setupSubViews];
    }
    
    return self;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    bounds.origin.x += marginSpaceSize;
    bounds.size.width -= marginSpaceSize * 2;
    bounds.origin.y += 10;
    bounds.size.height -= 10;
    self.contentView.frame = bounds;
}

- (void)setupSubViews{
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.modeNameLabel];
    [self.contentView addSubview:self.modeDescriptionLabel];
    
    @JZWeakObj(self);
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.size.mas_equalTo(CGSizeMake(primaryIconSize, primaryIconSize));
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.left.mas_equalTo(selfWeak.contentView.mas_left).offset(spaceX);
    }];
    
    [self.modeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.iconImageView.mas_right).offset(spaceX);
        make.top.mas_equalTo(selfWeak.iconImageView.mas_top);
        make.height.mas_equalTo(modeNameHeight);
        make.width.mas_equalTo(150.0f);
    }];
    
    [self.modeDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.iconImageView.mas_right).offset(spaceX);
        make.top.mas_equalTo(selfWeak.modeNameLabel.mas_bottom);
        make.height.mas_equalTo(modeNameHeight);
        make.width.mas_equalTo(150.0f);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
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

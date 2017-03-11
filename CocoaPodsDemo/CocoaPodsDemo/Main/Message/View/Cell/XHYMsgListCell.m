//
//  XHYMsgListCell.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/24.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYMsgListCell.h"
#import "XHYFontTool.h"
#import "UIColor+JKHEX.h"
#import "UIImage+Color.h"
#import "UIImage+makeColor.h"
#import "UIImage+RoundedCorner.h"

static const CGFloat iconSize = 16.0f;
static const CGFloat deviceNameHeight = 20.0f;
static const CGFloat spaceX = 5.0f;
static NSString * const MsgListCellIdentifier = @"MsgListCellIdentifier";

@implementation XHYMsgListCell

+ (instancetype)dequeueMsgListCellFromRootTableView:(UITableView *)tableView{

    XHYMsgListCell *cell = (XHYMsgListCell *)[tableView dequeueReusableCellWithIdentifier:MsgListCellIdentifier];
    
    if (!cell) {
        
        cell = [[XHYMsgListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MsgListCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (UIImageView *)iconImageView{

    if (!_iconImageView) {
        
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor whiteColor];
        _iconImageView.layer.cornerRadius = iconSize / 2;
        _iconImageView.layer.masksToBounds = YES;
    }
    
    return _iconImageView;
}

- (UILabel *)deviceNameLabel{
    
    if (!_deviceNameLabel) {
        
        _deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _deviceNameLabel.backgroundColor = [UIColor clearColor];
        _deviceNameLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _deviceNameLabel.textColor = [UIColor blackColor];
        _deviceNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _deviceNameLabel;
}

- (UILabel *)msgContentLabel{
    
    if (!_msgContentLabel) {
        
        _msgContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgContentLabel.backgroundColor = [UIColor clearColor];
        _msgContentLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:15.0f];
        _msgContentLabel.textColor = BackgroudColor;
        _msgContentLabel.textAlignment = NSTextAlignmentLeft;
        _msgContentLabel.numberOfLines = 0;
        _msgContentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    
    return _msgContentLabel;
}

- (UILabel *)msgDateLabel{
    
    if (!_msgDateLabel) {
        
        _msgDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgDateLabel.backgroundColor = [UIColor clearColor];
        _msgDateLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:12.0f];
        _msgDateLabel.textColor = BackgroudColor;
        _msgDateLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _msgDateLabel;
}

- (UILabel *)msgTimeLabel{
    
    if (!_msgTimeLabel) {
        
        _msgTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgTimeLabel.backgroundColor = [UIColor clearColor];
        _msgTimeLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _msgTimeLabel.textColor = [UIColor whiteColor];
        _msgTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return _msgTimeLabel;
}

- (UILabel *)lineLabel{
    
    if (!_lineLabel) {
        
        _lineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _lineLabel.backgroundColor = BackgroudColor;
    }
    
    return _lineLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 6.0f;
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
    
    [self.contentView addSubview:self.msgDateLabel];
    [self.contentView addSubview:self.msgTimeLabel];
    [self.contentView addSubview:self.lineLabel];

    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.deviceNameLabel];
    [self.contentView addSubview:self.msgContentLabel];
    
    @JZWeakObj(self);
    
    [self.msgDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.contentView.mas_left).offset(spaceX);
        make.top.mas_equalTo(selfWeak.contentView.mas_top).offset(spaceX);
        make.height.mas_equalTo(deviceNameHeight);
        make.width.mas_equalTo(80.0f);
    }];
    
    [self.msgTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(selfWeak.msgDateLabel.mas_right);
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.height.mas_equalTo(deviceNameHeight);
        make.width.mas_equalTo(80.0f);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.size.mas_equalTo(CGSizeMake(iconSize, iconSize));
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.left.mas_equalTo(selfWeak.msgTimeLabel.mas_right).offset(spaceX);
    }];
    
    [self.lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.mas_equalTo(selfWeak.contentView);
        make.width.mas_equalTo(1);
        make.centerX.mas_equalTo(selfWeak.iconImageView.mas_centerX);
        
    }];
    
    /*
    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(selfWeak.iconImageView.mas_right).offset(spaceX);
        make.right.mas_equalTo(selfWeak.contentView.mas_right).offset(-spaceX);
        make.top.mas_equalTo(selfWeak.contentView.mas_top).offset(spaceX);
        make.height.mas_equalTo(deviceNameHeight);
    }];
    */
    
    [self.msgContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.iconImageView.mas_right).offset(spaceX);
        make.right.mas_equalTo(selfWeak.contentView.mas_right).offset(-spaceX);
        make.top.mas_equalTo(selfWeak.contentView.mas_top).offset(spaceX);
        make.bottom.mas_equalTo(selfWeak.contentView.mas_bottom).offset(-spaceX);
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

- (void)setDisplayMsg:(XHYMsg *)displayMsg{

    _displayMsg = displayMsg;
    UIColor *textColor = nil;
    
    if (_displayMsg.msgType) {
    
        textColor = [UIColor redColor];
        self.iconImageView.image = [[UIImage imageNamed:@"icon_timeline"] imageMaskWithColor:textColor];
        
    }else{
        
        textColor = [UIColor blackColor];
        self.iconImageView.image = [UIImage imageNamed:@"icon_timeline"];
    }
    
    self.msgTimeLabel.textColor = textColor;
    self.msgDateLabel.textColor = textColor;
    self.msgContentLabel.textColor = textColor;
    
    self.msgContentLabel.text = [displayMsg getMsgDisplayContent];
    
    if ([displayMsg.msgDate length]){
        
        self.msgDateLabel.text = [displayMsg.msgDate substringWithRange:NSMakeRange(0, 10)];
        self.msgTimeLabel.text = [displayMsg.msgDate substringFromIndex:11];
    }
}

@end

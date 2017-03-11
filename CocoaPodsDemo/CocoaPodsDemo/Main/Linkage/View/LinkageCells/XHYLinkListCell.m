//
//  XHYLinkListCell.m
//  XHYSparxSmart
//
//  Created by  XHY on 2016/10/12.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import "XHYLinkListCell.h"
#import "Masonry.h"
#import "UIColor+JKHEX.h"
#import "XHYFontTool.h"

@implementation XHYLinkListCell

- (UIImageView *)selectImageView{
    
    if (!_selectImageView) {
        
        _selectImageView = [[UIImageView alloc] init];
        _selectImageView.image = [UIImage imageNamed:@"login_privacy_unselect"];
    }
    
    return _selectImageView;
}

- (UILabel *)linkName{
    
    if (!_linkName) {
        
        _linkName = [[UILabel alloc] init];
        _linkName.textAlignment = NSTextAlignmentLeft;
        _linkName.backgroundColor = [UIColor clearColor];
        _linkName.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
    }
    
    return _linkName;
}

- (UILabel *)linkDevice0{
    
    if (!_linkDevice0) {
        
        _linkDevice0 = [[UILabel alloc] init];
        _linkDevice0.textAlignment = NSTextAlignmentLeft;
        _linkDevice0.backgroundColor = [UIColor clearColor];
        _linkDevice0.textColor = [UIColor jk_colorWithHexString:@"#9d9d9d"];
        _linkDevice0.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:14.0f];
    }
    
    return _linkDevice0;
}

- (UIImageView *)linkImageView{

    if (!_linkImageView) {
        
        _linkImageView = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:@"link_link"]];
    }
    
    return _linkImageView;
}

- (UILabel *)linkDevice1{
    
    if (!_linkDevice1) {
        
        _linkDevice1 = [[UILabel alloc] init];
        _linkDevice1.textAlignment = NSTextAlignmentLeft;
        _linkDevice1.backgroundColor = [UIColor clearColor];
        _linkDevice1.textColor = [UIColor jk_colorWithHexString:@"#9d9d9d"];
        _linkDevice1.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:14.0f];
    }
    
    return _linkDevice1;
}

- (void)setupSubViews{
    
    CGFloat spaceX = 8.0f;
    
    [self.contentView addSubview:self.selectImageView];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(self.contentView.mas_left);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(0.0f, 0.0f));
    }];
    
    [self.contentView addSubview:self.linkName];
    [self.linkName mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.selectImageView.mas_right).offset(spaceX);
        make.top.mas_equalTo(self.contentView.mas_top).offset(spaceX);
        make.right.mas_equalTo(self.contentView.mas_right);
        make.height.mas_equalTo(30.0f);
    }];
    
    [self.contentView addSubview:self.linkDevice0];
    [self.linkDevice0 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.linkName.mas_left);
        make.top.mas_equalTo(self.linkName.mas_bottom).offset(2);
        make.width.mas_equalTo(200.0f);
        make.height.mas_equalTo(30.0f);
    }];
    
    [self.contentView addSubview:self.linkImageView];
    [self.linkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.linkDevice0.mas_right);
        make.centerY.mas_equalTo(self.linkDevice0.mas_centerY);
        make.height.mas_equalTo(self.linkDevice0.mas_height);
        make.width.mas_equalTo(30.0f);
    }];
    
    [self.contentView addSubview:self.linkDevice1];
    [self.linkDevice1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.linkImageView.mas_right).offset(spaceX);
        make.right.mas_equalTo(self.contentView.mas_right);
        make.top.mas_equalTo(self.linkDevice0.mas_top);
        make.height.mas_equalTo(self.linkDevice0.mas_height);
    }];
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

- (void)setEditForSelect:(BOOL)edit{
    
    [self.selectImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        if (edit) {
            
            make.left.mas_equalTo(self.contentView.mas_left).offset(8);
            make.size.mas_equalTo(CGSizeMake(24.0f, 24.0f));
            
        }else{
            
            make.left.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(0.0f, 0.0f));
        }
    }];
    
    [self.contentView updateConstraints];
}

- (void)setCheck:(BOOL)check{
    
    _check = check;
    
    if (check) {
        
        self.selectImageView.image = [UIImage imageNamed:@"login_privacy_select"];
        
    }else{
        
        self.selectImageView.image = [UIImage imageNamed:@"login_privacy_unselect"];
    }
}

- (void)configDevice0Text:(NSString *)text{

    if ([text length]) {
        
        CGRect rect = [text boundingRectWithSize:CGSizeMake(ScreenWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:[XHYFontTool getDeaultFontBaseLanguageWithSize:14.0f],NSFontAttributeName, nil] context:nil];
        
        [self.linkDevice0 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(rect.size.width + 8);
        }];
    }
    
    [self.linkDevice0 setText:text];
}

@end

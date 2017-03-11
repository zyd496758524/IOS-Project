//
//  XHYLinkNameEditCell.m
//  XHYSparxSmart
//
//  Created by  XHY on 2016/10/12.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import "XHYLinkNameEditCell.h"

#import "Masonry.h"
#import "UIColor+JKHEX.h"
#import "XHYFontTool.h"

@implementation XHYLinkNameEditCell

- (UILabel *)linkEditName{
    
    if (!_linkEditName) {
        
        _linkEditName = [[UILabel alloc] init];
        _linkEditName.textAlignment = NSTextAlignmentLeft;
        _linkEditName.backgroundColor = [UIColor clearColor];
        _linkEditName.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _linkEditName.text = @"联动名称";
    }
    
    return _linkEditName;
}

- (UITextField *)linkNameField{

    if (!_linkNameField) {
    
        _linkNameField = [[UITextField alloc] init];
        _linkNameField.backgroundColor = [UIColor jk_colorWithHexString:@"#dfdfdf"];
        _linkNameField.borderStyle = UITextBorderStyleRoundedRect;
    }
    
    return _linkNameField;
}

- (void)setupSubViews{
    
    CGFloat spaceX = 8.0f;
    
    [self.contentView addSubview:self.linkEditName];
    [self.linkEditName mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.contentView.mas_left).offset(spaceX);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(80.0f);
        make.height.mas_equalTo(40.0f);
    }];
    
    [self.contentView addSubview:self.linkNameField];
    [self.linkNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.linkEditName.mas_right).offset(spaceX);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-spaceX);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(self.linkEditName.mas_height);
    }];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setupSubViews];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

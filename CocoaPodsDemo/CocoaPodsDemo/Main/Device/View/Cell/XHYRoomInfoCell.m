//
//  XHYRoomInfoCell.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/29.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYRoomInfoCell.h"
#import "XHYFontTool.h"

@implementation XHYRoomInfoCell

- (UILabel *)roomTitleLabel{

    if (!_roomTitleLabel) {
     
        _roomTitleLabel = [[UILabel alloc] init];
        _roomTitleLabel.backgroundColor = [UIColor clearColor];
        _roomTitleLabel.textAlignment = NSTextAlignmentLeft;
        _roomTitleLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _roomTitleLabel.textColor = [UIColor blackColor];
    }
    
    return _roomTitleLabel;
}

- (UILabel *)roomLabel{
    
    if (!_roomLabel) {
        
        _roomLabel = [[UILabel alloc] init];
        _roomLabel.backgroundColor = [UIColor clearColor];
        _roomLabel.textAlignment = NSTextAlignmentRight;
        _roomLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _roomLabel.textColor = [UIColor jk_colorWithHexString:@"#9d9d9d"];
    }
    
    return _roomLabel;
}

- (void)setupSubViews{

    [self.contentView addSubview:self.roomTitleLabel];
    [self.contentView addSubview:self.roomLabel];
    
    @JZWeakObj(self);
    [self.roomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make){
       
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.left.mas_equalTo(selfWeak.contentView.mas_left).offset(10);
        make.height.mas_equalTo(30.0f);
        make.width.mas_equalTo(ScreenWidth/2.0);
    }];
    [self.roomLabel mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.right.mas_equalTo(selfWeak.contentView.mas_right);
        make.height.mas_equalTo(30.0f);
        make.width.mas_equalTo(160.0f);
    }];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        [self setupSubViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

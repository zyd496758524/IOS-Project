//
//  XHYWeekSelectCell.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/10/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYWeekSelectCell.h"

#import "UIColor+JKHEX.h"
#import "UIImage+makeColor.h"
#import "XHYFontTool.h"

@implementation XHYWeekSelectCell

- (UILabel *)weekLabel{
    
    if (!_weekLabel) {
        
        _weekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _weekLabel.backgroundColor = [UIColor clearColor];
        _weekLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _weekLabel.textColor = [UIColor blackColor];
        _weekLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _weekLabel;
}

- (UIImageView *)selectImageView{

    if (!_selectImageView) {
        
        _selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"week_nsrmal"]];
    }
    
    return _selectImageView;
}

- (UILabel *)lineLabel{

    if (!_lineLabel) {
        
        _lineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _lineLabel.backgroundColor = [UIColor clearColor];
    }
    
    return _lineLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setupChildView];
    }
    
    return self;
}

- (void)setupChildView{
    
    [self.contentView addSubview:self.weekLabel];
    [self.contentView addSubview:self.selectImageView];
    [self.contentView addSubview:self.lineLabel];
    
    __weak typeof(self) weakWeekSelectCell = self;
    CGFloat spaceX = 8.0f;
    
    [self.weekLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakWeekSelectCell.contentView.mas_left).offset(spaceX);             //左 往右偏移 8
        make.right.mas_equalTo(weakWeekSelectCell.selectImageView.mas_right).offset(-spaceX);
        make.centerY.mas_equalTo(weakWeekSelectCell.contentView.mas_centerY);                      //垂直居中
        make.height.mas_equalTo(30.0f);                          //固定大小
    }];
    
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(weakWeekSelectCell.contentView.mas_right).offset(-spaceX);
        make.centerY.mas_equalTo(weakWeekSelectCell.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(12.0f, 12.0f));

    }];
    
    [self.lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakWeekSelectCell.contentView.mas_left).offset(spaceX);
        make.right.mas_equalTo(weakWeekSelectCell.contentView.mas_right).offset(-spaceX);
        make.bottom.mas_equalTo(weakWeekSelectCell.contentView.mas_bottom);
        make.height.mas_equalTo(0.5f);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setCheak:(BOOL)cheak{

    _cheak = cheak;
    
    if (_cheak) {
    
        self.selectImageView.image = [UIImage imageNamed:@"week_select"];
        
    }else{
        
        self.selectImageView.image = [UIImage imageNamed:@"week_normal"];
    }
}

@end

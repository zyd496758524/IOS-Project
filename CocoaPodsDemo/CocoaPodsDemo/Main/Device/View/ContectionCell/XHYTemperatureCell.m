//
//  XHYTemperatureCell.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYTemperatureCell.h"
#import "Masonry.h"
#import "XHYFontTool.h"

@implementation XHYTemperatureCell

- (UIImageView *)iconImageView{
    
    if (!_iconImageView) {
        
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _iconImageView;
}

- (UIImageView *)temIconImageView{
    
    if (!_temIconImageView) {
        
        _temIconImageView = [[UIImageView alloc] init];
        _temIconImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _temIconImageView;
}


- (UILabel *)temperatureLabel{
    
    if (!_temperatureLabel) {
        
        _temperatureLabel = [[UILabel alloc] init];
        _temperatureLabel.backgroundColor = [UIColor clearColor];
        _temperatureLabel.textAlignment = NSTextAlignmentLeft;
        _temperatureLabel.textColor = [UIColor blackColor];
        _temperatureLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:14.0f];
        _temperatureLabel.text = @"21℃";
    }
    return _temperatureLabel;
}

- (UIImageView *)humIconImageView{
    
    if (!_humIconImageView) {
        
        _humIconImageView = [[UIImageView alloc] init];
        _humIconImageView.backgroundColor = [UIColor clearColor];
    }
    return _humIconImageView;
}

- (UILabel *)humidityLabel{
    
    if (!_humidityLabel){
        
        _humidityLabel = [[UILabel alloc] init];
        _humidityLabel.backgroundColor = [UIColor clearColor];
        _humidityLabel.textAlignment = NSTextAlignmentCenter;
        _humidityLabel.textColor = [UIColor blackColor];
        _humidityLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:14.0f];
        _humidityLabel.text = @"75%";
    }
    
    return _humidityLabel;
}

- (void)setupSubviews{
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 6.0f;
    self.contentView.layer.masksToBounds = YES;
    
    [self.contentView addSubview:self.iconImageView];
    
    [self.contentView addSubview:self.temIconImageView];
    [self.contentView addSubview:self.temperatureLabel];
    
    [self.contentView addSubview:self.humIconImageView];
    [self.contentView addSubview:self.humidityLabel];
    
    @JZWeakObj(self);
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.mas_equalTo(selfWeak.contentView.mas_left).offset(8);
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(primaryIconSize, primaryIconSize));
    }];
    
    [self.temIconImageView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.mas_equalTo(selfWeak.iconImageView.mas_right).offset(8);
        make.top.mas_equalTo(selfWeak.iconImageView.mas_top).offset(-8);
        make.size.mas_equalTo(CGSizeMake(primaryIconSize / 2, primaryIconSize / 2));
    }];
    [self.temperatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(selfWeak.temIconImageView.mas_right).offset(8);
        make.top.mas_equalTo(selfWeak.temIconImageView.mas_top);
        make.right.mas_equalTo(selfWeak.contentView.mas_right);
        make.height.mas_equalTo(selfWeak.temIconImageView.mas_height);
    }];
    
    [self.humIconImageView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.mas_equalTo(selfWeak.iconImageView.mas_right).offset(8);
        make.bottom.mas_equalTo(selfWeak.iconImageView.mas_bottom).offset(8);
        make.size.mas_equalTo(CGSizeMake(primaryIconSize / 2, primaryIconSize / 2));
    }];
    [self.humidityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.humIconImageView.mas_right).offset(8);
        make.top.mas_equalTo(selfWeak.humIconImageView.mas_top);
        make.right.mas_equalTo(selfWeak.contentView.mas_right);
        make.height.mas_equalTo(selfWeak.humIconImageView.mas_height);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]){
        
        [self setupSubviews];
    }
    
    return self;
}

@end

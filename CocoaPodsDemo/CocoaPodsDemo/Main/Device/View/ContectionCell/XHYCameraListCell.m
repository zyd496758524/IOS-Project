//
//  XHYCameraListCell.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYCameraListCell.h"
#import "Masonry.h"
#import "XHYFontTool.h"

@implementation XHYCameraListCell

- (UIImageView *)iconImageView{

    if (!_iconImageView) {
        
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _iconImageView;
}

- (UILabel *)cameraNameLabel{

    if (!_cameraNameLabel) {
        
        _cameraNameLabel = [[UILabel alloc] init];
        _cameraNameLabel.backgroundColor = [UIColor clearColor];
        _cameraNameLabel.textAlignment = NSTextAlignmentCenter;
        _cameraNameLabel.textColor = [UIColor blackColor];
        _cameraNameLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _cameraNameLabel.text = @"网络摄像头";
    }
    
    return _cameraNameLabel;
}

- (UILabel *)cameraFloorLabel{
    
    if (!_cameraFloorLabel){
        
        _cameraFloorLabel = [[UILabel alloc] init];
        _cameraFloorLabel.backgroundColor = [UIColor clearColor];
        _cameraFloorLabel.textAlignment = NSTextAlignmentCenter;
        _cameraFloorLabel.textColor = [UIColor blackColor];
        _cameraFloorLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:14.0f];
        _cameraFloorLabel.text = @"二楼/客厅";
    }
    
    return _cameraFloorLabel;
}

- (void)setupSubviews{

    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 6.0f;
    self.contentView.layer.masksToBounds = YES;
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.cameraNameLabel];
    [self.contentView addSubview:self.cameraFloorLabel];
    
    @JZWeakObj(self);
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.mas_equalTo(selfWeak.contentView.mas_centerX);
        make.top.mas_equalTo(selfWeak.contentView.mas_top).offset(8);
        make.size.mas_equalTo(CGSizeMake(40.0f, 40.0f));
    }];
    
    [self.cameraNameLabel mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.top.mas_equalTo(selfWeak.iconImageView.mas_bottom);
        make.centerX.mas_equalTo(selfWeak.contentView.mas_centerX);
        make.width.mas_equalTo(selfWeak.contentView.mas_width);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.cameraFloorLabel mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.top.mas_equalTo(selfWeak.cameraNameLabel.mas_bottom);
        make.centerX.mas_equalTo(selfWeak.contentView.mas_centerX);
        make.width.mas_equalTo(selfWeak.contentView.mas_width);
        make.height.mas_equalTo(20.0f);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]){
        
        [self setupSubviews];
    }
    
    return self;
}

@end

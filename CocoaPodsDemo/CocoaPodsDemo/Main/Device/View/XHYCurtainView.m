//
//  XHYCurtainView.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/5.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYCurtainView.h"

@interface XHYCurtainView()

@property(nonatomic,strong) UIImageView *leftImageView;
@property(nonatomic,strong) UIImageView *rightImageView;

@end

static const CGFloat titleHeght = 10.0f;

@implementation XHYCurtainView

- (UIImageView *)leftImageView{

    if (!_leftImageView) {
    
        _leftImageView = [[UIImageView alloc] init];
        _leftImageView.backgroundColor = [UIColor redColor];
    }
    
    return _leftImageView;
}

- (UIImageView *)rightImageView{
    
    if (!_rightImageView) {
        
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.backgroundColor = [UIColor greenColor];
    }
    
    return _rightImageView;
}

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]){
        
        [self setupSubViews];
    }
    
    return self;
}

- (void)setupSubViews{
    
    [self addSubview:self.leftImageView];
    [self addSubview:self.rightImageView];
    CGRect bounds = self.bounds;
    CGFloat curtainWidth = CGRectGetWidth(bounds) / 2;
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top).offset(titleHeght);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-titleHeght);
        make.width.mas_equalTo(curtainWidth);
    }];
    
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(self.mas_top).offset(titleHeght);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-titleHeght);
        make.width.mas_equalTo(self.leftImageView.mas_width);
    }];
}

- (void)setCurtainProgress:(CGFloat)progress{

    if (progress < 0 || progress > 1.0f){
        
        return;
    }
    
    CGFloat spacx = 20.0f;
    CGFloat curtainWidth = ScreenWidth / 2;
    
    [self.leftImageView mas_updateConstraints:^(MASConstraintMaker *make){
        
        make.width.mas_equalTo(spacx + (curtainWidth - spacx) * progress);
    }];
    [self updateConstraints];
    [self layoutIfNeeded];
}

@end

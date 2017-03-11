//
//  XHYFooterAddView.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/24.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYFooterAddView.h"
#import "UIColor+JKHEX.h"
#import "UIImage+makeColor.h"

@implementation XHYFooterAddView

+(instancetype)dequeueFooterAddViewFromRootTableView:(UITableView *)tableView{
    
    static NSString *footerID = @"XHYFooterAddView";
    
    XHYFooterAddView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerID];
    
    if (footerView == nil) {
        
        footerView = [[XHYFooterAddView alloc] initWithReuseIdentifier:footerID];
    }
    
    return footerView;
}

- (UIButton *)addBtn{

    if (!_addBtn) {
    
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[[UIImage imageNamed:@"add"] imageMaskWithColor:MainColor] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(footerViewAddBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addBtn;
}

- (UILabel *)bottomLineLabel{
    
    if (!_bottomLineLabel) {
        
        _bottomLineLabel = [[UILabel alloc] init];
        _bottomLineLabel.backgroundColor = [UIColor jk_colorWithHexString:@"#E4E3E5"];
    }
    
    return _bottomLineLabel;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithReuseIdentifier:reuseIdentifier]){
        
        //self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self setupSubViews];
    }
    
    return self;
}

- (void)layoutSubviews{

    [super layoutSubviews];
    CGRect rect = self.bounds;
    rect.size.height -= 20;
    
    self.contentView.frame = rect;
}

- (void)setupSubViews{

    [self.contentView addSubview:self.addBtn];
    [self.contentView addSubview:self.bottomLineLabel];
    
    @JZWeakObj(self);
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.right.mas_equalTo(selfWeak.contentView.mas_right).offset(-8);
        make.size.mas_equalTo(CGSizeMake(36.0f, 36.0f));
    }];
    
    [self.bottomLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.contentView.mas_left);
        make.right.mas_equalTo(selfWeak.contentView.mas_right);
        make.top.mas_equalTo(selfWeak.contentView.mas_top);
        make.height.mas_equalTo(0.6f);
    }];
}

- (void)footerViewAddBtnClick:(id)sender{

    if (self.delegate && [self.delegate respondsToSelector:@selector(XHYFooterAddViewAddBtnClick:)]) {
        
        [self.delegate XHYFooterAddViewAddBtnClick:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

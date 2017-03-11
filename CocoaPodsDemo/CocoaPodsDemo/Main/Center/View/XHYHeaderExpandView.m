//
//  XHYHeaderExpandView.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/22.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYHeaderExpandView.h"
#import "XHYFontTool.h"
#import "UIColor+JKHEX.h"
#import "Masonry.h"

@implementation XHYHeaderExpandView

+(instancetype)dequeueHeaderExpandViewFromRootTableView:(UITableView *)tableView{

    static NSString *headerID = @"XHYHeaderExpandView";
    
    XHYHeaderExpandView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerID];
    
    if (headerView == nil) {
        
        headerView = [[XHYHeaderExpandView alloc] initWithReuseIdentifier:headerID];
    }
    
    return headerView;
}

- (UIButton *)selectBtn{

    if (!_selectBtn) {
    
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setImage:[UIImage imageNamed:@"device_check_normal"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"device_check_select"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectBtn;
}

- (UILabel *)titleLabel{

    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = MainColor;
        _titleLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:18.0f];
    }
    
    return _titleLabel;
}

- (UIImageView *)expendImageView{

    if (!_expendImageView) {
        
        _expendImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _expendImageView.image = [UIImage imageNamed:@"icon_disclosureIndicator"];
    }
    
    return _expendImageView;
}

- (UILabel *)topLineLabel{

    if (!_topLineLabel) {
        
        _topLineLabel = [[UILabel alloc] init];
        _topLineLabel.backgroundColor = [UIColor jk_colorWithHexString:@"#E4E3E5"];
    }
    
    return _topLineLabel;
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
        
        self.contentView.backgroundColor = [UIColor jk_colorWithHexString:@"#eeeeee"];
        
        [self setupSubViews];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expendBtnClick:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        
        [self.titleLabel addGestureRecognizer:tap];
        self.titleLabel.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)setupSubViews{

    [self.contentView addSubview:self.selectBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.expendImageView];
    [self.contentView addSubview:self.topLineLabel];
    [self.contentView addSubview:self.bottomLineLabel];
    
    @JZWeakObj(self);
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(selfWeak.contentView.mas_left).offset(8);
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(0.0f, 0.0f));
    }];
    
    [self.expendImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(selfWeak.contentView.mas_right).offset(-8 * 2);
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(9.0f, 14.0f));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.selectBtn.mas_right).offset(8);
        make.right.mas_equalTo(selfWeak.expendImageView.mas_left).offset(-8);
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.height.mas_equalTo(30.0f);
    }];
    
    [self.topLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.contentView.mas_left);
        make.right.mas_equalTo(selfWeak.contentView.mas_right);
        make.top.mas_equalTo(selfWeak.contentView.mas_top);
        make.height.mas_equalTo(0.8f);
    }];
    
    [self.bottomLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.contentView.mas_left);
        make.right.mas_equalTo(selfWeak.contentView.mas_right);
        make.bottom.mas_equalTo(selfWeak.contentView.mas_bottom);
        make.height.mas_equalTo(0.8f);
    }];
}

- (void)setIsSelect:(BOOL)isSelect{

    _isSelect = isSelect;
    self.selectBtn.selected = isSelect;
}

- (void)setIsExpend:(BOOL)isExpend{

    _isExpend = isExpend;
    self.bottomLineLabel.hidden = _isExpend;
    
    if (!_isExpend) {
        
        //没有展开
        [UIView animateWithDuration:0.3f animations:^{
            
            self.expendImageView.transform = CGAffineTransformMakeRotation(0);
            
        } completion:^(BOOL finished) {
            
        }];
        
    }else {
        
        //展开
        [UIView animateWithDuration:0.3f animations:^{
            
            self.expendImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)beginSelect:(BOOL)begin{

    [self.selectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        
        if (begin) {
            
            make.size.mas_equalTo(CGSizeMake(26.0f, 26.0f));
            
        }else{
            
            make.size.mas_equalTo(CGSizeMake(0.0f, 0.0f));
        }
    }];
    
    [UIView animateWithDuration:0.5F animations:^{
        
        [self.contentView updateConstraints];
        [self.contentView layoutIfNeeded];
    }];
}

- (void)expendBtnClick:(UITapGestureRecognizer *)Recognizer{
    
    self.isExpend = !self.isExpend;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(XHYHeaderExpandViewExpend:)]) {
        
        [self.delegate XHYHeaderExpandViewExpend:self];
    }
}

- (void)selectBtnClick:(UIButton *)selectBtn{
    
    self.selectBtn.selected = !self.selectBtn.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(XHYHeaderExpandView:didSelectBtn:)]) {
        
        [self.delegate XHYHeaderExpandView:self didSelectBtn:self.selectBtn.selected];
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

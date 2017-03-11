//
//  XHYLinkEditCell.m
//  XHYSparxSmart
//
//  Created by  XHY on 2016/10/12.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import "XHYLinkEditCell.h"
#import "Masonry.h"
#import "UIColor+JKHEX.h"
#import "XHYFontTool.h"

@implementation XHYLinkEditCell

- (UIButton *)deleteBtn{

    if (!_deleteBtn) {
     
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"link_delete"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _deleteBtn;
}

- (UIImageView *)deviceImageView{

    if (!_deviceImageView) {
     
        _deviceImageView = [[UIImageView alloc] init];
        _deviceImageView.backgroundColor = [UIColor whiteColor];
        _deviceImageView.layer.cornerRadius = 6.0f;
    }
    
    return _deviceImageView;
}

- (UILabel *)deviceName{
    
    if (!_deviceName) {
        
        _deviceName = [[UILabel alloc] init];
        _deviceName.textAlignment = NSTextAlignmentLeft;
        _deviceName.backgroundColor = [UIColor clearColor];
        _deviceName.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
    }
    
    return _deviceName;
}

- (UIImageView *)deviceIndicatorImageView{

    if (!_deviceIndicatorImageView) {
        
        _deviceIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_disclosureIndicator"]];
    }
    
    return _deviceIndicatorImageView;
}

- (UIImageView *)actionImageView{
    
    if (!_actionImageView) {
        
        _actionImageView = [[UIImageView alloc] init];
        _actionImageView.backgroundColor = [UIColor whiteColor];
        _actionImageView.layer.cornerRadius = 6.0f;
    }
    
    return _actionImageView;
}

- (UILabel *)actionName{
    
    if (!_actionName) {
        
        _actionName = [[UILabel alloc] init];
        _actionName.textAlignment = NSTextAlignmentLeft;
        _actionName.backgroundColor = [UIColor clearColor];
        _actionName.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
    }
    
    return _actionName;
}

- (UIImageView *)actionIndicatorImageView{
    
    if (!_actionIndicatorImageView) {
        
        _actionIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_disclosureIndicator"]];
    }
    
    return _actionIndicatorImageView;
}

- (void)setupSubViews{
    
    CGFloat spaceX = 8.0f;
    
    [self.contentView addSubview:self.deleteBtn];
    
    [self.contentView addSubview:self.deviceImageView];
    [self.deviceImageView addSubview:self.deviceName];
    [self.deviceImageView addSubview:self.deviceIndicatorImageView];
    
    [self.contentView addSubview:self.actionImageView];
    [self.actionImageView addSubview:self.actionName];
    [self.actionImageView addSubview:self.actionIndicatorImageView];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left);
        make.size.mas_equalTo(CGSizeMake(0.0f, 0.0f));
    }];
    
    [self.actionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-spaceX);
        make.size.mas_equalTo(CGSizeMake(100.0f, 40.0f));
    }];
    [self.actionIndicatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.actionImageView.mas_centerY);
        make.right.mas_equalTo(self.actionImageView.mas_right).offset(-spaceX);
        make.size.mas_equalTo(CGSizeMake(9.0f, 14.0f));
    }];
    [self.actionName mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.actionImageView.mas_centerY);
        make.left.mas_equalTo(self.actionImageView.mas_left).offset(spaceX);
        make.right.mas_equalTo(self.actionIndicatorImageView.mas_left);
        make.height.mas_equalTo(self.actionImageView.mas_height);
    }];
    
    [self.deviceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.deleteBtn.mas_right).offset(spaceX);
        make.right.mas_equalTo(self.actionImageView.mas_left).offset(-spaceX);
        make.height.mas_equalTo(self.actionImageView.mas_height);
    }];
    [self.deviceIndicatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.deviceImageView.mas_centerY);
        make.right.mas_equalTo(self.deviceImageView.mas_right).offset(-spaceX);
        make.size.mas_equalTo(CGSizeMake(9.0f, 14.0f));
    }];
    [self.deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.deviceImageView.mas_centerY);
        make.left.mas_equalTo(self.deviceImageView.mas_left).offset(spaceX);
        make.right.mas_equalTo(self.deviceIndicatorImageView.mas_left);
        make.height.mas_equalTo(self.deviceImageView.mas_height);
    }];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setupSubViews];
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.userInteractionEnabled = YES;
        
        self.deviceImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *deviceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deviceTapGestureRecognizer:)];
        deviceTap.delegate = self;
        deviceTap.numberOfTapsRequired = 1;
        deviceTap.numberOfTouchesRequired = 1;
        [self.deviceImageView addGestureRecognizer:deviceTap];
       
        self.actionImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *actionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGestureRecognizer:)];
        actionTap.delegate = self;
        actionTap.numberOfTapsRequired = 1;
        actionTap.numberOfTouchesRequired = 1;
        
        [self.actionImageView addGestureRecognizer:actionTap];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditForDelete:(BOOL)edit{

    [self.deleteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        
        if (edit) {
            
            make.left.equalTo(self.contentView).offset(8);
            make.size.mas_equalTo(CGSizeMake(36.0f, 36.0f));
            
        }else{
            
            make.left.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(0.0f, 0.0f));
        }
    }];
    
    [self.contentView updateConstraints];
}

- (void)deleteBtnClick:(id)sender{

    if (self.delegate && [self.delegate respondsToSelector:@selector(XHYLinkEditCell:didDeleteLink:)]) {
        
        [self.delegate XHYLinkEditCell:self didDeleteLink:self.indexPath];
    }
}

- (void)setActionViewHidden:(BOOL)hidden{

    self.actionImageView.hidden = hidden;
    self.actionName.hidden = hidden;
    self.actionIndicatorImageView.hidden = hidden;
}

- (void)deviceTapGestureRecognizer:(UITapGestureRecognizer *)Recognizer{

    if (self.delegate && [self.delegate respondsToSelector:@selector(XHYLinkEditCell:deviceDidSelectLink:)]) {
        
       [self.delegate XHYLinkEditCell:self deviceDidSelectLink:self.indexPath];
    }
}

- (void)actionTapGestureRecognizer:(UITapGestureRecognizer *)Recognizer{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(XHYLinkEditCell:actionDidSelectLink:)]) {
        
        [self.delegate XHYLinkEditCell:self actionDidSelectLink:self.indexPath];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    //NSLog(@"XHYLinkEditCell --- XHYLinkEditCell shouldReceiveTouch");
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewLabel"]){
        
        return NO;
    }
    
    return YES;
}

@end

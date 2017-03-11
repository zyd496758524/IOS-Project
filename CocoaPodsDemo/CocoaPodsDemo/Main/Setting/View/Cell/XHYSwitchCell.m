//
//  XHYSwitchCell.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2017/2/21.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYSwitchCell.h"
#import "XHYFontTool.h"

@implementation XHYSwitchCell

- (UILabel *)setItemTitleLabel{
    
    if (!_setItemTitleLabel){
        
        _setItemTitleLabel = [[UILabel alloc] init];
        _setItemTitleLabel.backgroundColor = [UIColor clearColor];
        _setItemTitleLabel.textAlignment = NSTextAlignmentLeft;
        _setItemTitleLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0F];
    }
    
    return _setItemTitleLabel;
}

- (UISwitch *)valueSwitch{
    
    if (!_valueSwitch) {
        
        _valueSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_valueSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _valueSwitch;
}

- (void)setupSubViews{
    
    [self.contentView addSubview:self.setItemTitleLabel];
    [self.setItemTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.contentView.mas_left).offset(10.0f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(200.0f, 30.0f));
    }];
    self.accessoryView = self.valueSwitch;
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

- (void)valueChanged:(id)sender{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(XHYYWarningSetCell:ValueChange:indexPath:)]) {
        
        [self.delegate XHYYWarningSetCell:self ValueChange:self.valueSwitch.on indexPath:self.indexPath];
    }
}
@end

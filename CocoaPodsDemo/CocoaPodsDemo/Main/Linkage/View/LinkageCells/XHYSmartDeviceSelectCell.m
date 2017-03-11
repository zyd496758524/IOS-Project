//
//  XHYSmartDeviceSelectCell.m
//  CocoaPodsDemo
//
//  Created by Zyd on 2017/1/16.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import "XHYSmartDeviceSelectCell.h"

static NSString * const SmartDeviceSelectCellIdentifier = @"SmartDeviceSelectCellIdentifier";

@implementation XHYSmartDeviceSelectCell

+ (instancetype)dequeueSmartDeviceCellFromRootTableView:(UITableView *)tableView{
    
    XHYSmartDeviceSelectCell *cell = (XHYSmartDeviceSelectCell *)[tableView dequeueReusableCellWithIdentifier:SmartDeviceSelectCellIdentifier];
    
    if (!cell) {
        
        cell = [[XHYSmartDeviceSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SmartDeviceSelectCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}


- (UIImageView *)selectImageView{
    
    if (!_selectImageView) {
        
        _selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"device_check_normal"]];
        _selectImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _selectImageView;
}

- (void)setupSmartDeviceSelectView{

    [self.contentView addSubview:self.selectImageView];
    
    @JZWeakObj(self);
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(selfWeak.contentView.mas_right).offset(-8);             //左 往右偏移 8
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);                      //垂直居中
        make.size.mas_equalTo(CGSizeMake(selectImageSize, selectImageSize));             //固定大小
    }];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self){
        
        [self setupSmartDeviceSelectView];
    }
    
    return self;
}

- (void)setDeviceSelect:(BOOL)deviceSelect{

    if (deviceSelect) {
        
        [self.selectImageView setImage:[UIImage imageNamed:@"device_check_select"]];
        
    }else{
        [self.selectImageView setImage:[UIImage imageNamed:@"device_check_normal"]];
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

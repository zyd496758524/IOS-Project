//
//  XHYSmartDeviceCell.m
//  XHYSparxSmart
//
//  Created by  XHY on 16/7/22.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import "XHYSmartDeviceCell.h"
#import "UIColor+JKHEX.h"
#import "UIImage+makeColor.h"
#import "XHYFontTool.h"

static const CGFloat powerIconSize = 20.0f;     //
static const CGFloat nameLabelHeight = 24.0f;   //设备名称高度
static const CGFloat spaceX = 8.0f;             //操作按钮间隙

static NSString * const SmartDeviceCellIdentifier = @"SmartDeviceCellIdentifier";

@interface XHYSmartDeviceCell(){
    
}

@property(nonatomic,strong) UIImageView *loadingImageView;

@end

@implementation XHYSmartDeviceCell

#pragma mark ----- getters

- (UIImageView *)iconImageView{
    
    if (!_iconImageView) {
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _iconImageView;
}

- (UILabel *)deviceNameLabel{
    
    if (!_deviceNameLabel) {
        
        _deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _deviceNameLabel.backgroundColor = [UIColor clearColor];
        _deviceNameLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:16.0f];
        _deviceNameLabel.textColor = [UIColor blackColor];
        _deviceNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _deviceNameLabel;
}

- (UILabel *)deviceFloorLabel{
    
    if (!_deviceFloorLabel) {
        
        _deviceFloorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _deviceFloorLabel.backgroundColor = [UIColor clearColor];
        _deviceFloorLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:14.0f];
        _deviceFloorLabel.textColor = [UIColor jk_colorWithHexString:@"#a7a7a7"];
    }
    
    return _deviceFloorLabel;
}

- (UIImageView *)powerImageView{

    if (!_powerImageView) {
        
        _powerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _powerImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _powerImageView;
}

- (UIImageView *)locationImageView{

    if (!_locationImageView) {
        
        _locationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _locationImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _locationImageView;
}

- (UILabel *)powerLabel{

    if (!_powerLabel) {
        
        _powerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _powerLabel.backgroundColor = [UIColor clearColor];
        _powerLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:10.0f];
        _powerLabel.textColor = [UIColor blackColor];
        _powerLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return _powerLabel;
}

- (UIImageView *)workStatusImageView{

    if (!_workStatusImageView) {
        
        _workStatusImageView = [[UIImageView alloc] init];
        _workStatusImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _workStatusImageView;
}

+ (instancetype)dequeueSmartDeviceCellFromRootTableView:(UITableView *)tableView{
    
    XHYSmartDeviceCell *cell = (XHYSmartDeviceCell *)[tableView dequeueReusableCellWithIdentifier:SmartDeviceCellIdentifier];
    
    if (!cell) {
        
        cell = [[XHYSmartDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SmartDeviceCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.layer.cornerRadius = 6.0f;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.clipsToBounds = YES;
        self.contentView.backgroundColor = [UIColor whiteColor];

        [self setupChildView];
    }
    
    return self;
}

- (void)setupChildView{
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.deviceNameLabel];
    
    [self.contentView addSubview:self.locationImageView];
    [self.contentView addSubview:self.deviceFloorLabel];
    
    [self.contentView addSubview:self.powerImageView];
    [self.contentView addSubview:self.powerLabel];
    
    [self.contentView addSubview:self.workStatusImageView];
    
    @JZWeakObj(self);
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.mas_equalTo(selfWeak.contentView.mas_left).offset(spaceX);             //左 往右偏移 8
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);                      //垂直居中
        make.size.mas_equalTo(CGSizeMake(primaryIconSize, primaryIconSize));             //固定大小
    }];

    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.top.mas_equalTo(selfWeak.iconImageView.mas_top).offset(-spaceX/2);
        make.height.mas_equalTo(nameLabelHeight);
        make.left.mas_equalTo(selfWeak.iconImageView.mas_right).offset(spaceX);
        make.width.mas_equalTo(@200.0f);
    }];
    
    [self.locationImageView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.mas_equalTo(selfWeak.deviceNameLabel.mas_left);
        make.top.mas_equalTo(selfWeak.deviceNameLabel.mas_bottom).offset(8);
        make.size.mas_equalTo(CGSizeMake(nameLabelHeight - 10, nameLabelHeight - 10));
    }];
    
    [self.deviceFloorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(selfWeak.locationImageView.mas_right).offset(2);
        make.centerY.mas_equalTo(selfWeak.locationImageView.mas_centerY);
        make.height.mas_equalTo(nameLabelHeight);
        make.width.mas_equalTo(@200.0f);
    }];
    
    [self.powerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(selfWeak.contentView.mas_right);
        make.top.mas_equalTo(selfWeak.contentView.mas_top);
        make.size.mas_equalTo(CGSizeMake(powerIconSize, powerIconSize));
    }];
    
    [self.powerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.mas_equalTo(selfWeak.powerImageView.mas_left).offset(-4.0f);
        make.centerY.mas_equalTo(selfWeak.powerImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(powerIconSize, powerIconSize));
    }];
    
    [self.workStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(selfWeak.contentView.mas_right).offset(-spaceX);
        make.bottom.mas_equalTo(selfWeak.contentView.mas_bottom).offset(-spaceX);
        make.size.mas_equalTo(CGSizeMake(powerIconSize, powerIconSize));
    }];
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    bounds.origin.x += marginSpaceSize;
    bounds.size.width -= marginSpaceSize * 2;
    bounds.origin.y += 5;
    bounds.size.height -= 10;
    self.contentView.frame = bounds;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        
        [self.contentView setBackgroundColor:[UIColor grayColor]];
        
    }else{
        
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setDisplaySmartDevice:(XHYSmartDevice *)displaySmartDevice{

    _displaySmartDevice = displaySmartDevice;
    
    self.iconImageView.image = [UIImage imageNamed:[displaySmartDevice getDeviceIconName]];
    self.deviceNameLabel.text = [displaySmartDevice.customDeviceName length]?displaySmartDevice.customDeviceName:displaySmartDevice.deviceName;
    
    NSString *floorStr = [displaySmartDevice getFloorRoomDescription];
    self.deviceFloorLabel.text = [floorStr length] ? floorStr : @"";
    self.locationImageView.image = [floorStr length] ? [UIImage imageNamed:@"device_location"] : nil;
    
    BOOL isNeed = [displaySmartDevice isNeedDisplayWorkStatus];
    self.workStatusImageView.hidden = !isNeed;
    if (isNeed) {
        
        if (displaySmartDevice.deviceOnlineStatus && displaySmartDevice.deviceWorkStatus){
            
            self.workStatusImageView.image = [[UIImage imageNamed:@"device_workStatus"] imageMaskWithColor:MainColor];
            
        }else{
            
            self.workStatusImageView.image = [[UIImage imageNamed:@"device_workStatus"] imageMaskWithColor:[UIColor redColor]];
        }
    }
    
    self.powerImageView.hidden = [displaySmartDevice isStrongPowerDevice];
    
    if (displaySmartDevice.powerStatus){
        
        self.powerImageView.image = [UIImage imageNamed:@"device_power"];
        
    }else{
        
        self.powerImageView.image = nil;
    }
}

@end

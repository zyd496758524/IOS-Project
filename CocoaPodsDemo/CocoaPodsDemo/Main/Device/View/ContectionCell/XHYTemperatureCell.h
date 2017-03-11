//
//  XHYTemperatureCell.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHYTemperatureCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView *iconImageView;

@property(nonatomic,strong) UIImageView *temIconImageView;
@property(nonatomic,strong) UILabel *temperatureLabel;

@property(nonatomic,strong) UIImageView *humIconImageView;
@property(nonatomic,strong) UILabel *humidityLabel;

@end

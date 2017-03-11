//
//  XHYCameraListCell.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHYCameraListCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView *iconImageView;

@property(nonatomic,strong) UIImageView *temImageView;
@property(nonatomic,strong) UIImageView *humImageView;

@property(nonatomic,strong) UILabel *cameraNameLabel;
@property(nonatomic,strong) UILabel *cameraFloorLabel;

@end

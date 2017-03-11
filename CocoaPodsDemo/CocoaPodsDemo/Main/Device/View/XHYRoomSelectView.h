//
//  XHYRoomSelectView.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/29.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHYRoomSelectView : UIView

@property (nonatomic, strong) NSArray * dataSource;

@property (nonatomic, strong) NSString * defaultStr;

@property (nonatomic, copy) void (^roomDidSelect)(NSString * floorRoom);

- (void)show;

@end

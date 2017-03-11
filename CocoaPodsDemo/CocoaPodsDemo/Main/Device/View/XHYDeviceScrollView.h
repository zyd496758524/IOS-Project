//
//  XHYDeviceScrollView.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/6.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>


@class XHYDeviceScrollView;
@class XHYSmartDevice;

@protocol XHYDeviceScrollViewDelegate <NSObject>

- (void)xhy_deviceScrollView:(XHYDeviceScrollView *)scrollView didScrollToItemAtIndex:(NSInteger)index;

- (void)xhy_deviceScrollView:(XHYDeviceScrollView *)scrollView didSelectItem:(XHYSmartDevice *)smartDecice;

@end

@interface XHYDeviceScrollView : UIView

@property(nonatomic,weak) id<XHYDeviceScrollViewDelegate> delegate;
@property(nonatomic,strong) NSArray *roomArray;

- (void)setCurrentPage:(NSInteger)Page;

//刷新设备状态 是否需要置顶
- (void)reloadDeviceDetailInfo:(XHYSmartDevice *)msgDevice needStick:(BOOL)stick;

@end

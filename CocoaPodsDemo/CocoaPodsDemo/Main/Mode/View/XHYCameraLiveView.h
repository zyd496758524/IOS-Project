//
//  XHYCameraLiveView.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/26.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UAnYan/UAnYan.h>

@protocol XHYCameraLiveViewDelegate <NSObject>

- (void)clarityValueSelect:(NSInteger)clarity; // 0 标清 1 高清

@end

@interface XHYCameraLiveView : AyMovieGLView

@property(nonatomic,weak) id<XHYCameraLiveViewDelegate> claritydelegate;
@property(nonatomic,strong) UILabel *speedLabel;
@property(nonatomic,strong) UISegmentedControl *claritySegmentedControl;

@end

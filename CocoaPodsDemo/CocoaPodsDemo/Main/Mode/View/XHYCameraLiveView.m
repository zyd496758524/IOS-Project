//
//  XHYCameraLiveView.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/26.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYCameraLiveView.h"
#import "XHYFontTool.h"

@implementation XHYCameraLiveView
@synthesize claritydelegate;

- (UILabel *)speedLabel{

    if (!_speedLabel) {
     
        _speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 20.0f)];
        _speedLabel.backgroundColor = [UIColor clearColor];
        _speedLabel.textColor = [UIColor whiteColor];
        _speedLabel.textAlignment = NSTextAlignmentLeft;
        _speedLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:10.0F];
    }
    
    return _speedLabel;
}

- (UISegmentedControl *)claritySegmentedControl{

    if (!_claritySegmentedControl) {
        
        _claritySegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"标清",@"高清"]];
        _claritySegmentedControl.tintColor = [UIColor whiteColor];
        [_claritySegmentedControl addTarget:self action:@selector(clarityValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _claritySegmentedControl;
}

- (id)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.speedLabel];
        [self addSubview:self.claritySegmentedControl];
        [self.claritySegmentedControl setSelectedSegmentIndex:0];
    }
    
    return self;
}

- (void)layoutSubviews{

    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    [self.claritySegmentedControl setFrame:CGRectMake(CGRectGetWidth(bounds) - 90.0f, 5.0f, 80.0f, 30.0f)];
}

- (void)clarityValueChanged:(id)sender{

    if (self.claritydelegate && [self.claritydelegate respondsToSelector:@selector(clarityValueSelect:)]) {
        
        [self.claritydelegate clarityValueSelect:self.claritySegmentedControl.selectedSegmentIndex];
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

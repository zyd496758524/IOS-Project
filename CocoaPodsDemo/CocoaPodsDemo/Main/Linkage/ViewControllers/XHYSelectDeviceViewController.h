//
//  XHYSelectDeviceViewController.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/18.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYBaseViewController.h"

typedef enum : NSUInteger {
    XHYDeviceSelect_Multi,
    XHYDeviceSelect_Radio,
} XHYDeviceSelectType;

typedef void(^selectDeviceBlock)(NSArray *selectDeviceArray);

@interface XHYSelectDeviceViewController : XHYBaseViewController

@property(nonatomic,copy) selectDeviceBlock deviceBlock;

- (instancetype)initWithDeviceSelectType:(XHYDeviceSelectType)selectType;

@end

//
//  XHYModeEditViewController.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/23.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYBaseViewController.h"
#import "XHYModeItem.h"

typedef enum : NSUInteger {
    ModeEdit,
    ModeAdd,
} ModeMangaerType;

@interface XHYModeEditViewController : XHYBaseViewController

@property(nonatomic,strong) XHYModeItem *currentEditMode;

- (instancetype)initWithModeEditType:(ModeMangaerType)modeEditType;

@end

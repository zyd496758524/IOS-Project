//
//  XHYLinkageEditViewController.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/16.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYBaseViewController.h"

#import "XHYSmartLinkage.h"

typedef enum : NSUInteger {
    LinkageEdit,
    LinkageAdd,
} LinkageMangaerType;

@interface XHYLinkageEditViewController : XHYBaseViewController

@property(nonatomic,strong) XHYSmartLinkage *editSmartLinkage;

- (instancetype)initWithLinkageManagerType:(LinkageMangaerType)managerType;


@end

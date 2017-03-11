//
//  XHYSelectLinkageViewController.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/25.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYBaseViewController.h"

typedef void(^selectLinkageBlock)(NSArray *selectLinkageArray);

@interface XHYSelectLinkageViewController : XHYBaseViewController

@property(nonatomic,copy) selectLinkageBlock linkageBlock;

@end

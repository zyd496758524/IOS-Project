//
//  XHYLinkValueHelper.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/16.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHYLinkValueHelper : NSObject

+ (NSString *)getActionDescriptionFromActionValue:(NSString *)actionValue;

+ (BOOL)needAdditionalValueForActionValue:(NSString *)actionValue;

@end

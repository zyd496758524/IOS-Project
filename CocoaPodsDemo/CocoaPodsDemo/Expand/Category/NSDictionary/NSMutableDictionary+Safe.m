//
//  NSMutableDictionary+Safe.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/10.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "NSMutableDictionary+Safe.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (Safe)

+ (void)load {
    
    Class dictCls = NSClassFromString(@"__NSDictionaryM");
    
    Method originalMethod = class_getInstanceMethod(dictCls,
                                                    @selector(setObject:forKey:));
    Method swizzledMethod = class_getInstanceMethod(dictCls,
                                                    @selector(na_setObject:forKey:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)na_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!anObject)
        return;
    [self na_setObject:anObject forKey:aKey];
}

@end

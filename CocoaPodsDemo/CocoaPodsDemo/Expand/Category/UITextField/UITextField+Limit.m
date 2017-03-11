//
//  UITextField+Limit.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/22.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "UITextField+Limit.h"
#import <objc/runtime.h>


@implementation UITextField (Limit)

+ (void)load{
    
    /*
    Method sysMethod = class_getInstanceMethod(self, @selector(addTarget:action:forControlEvents:));
    
    Method limitMethod = class_getInstanceMethod(self, @selector(limitAddTarget:action:forControlEvents:));
    SEL limitSEL = @selector(limitTextFieldDidChange:);
    
    BOOL didAddMethod = class_addMethod(self, limitSEL, method_getImplementation(limitMethod), method_getTypeEncoding(limitMethod));
    
    if (didAddMethod){
        
        class_replaceMethod(self, limitSEL, method_getImplementation(sysMethod), method_getTypeEncoding(sysMethod));
        
    }else{
        
        method_exchangeImplementations(sysMethod, limitMethod);
    }
    */
}

- (NSUInteger)maxTextLength{

    return [objc_getAssociatedObject(self, "UITextFieldMaxTextLength") integerValue];
}

- (void)setMaxTextLength:(NSUInteger)maxTextLength{

    objc_setAssociatedObject(self, "UITextFieldMaxTextLength", @(maxTextLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)limitAddTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{

}

- (void)limitTextFieldDidChange:(id)sender{
    
    NSUInteger textLength = [self unicodeLengthOfString:self.text];
    
    if (textLength > self.maxTextLength)  // MAXLENGTH为最大字数
    {
        //超出限制字数时所要做的事
        self.text = [self.text substringToIndex:self.maxTextLength];
    }
}

//按照中文两个字符，英文数字一个字符计算字符数
- (NSUInteger) unicodeLengthOfString:(NSString *)text{
    
    NSUInteger asciiLength = 0;
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    return asciiLength;
}
@end

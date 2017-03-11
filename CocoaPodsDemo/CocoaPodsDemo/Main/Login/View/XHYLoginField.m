//
//  XHYLoginField.m
//  XHYSparxSmart
//
//  Created by  XHY on 16/7/7.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import "XHYLoginField.h"

@implementation XHYLoginField

- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 5;
    return iconRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds{
    
    CGRect iconRect = [super rightViewRectForBounds:bounds];
    iconRect.origin.x -= 3;
    return iconRect;
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    
    CGRect textRect = [super textRectForBounds:bounds];
    textRect.origin.x += 5;
    return textRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds{

    CGRect editRect = [super editingRectForBounds:bounds];
    editRect.origin.x += 5;
    return editRect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

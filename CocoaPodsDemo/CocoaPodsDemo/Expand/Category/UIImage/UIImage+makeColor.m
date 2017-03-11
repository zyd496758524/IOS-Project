//
//  UIImage+makeColor.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/7/21.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "UIImage+makeColor.h"

@implementation UIImage (makeColor)

- (UIImage *)imageMaskWithColor:(UIColor *)maskColor{

    if (!maskColor) {
        return nil;
    }
    
    UIImage *newImage = nil;
    CGRect imageRect = (CGRect){CGPointZero,self.size};
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -(imageRect.size.height));
    CGContextClipToMask(context, imageRect, self.CGImage);//选中选区 获取不透明区域路径
    CGContextSetFillColorWithColor(context, maskColor.CGColor);//设置颜色
    CGContextFillRect(context, imageRect);//绘制
    newImage = UIGraphicsGetImageFromCurrentImageContext();//提取图片
    UIGraphicsEndImageContext();
    return newImage;
}

@end

//
//  XHYFontTool.h
//  XHYSparxSmart
//
//  Created by  XHY on 16/7/25.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHYFontTool : NSObject
/*
 *  根据当前手机系统语言返回对应字体,中文为微软雅黑  英文为Arial
 *
 *  @param fontSize 字体大小
 *
 *  @return 字体
 */
+ (UIFont *)getDeaultFontBaseLanguageWithSize:(CGFloat)fontSize;

@end

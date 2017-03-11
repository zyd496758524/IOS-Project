//
//  XHYFontTool.m
//  XHYSparxSmart
//
//  Created by  XHY on 16/7/25.
//  Copyright © 2016年 XHY_SmartLife. All rights reserved.
//

#import "XHYFontTool.h"

@implementation XHYFontTool

+ (UIFont *)getDeaultFontBaseLanguageWithSize:(CGFloat)fontSize{

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    if ([preferredLang containsString:@"zh-Hans"]){
        //中文
        return [UIFont fontWithName:@"MicrosoftYaHei" size:fontSize];
        
    }else{
        //英文
        return [UIFont fontWithName:@"Arial" size:fontSize];
    }
}

@end

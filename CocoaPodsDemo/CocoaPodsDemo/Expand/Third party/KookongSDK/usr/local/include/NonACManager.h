//
//  NonACManager.h
//  kookongIphone
//
//  Created by shuaiwen on 16/3/15.
//  Copyright © 2016年 shuaiwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NonACManager : NSObject
-(id)KKNonACManagerWith:(NSDictionary * )irData;
-(NSArray *)getAllKeys;
-(int)getRemoteID;
-(NSArray* )getParams;//获得遥控器参数
-(NSArray *)getKeyIrWith:(NSString *)fkey;//获得按键参数
@end

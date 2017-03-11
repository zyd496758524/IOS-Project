//
//  XHYModeItem.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/23.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHYModeItem : NSObject

@property(nonatomic,copy) NSString *modeName;
@property(nonatomic,copy) NSString *modeID;

@property(nonatomic,strong) NSMutableArray *deviceArray;
@property(nonatomic,strong) NSMutableArray *linkageArray;
@property(nonatomic,strong) NSMutableArray *msgArray;

@end

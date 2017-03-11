//
//  XHYFloorItem.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/11/23.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHYFloorItem : NSObject

@property(nonatomic,copy) NSString *floorName;
@property(nonatomic,strong) NSMutableArray *roomArray;

@property(nonatomic,assign) BOOL isExpend;
@property(nonatomic,assign) BOOL isSelect;

@end

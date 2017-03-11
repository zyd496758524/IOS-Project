//
//  XHYDBManager.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/31.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "FMDatabaseQueue.h"

@interface XHYDBManager : NSObject

+ (void)createDataBase;

+ (FMDatabaseQueue *)shareDataDaseQueue;

+ (BOOL)addField:(NSString *)field inTable:(NSString *)tableName;

@end

//
//  XHYDBManager.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/31.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYDBManager.h"

@implementation XHYDBManager

+ (void)createDataBase{

    if ([[NSFileManager defaultManager] fileExistsAtPath:MainDataBasePath]){
        
        NSLog(@"%@",MainDataBasePath);
        return;
    }
    //数据库不存在，创建数据库
    FMDatabaseQueue *queue = [XHYDBManager shareDataDaseQueue];
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"creatDB" ofType:@"sql"];
        NSString *creatSql  = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        if (![db executeStatements:creatSql]){
            NSLog(@"创建数据库失败");
        }
    }];
}

+ (FMDatabaseQueue *)shareDataDaseQueue{

    static FMDatabaseQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        queue = [FMDatabaseQueue databaseQueueWithPath:MainDataBasePath];
    });
    return queue;
}

+ (BOOL)addField:(NSString *)field inTable:(NSString *)tableName{

    __block BOOL result = NO;
    
    if (![field length]){
        
        return result;
    }
    
    if (![tableName length]){
        
        return result;
    }
    
    FMDatabaseQueue *queue = [XHYDBManager shareDataDaseQueue];
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback){

        if (![db columnExists:field inTableWithName:tableName]){
           
            NSString *addField = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ TEXT",tableName,field];
            result = [db executeUpdate:addField];
        }
    }];

    return result;
}

@end

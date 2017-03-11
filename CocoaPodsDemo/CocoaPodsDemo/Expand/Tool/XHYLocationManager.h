//
//  XHYLocationManager.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2017/3/3.
//  Copyright © 2017年  XHY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^KSystemLocationBlock)(CLLocation *loction, NSError *error);

@interface XHYLocationManager : NSObject

+ (id)shareInstance;

/**
 *  启动系统定位
 *
 *  @param systemLocationBlock 系统定位成功或失败回调成功
 */
- (void)startSystemLocationWithRes:(KSystemLocationBlock)systemLocationBlock;

@end

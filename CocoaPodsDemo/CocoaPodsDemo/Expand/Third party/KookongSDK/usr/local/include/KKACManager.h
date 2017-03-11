//
//  ModeAndValue.h
//  kookongIphone
//
//  Created by shuaiwen on 16/3/2.
//  Copyright © 2016年 shuaiwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface KKACManager : NSObject
@property(nonatomic,copy)NSString * AC_RemoteId;
@property(nonatomic,strong)NSDictionary * airDataDict;
@property(nonatomic,copy)NSString * apikey;

/**
 *  处理红外码库数据
 */
-(void)airConditionModeDataHandle;

/**
 *  非首次登陆时，将数据库保存的空调的每个模式及模式下对应的状态值进行传值
 *
 *  @param modesta  模式
 *  @param powersta 开关
 *  @param temp     温度
 *  @param windp    风量
 *  @param winds    风向
 *  @param isShow   是否为面板要展示的一组数据
 */
-(void)readAirConditionStateAndValueWihtModestate:(int)modesta powerState:(int)powersta temperature:(int)temp windPower:(int)windp windState:(int)winds isShowState:(BOOL)isShow;

/**
 *  判断当前温度下，温度是否可控
 *
 *  @return yes：可控，no：不可控
 */
-(BOOL)canControlTemp;

/**
 *  风向按钮是否可以点击
 *
 *  @return yes：可以点击，no：不可以点击
 */
-(BOOL)windStateButtonCanClick;

/**
 *  判断模式按钮是否可以点击
 *
 *  @param tag 模式button的tag值
 *
 *  @return yes：有当前模式，可以点击，no：没有当前模式，不可以点击
 */
-(BOOL)canModeStateButtonClickWithTag:(NSInteger)tag;
-(BOOL)canTemperatureButtonClickWithTag:(NSInteger)tag;//同上
-(BOOL)canWindStateButtonClickWithTag:(NSInteger)tag;//同上
-(BOOL)canWindPowerButtonClickWithTag:(NSInteger)tag;//同上

-(int)getModeState;//得到当前模式
-(int)getWindPower;//得到当前模式的风量
-(int)getWindState;//得到当前模式的风向
-(int)getTemperature;//得到当前模式的温度
-(int)getPowerState;//得到开关状态

/**
 *  点击按钮，改变按钮对应的状态值
 *
 *  @param modest 模式
 */
-(void)changeModeStateWithModeState:(int)modest;
-(void)changeWindPowerWithWindpower:(int)windp;//同上
-(void)changeTemperatureWithTemperature:(int)temp;//同上
-(void)changePowerStateWithPowerstate:(int)powersta;//同上
-(void)changeWindStateWithWindState:(int)windsta;//同上

-(NSArray *)getAllModeState;//得到该空调所拥有的所有模式
-(NSArray *)getAllWindPower;//得到该空调当前模式下所有的风量可选项
-(NSArray *)getAllWindState;//得到该空调所有的风向可选项
-(NSArray *)getLackOfTemperatureArray;//得到该空调当前模式下禁止设定的温度值集合

-(NSArray *)getAirConditionInfrared;//得到当前的按键参数
-(NSArray *)getParams;//得到当前的遥控器参数
-(NSArray *)getAirConditionAllModeAndValue;//得到所有的模式及模式下的状态值
@end

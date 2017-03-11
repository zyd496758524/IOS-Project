#ifndef ZIGBEE_H
#define ZIGBEE_H

#define MAX_DEVICE						1000
#define MODIFY_DATE "2016-10-27"

#define HAVE_POWER_DET
#define HAVE_DEV_VERSION	// 是否开启设备版本记录


// ---------------------------设备id-------------------------------
#define ZCL_HA_DEVICEID_ELE_SLIDING_DEV	0x0505			// 电动推窗器
#define ZCL_HA_DEVICEID_CTL_ONOFF			0x0506			// 终控开关   一个按键
#define ZCL_HA_DEVICEID_CTL_ONOFF_TWO	    0x0507			// 终控开关   2个按键
#define ZCL_HA_DEVICEID_CTL_ONOFF_THR	    0x0508			// 终控开关   3个按键

#define ZCL_HA_DEVICEID_PM25				0x0509			// PM2.5检测
#define ZCL_HA_DEVICEID_POWER_LIGHT		0x0510			// 带电量检测智能开关 被动设备
#define ZCL_HA_DEVICEID_CH2O_CHECK			0x0511			// 甲醛检测
#define ZCL_HA_DEVICEID_CURTAIN_CONTROL		0x0501			// 被动设备 窗帘电击
#define ZCL_HA_DEVICEID_DOOR				0x0503			// 门磁 主动设备
// clusterID 0x0006  开门 cmdid 0x01  关门 cmdid 0x00  敲门 cmdid 0x03

#define ZCL_HA_DEVICEID_SOS				0x0010			// SOS报警 主动设备
#define ZCL_HA_DEVICEID_CO_ALARM			0x0011  		// 燃气报警 主动设备
#define ZCL_HA_DEVICEID_TEMPERATURE_SENSOR	0x0302    		// 红外探测 主动设备
// clusterID 0x0408 guangmin上报 0x01 day 0x00 night clusterID 0x0407 人体感应  clusterID 0x0405 湿度上报   clusterID 0x0402 温度上报

#define ZCL_HA_DEVICEID_IAS_ZONE			0x0402   		// 烟雾报警 主动设备

#define ZCL_HA_DEVICEID_RAIN_ALARM	    	0x0504  		// 雨水探测器 主动设备


//红外转发器
#define ZCL_HA_DEVICEID_INFRA_FORWARD		0x0500			// 红外转发 被动设备


#define ZCL_HA_DEVICEID_LOCK				0x0502			// 门锁 被动设备
#define ZCL_HA_DEVICEID_ON_OFF_LIGHT		0x0100			// 智能开关 被动设备
#define ZCL_HA_DEVICEID_ON_OFF_SWITCH		0x0000  		// 被动设备 智能插座

#define ZCL_HA_DEVICEID_AIR_CT				0x3333  		// 被动设备  空调
#define ZCL_HA_DEVICEID_TV					0x2222  		// 被动设备  电视
#define ZCL_HA_DEVICEID_CAMERA      		0x1111  		// 被动设备  摄像头 0-24种旋转角度

#define ZCL_HA_DEVICEID_INTEL_REMOTE_CONTROL 0x0600 		// 智能遥控器

#define ZCL_HA_DEVICEID_SCENE_CONTROL 		0x000A  		// 情景设备

// clusterID 0x0008 开关控制  0x00 关, 0x01 开
// clusterID 0x0300 颜色配置  0x00 get 0x01 set data0 :pattern；(1 byte )data1:WRGB(顺序不可变)(4 bytes)
//                          单独控制模式：Data1 填0 0:W模式 1:W+C模式  2:RGB模式 3:W+RGB模式
//							单独控制颜色：Data0 填 FF
// clusterID 0x0005 模式控制  0x00 get 0x01 set 0x02 select
#define ZCL_HA_DEVICEID_DIMMER				0x0102 			// 调光器

#define ZCL_HA_BACKGROUND_MUSIC			0x4001			// 背景音乐设备（右转）
//空调				0x3333
//电视机				0x2222
//摄像头				0x1111
//没有标注设备编号		0x9999
//-----------------------------end-------------------------------

// 上报消息类型
enum MsgType_E
{
	MSG_TYPE_REPORT_STATE			= 0,		// Device on/off status changed. For switch, light and lock.
	MSG_TYPE_ONLINE_CHANGE			= 1,		// Device online/offline changed. For all devices.
	MSG_TYPE_REPORT_TEMPERATURE		= 2,		// Report temperature.
	MSG_TYPE_REPORT_HUMIDITY		= 3,		// Report humidity.
	MSG_TYPE_REPORT_DOOR_OPEN		= 4,		// Report door opened.
	MSG_TYPE_MOTION					= 5,		// Report motion alarm.
	MSG_TYPE_SMOKE					= 6,		// Report smoke alarm.
	MSG_TYPE_KNOCK_ON_THE_DOOR		= 7,		// Report someone knock on the the door.
	MSG_TYPE_USER_LIST				= 8,		// User list.
	MSG_TYPE_REPORT_LOCK_OPEN		= 9,		// Report lock opened.
	MSG_TYPE_PHOTO_SENSITIVE_CFG	= 10,		// Get photo sensivive config.
	MSG_TYPE_MOTION_CFG				= 11,		// Get motion config.
	MSG_TYPE_REPORT_CURTAIN_PROGRESS = 12,		// Report curtain progress.
	MSG_TYPE_REPORT_AT_HOME_MODE	= 13,		// Report at home mode.
	MSG_TYPE_REPORT_LEAVE_HOME_DELAY= 14,		// Report leave home delay.
	MSG_TYPE_REPORT_SOS				= 15,		// Report SOS msg
	MSG_TYPE_REPORT_CO_ALARM		= 16,		// Report CO alarm
	MSG_TYPE_REPORT_CH4_ALARM		= 17,		// Report CH4 alarm
	MSG_TYPE_REPORT_REMOTER_LEARNING	= 18,	// Report remoter learning key
	MSG_TYPE_REPORT_MODEDATA_CHANGE = 19,		// Report modedata change
	MSG_TYPE_REPORT_LINKDATA_CHANGE = 20,		// Report linkdata change
	MSG_TYPE_REPORT_RAIN_ALARM		= 21,   	// Report rain alarm: 0位: 0 白天 1黑夜 1位：0 无水 1 有水
	MSG_TYPE_REPORT_GW_VERSION		= 22,		// Report Gateway version
	MSG_TYPE_REPORT_DEVICE_DEL 		= 23,     	// Report Device del
	MSG_TYPE_REPORT_SWITCH_POWER 	= 24,		// Report Device power
	MSG_TYPE_NEW_DEVICE 			= 25,  		// Report New Device
	MSG_TYPE_REPORT_DAYNIGHT 		= 26, 		// Report Day(1) or night(0)
	MSG_TYPE_REPORT_DIMMER_SCENE 	= 27, 		// Report Dimmer scene 0~8
	MSG_TYPE_REPORT_DIMMER_COLOR 	= 28, 		// Report Dimmer color/mode
	MSG_TYPE_REPORT_BGM_STATUS 		= 29, 		// Report Background Music Play Status
	MSG_TYPE_REPORT_BGM_DEVINFO  	= 30,		// Report Background Music Dev info
	MSG_TYPE_REPORT_LINK_DEL		= 31,		// Report link del
	MSG_TYPE_REPORT_GW_PING			= 32,		// Report GW_PING
	MSG_TYPE_REPORT_SAVE_AC_KEY		= 33,		// Report Ac remoter save key
	MSG_TYPE_GET_MODE_DATA			= 34,
	MSG_TYPE_GET_LINK_DATA			= 35,
	MSG_TYPE_GET_DEVICE_NAME_DATA	= 36,
	MSG_TYPE_GET_ROOM_DATA			= 37,
	MSG_TYPE_GET_EXTRA_DATA			= 38,
	MSG_TYPE_GET_IR_DATA			= 39
};

struct DeviceInfo_S
{
	long long IEEEAddr;
	unsigned short int nwkAddr;	// Network address
	unsigned short int profileId;
	unsigned short int deviceId;	// Device type
	unsigned char endPoint;
	unsigned char status;
	unsigned char LQI;
#ifdef HAVE_POWER_DET
	unsigned char powerStatus; // 电量：0x0-有电 0x1-没电 0xff-表示为强电设备
#endif
	unsigned char dev_status; // 设备的开关状态
#ifdef HAVE_DEV_VERSION
	unsigned char dev_ver[5]; // 设备的版本号
#endif
};


struct MsgInfo_S
{
	enum MsgType_E type;						// Msg type..
	unsigned short nwkAddr;					// Network address.
	unsigned char endPoint;					// Endpoint.
	unsigned char value;						// Msg value.
	unsigned int intValue;						// Msg value by int.
	unsigned char charValue[2048];				// Msg value by char array.
	int charValueLen;							// Len of char array value.
};

// Call this function to get the devices list when system start. Ouput command string to send by XMPP.
void getNetworkRequest( char *result );
// After call getNetworkRequest, call this function to handle the received msg.
int networkResponse( const char *response, int len );
// Call this function when reconnect.
void startReconnect();
// Get specified device infor.
struct DeviceInfo_S *getDeviceInfo( int deviceNo );
// Get device sum.
int getDeviceCount();
// Get on/off status. For switch, light, lock. 
void getOnOffCmd( unsigned short int nwkAddr, unsigned char endPoint, char *result );
// Set on/off status. For switch, light, lock.
void setOnOffCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char onOff, char *result );
// Get user list.
void getUserList( unsigned short int nwkAddr, unsigned char endPoint, char *result );
// Send on/off/stop command. For curtain. value: off-0, on-1, stop-2.
void sendOnOffStopCmd( unsigned short int nwkAddr, unsigned char value, char *result ); 
// Handle the received msg. Return 0 means this msg should be handle.
int handleMsg( const char *msg, int len, struct MsgInfo_S *msgInfo );
// Send key. For controller.
void sendKeyCmd( unsigned short int nwkAddr, unsigned char key, char *result );
// Send open door cmd.
void sendOpenLockCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char userId, char *result1, char *result2 );
// Set user info.
void setUserInfo( unsigned char userId, char *name, int nameLen, unsigned char faceNo, char *result );
// Get photosensitive config.
void getPhotoSensitiveCfg( char *result );
// Set photosensitive config.
void setPhotoSensitiveCfg( bool beSet, unsigned long IEEEAddrSensitive, unsigned long IEEEAddrLight, char *result );
// Get Motion config.
void getMotionCfg( char *result );
// Set Motion config.
void setMotionCfg( bool beSet, unsigned long IEEEAddrSensitive, unsigned long IEEEAddrLight, char *result );
// Set door password.
void setDoorPassword( unsigned char type, unsigned char startYear, unsigned char startMonth, unsigned char startDay, unsigned char startHour, unsigned char startMinute, unsigned char endYear, unsigned char endMonth, unsigned char endDay, unsigned char endHour, unsigned char endMinute, char *result );
// Get at home mode.
void getAtHomeMode( char *result );
// Set at home mode.
void setAtHomeMode( int mode, char *result );
// Get leave home delay.
void getLeaveHomeDelay( char *result );
// Set leave home delay.
void setLeaveHomeDelay( int delay, char *result );
// One key control.
void oneKeyControl( int type, int control, char *result );
// Set lock time.
void setLockTime( unsigned char year, unsigned char month, unsigned char day, unsigned char hour, unsigned char minute, unsigned char second, char *result );
// send remote cmd.
void sendRemoteCmd( unsigned short int nwkAddr, unsigned char endPoint, int cmd, unsigned char device, int group, unsigned char keyval, unsigned char *param, int paramLen, char *result );
// send remote learning key. type 0 is tv, type 1 is arc.
void sendRemoteLearnKey( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char *keyValue, char *result );
// remote learning end.
void remoteLearnEnd(  unsigned short int nwkAddr, unsigned char endPoint, char *result );
// Set door device.
void setDoor( unsigned long IEEEAddrDoor, char *result );


/* ************************************************************************
 *  void sendStartLearnCmd( unsigned short int nwkAddr, unsigned char endPoint, char type,  char keyVal, char *result )
 *
 *  info: 开始学习 APP----> gateway (转发) --> zigbee (转发) -serial-> RF模块
 *  in:
 *  	nwkAddr : 类型-unsigned short int  描述-
 *  	endPoint: 类型-unsigned char    描述-服务器端口
 *  	type: 类型-char 描述-0x00 普通设备 0x01 空调设备
 *  	keyVal:  类型-char 描述-键值
 *  	result: 类型-jbyteArray  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/

/*
 * 开始学习：
 * 普通设备 16  F6  01  ser  sum  08
 * 空调设备 16  FC  01  ser  sum  08
 *
 *
 * */
void sendStartLearnCmd( unsigned short int nwkAddr, unsigned char endPoint, char type,  char keyVal, char *result );
/* ************************************************************************
 *  void sendLearnKeyCmd( unsigned short int nwkAddr, unsigned char endPoint, char type, char keyVal, char *result )
 *
 *  info: 开始学习 APP----> gateway (转发) --> zigbee (转发) -serial-> RF模块
 *  in:
 *  	nwkAddr : 类型-unsigned short int  描述-
 *  	endPoint: 类型-unsigned char  描述-服务器端口
 *  	type: 类型-char 描述-0x00 普通设备 0x01 空调设备
 *  	keyVal:  类型-char 描述-键值
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *  	连接云服务器的状态：
 *  	0 登录成功
 *  	其他 登录失败
 *
 * ************************************************************************/
/*
 * 发送学习按键：
 * 普通设备 16  F7  01  ser  sum  08
 * 空调设备 16  FD  01  ser  sum  08
 *
 *
 * */
void sendLearnKeyCmd( unsigned short int nwkAddr, unsigned char endPoint, char type,  char keyVal, char *result );

/* ************************************************************************
 *  void sendStopLearnCmd( unsigned short int nwkAddr,unsigned char endPoint, char *result )
 *
 *  info: 停止学习 APP----> gateway (转发) --> zigbee (转发) -serial-> RF模块
 *  in:
 *  	nwkAddr : 类型-unsigned short int  描述-
 *  	endPoint: 类型-unsigned char    描述-服务器端口
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
/*
 *  16  FE  00  sum  08
 *
 * */
void sendStopLearnCmd( unsigned short int nwkAddr, unsigned char endPoint, char *result );


/*
 * 发送遥控器参数：
 * 单独发送遥控器参数 01 Len0 Text0
 *
 *
 * */
void sendRemConParaCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int len,  char *para, char *result );

/*
 * 发送按键参数：
 * 单独发送遥控器KeyId 02 Len1 Text1
 *
 *
 * */
void sendRemConKeyParaCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int len,  char *para, char *result );

/*
 * 发送遥控器参数+按键参数：
 * 一起发送 03 Len0 Text0 Len1 Text1
 *
 * 如果 Len0 + Len1 长度 超过 70，需要拆分成2条指令发送：
 * 分别调用 sendRemConParaCmd + sendRemConKeyParaCmd 一次
 *
 *
 * */
void sendRemConAllParaCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int rem_len,  char *rem_para, unsigned short int key_len, char *key_para, char *result );

/* ************************************************************************
 *  void sendAirConditionParamCmd( unsigned short int nwkAddr, unsigned char endPoint,
		unsigned char acMode, unsigned char acFan, unsigned char acTemp,
		unsigned short int paramLen,  char *acParam, char *result )
 *
 *  for: 空调遥控器
 *  info: 发送空调码组
 *  in:
 *  	nwkAddr : 类型-unsigned short int  描述-
 *  	endPoint: 类型-unsigned char  描述-服务器端口
 *  	acMode: 空调模式
 *  	acFan: 空调风量
 *  	acTemp: 空调温度
 *		paramLen: 空调参数长度
 *		para: 空调参数
 *  	result: 类型-char *  描述-用于保存返回的结果
 *
 *  return:
 *
 * ************************************************************************/
/*
 * 发送保存code按键：
 * 04 Mode Fan Temp paramLen acParam
 *
 *
 * */
void sendAirConditionParamCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char acMode, unsigned char acFan, unsigned char acTemp, unsigned short int len,  char *para, char *result );

/* ************************************************************************
 *  void sendAirConditionParamCmd( unsigned short int nwkAddr, unsigned char endPoint,
		unsigned char acMode[], unsigned char acFan[], unsigned char acTemp[],
		unsigned short int paramLen[],  char *acParam[], char *result )
 *
 *  for: 空调遥控器
 *  info: 发送空调码组
 *  in:
 *  	nwkAddr : 类型-unsigned short int  描述-
 *  	endPoint: 类型-unsigned char  描述-服务器端口
 *  	acMode[]: 空调模式
 *  	acFan[]: 空调风量
 *  	acTemp[]: 空调温度
 *		paramLen[]: 空调参数长度
 *		para[]: 空调参数
 *  	result: 类型-char *  描述-用于保存返回的结果
 *
 *  return:
 *
 * ************************************************************************/
/*
 * 发送保存code按键：
 * 04 Mode Fan Temp paramLen acParam
 *
 * 05 Mode Fan Temp paramLen acParam Mode Fan Temp paramLen acParam
 * */
void sendAirConditionParamCmdAll( unsigned short int nwkAddr, unsigned char endPoint, unsigned char size, unsigned char acMode[], unsigned char acFan[], unsigned char acTemp[], unsigned short int len[],  char *para[], char *result );

/* ************************************************************************
 *  void setModeData( char *data, int dataLen,char *result )
 *
 *  info: 情景模式通知 数据包设置
 *  in:
 *  	data : 类型-char *  描述- json-urlcode encode 数据
 *  	dataLen: 类型-int    描述-数据长度
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setModeData( char *data, int dataLen,char *result );

/* ************************************************************************
 *  void sendDelMode( char *data, int dataLen, unsigned char value , char *result )
 *
 *  info: 设置删除的场景ID
 *  in:
 *  	data : 类型-char *  描述- json-urlcode mode uniqueID
 *  	dataLen: 类型-int    描述-数据长度
 *  	value: 类型-unsigned char 描述-0 取消 1 设置
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendDelMode( char *data, int dataLen, unsigned char value , char *result );

/* ************************************************************************
 *  void setLinkData( char *data, int dataLen,char *result )
 *
 *  info: 联动数据通知 数据包设置
 *  in:
 *  	data : 类型-char *  描述- json-urlcode encode 数据
 *  	dataLen: 类型-int    描述-数据长度
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setLinkData( char *data, int dataLen,char *result );

/* ************************************************************************
 *  void sendDelLink( char *data, int dataLen,char *result )
 *
 *  info: 联动数据通知 数据包设置
 *  in:
 *  	data : 类型-char *  描述- json-urlcode encode 数据
 *  	dataLen: 类型-int    描述-数据长度
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendDelLink( char *data, int dataLen,char *result );

/* ************************************************************************
 *  void sendModeDataClear( char *result )
 *
 *  info: 联动数据通知 数据包设置
 *  in:
 *  	data : 类型-char *  描述- json-urlcode encode 数据
 *  	dataLen: 类型-int    描述-数据长度
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendModeDataClear( char *result );

/* ************************************************************************
 *  void sendSelMode( char *data, int dataLen, unsigned char value , char *result )
 *
 *  info: 设置选择的场景ID
 *  in:
 *  	data : 类型-char *  描述- json-urlcode mode uniqueID
 *  	dataLen: 类型-int    描述-数据长度
 *  	value: 类型-unsigned char 描述-0 取消 1 设置
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendSelMode( char *data, int dataLen, unsigned char value , char *result );

/* ************************************************************************
 *  void startAddingMode( unsigned char value , char *result )
 *
 *  info: 进入允许入网模式
 *  in:
 *  	value: 类型-unsigned char 描述-0 取消 1 设置
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void startAddingMode( unsigned char value , char *result );

/* ************************************************************************
 *  void getGwVersion( char *result )
 *
 *  info: 获取网关版本号
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getGwVersion( char *result );

/* ************************************************************************
 *  void sendSaveCodeCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int code, char *result )
 *
 *  info: 发送code 鎷组
 *  in:
 *  	nwkAddr : 类型-unsigned short int  描述-
 *  	endPoint: 类型-unsigned char  描述-服务器端口
 *  	code:  类型-类型-unsigned short int 描述-code
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
/*
 * 发送保存code按键：
 * 16  FF  02  Code_L Code_H  sum  08
 *
 *
 * */
void sendSaveCodeCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int code, char *result );

/* ************************************************************************
 *  void sendDeviceDelCmd( char *data, int dataLen,char *result )
 *
 *  info: 联动数据通知 数据包设置
 *  in:
 *  	data : 类型-char *  描述- json-urlcode encode 数据
 *  	dataLen: 类型-int    描述-数据长度
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendDeviceDelCmd( char *data, int dataLen,char *result );
// Get on/off status. For switch, light, lock.
void getDevicePowerCmd( unsigned short int nwkAddr, unsigned char endPoint, char *result );

/* ************************************************************************
 *  void sendFwOTAUpdate( char *result )
 *
 *  info: 让网关进行OTA升级，APP需要先对当前的网关的固件版本与云端的网关的固件版本进行比对，来确定是否需要发送该命令
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendFwOTAUpdate( char *result );

/* ************************************************************************
 *  void sendDoFactory( char *result )
 *
 *  info: 清空设备
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendDoFactory( char *result );

/* ************************************************************************
 *  void sendAppCtlEventCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char event, unsigned char val, char *result )
 *
 *  info: 发送APP EVENT
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendAppCtlEventCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char event, unsigned char val, char *result );

/* ************************************************************************
 *  void sendDimmerOnOffCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char OnOff, char *result )
 *
 *  info: 发送dimmer on(0x01)/off(0x00) 状态
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendDimmerOnOffCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char OnOff, char *result );

/* ************************************************************************
 *  void sendDimmerColorCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char mode, unsigned char col_r, unsigned char col_g, unsigned char col_b, char *result )
 *
 *  info: get(0x00)/set(0x01) dimmer 颜色/模式 状态
 *  in:
 *  	type:   类型 unsigned char 描述:0x00 get, 0x01 set
 *  	mode: 	类型 unsigned char 描述:0x00 W, 0x01 w+c, 0x02 RGB, 0x03 w+RGB, 单独控制 颜色 mode 填写 0xff
 *  	col_w:  类型 unsigned char 描述:0~0xff
 *  	col_r:  类型 unsigned char 描述:0~0xff
 *  	col_g:	类型 unsigned char 描述:0~0xff
 *  	col_b:	类型 unsigned char 描述:0~0xff
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  	注意： 当单独设置 模式的时候， col_w/col_r/col_g/col_b 全部填充0
 *  		  当单独设置 颜色的时候， mode 填充 0xff
 *  return:
 *
 * ************************************************************************/
void sendDimmerColorCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char mode, unsigned char col_w, unsigned char col_r, unsigned char col_g, unsigned char col_b, char *result );


/* ************************************************************************
 *  void sendDimmerSceneCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char sel, unsigned char col_w, unsigned char col_r, unsigned char col_g, unsigned char col_b, char *name, char *result );
 *
 *  info: get(0x00)/set(0x01)/sel(0x02) dimmer 颜色/模式 状态
 *  in:
 *  	type:   类型 unsigned char 描述:0x00 get, 0x01 set, 0x02 select
 *  	sel: 	类型 unsigned char 描述:0x00~0x08 总共有9个
 *  	col_w:  类型 unsigned char 描述:0~0xff
 *  	col_r:  类型 unsigned char 描述:0~0xff
 *  	col_g:	类型 unsigned char 描述:0~0xff
 *  	col_b:	类型 unsigned char 描述:0~0xff
 *  	name:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  	注意： 当单独设置 模式的时候， col_w/col_r/col_g/col_b 全部填充0
 *  		  当单独设置 颜色的时候， mode 填充 0xff
 *  return:
 *
 * ************************************************************************/
void sendDimmerSceneCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char sel, unsigned char col_w, unsigned char col_r, unsigned char col_g, unsigned char col_b, char *name, char *result );


/* ************************************************************************
 *  void sendBgmusicCmd( char *iEEEAddr, unsigned char cmd, int extLen, char *extVal, char *result )
 *
 *  info: 发送BGM控制命令
 *  in:
 *  	iEEEAddr: char * : 8字节
 *  	cmd		: unsigned char   : 参照 BGM控制命令表
 *  	extLen 	: int 			  : 扩展数据长度 （无则填写为 0）
 *  	extVal	: char * : 扩展数据（无则填写为NULL）
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  	注意：
 *  return:
 *
 * ************************************************************************/
void sendBgmusicCmd( char *iEEEAddr, unsigned char cmd, char extLen, char *extVal, char *result );

/*
 * 带电量检测灯控开关 SET：
 * #define ZCL_HA_DEVICEID_POWER_LIGHT			0x0510			// 带电量检测智能开关 被动设备
 *
 *
 * */
void sendPLightSetCmd( unsigned short int nwkAddr, unsigned char endPoint, char key,  char onoff, char *result );

/*
 * 带电量检测灯控开关 GET：
 * #define ZCL_HA_DEVICEID_POWER_LIGHT			0x0510			// 带电量检测智能开关 被动设备
 *
 *
 * */
void sendPLightGetCmd( unsigned short int nwkAddr, unsigned char endPoint, char *result );

/*
 * GWPING
 *
 * */
void sendGwPingCmd( char *result );


/* ************************************************************************
 *  void getLinkData(char *result )
 *
 *  info: 从网关获得联动数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getLinkData(char *result );



/* ************************************************************************
 *  void getModeData( char *result )
 *
 *  info: 从网关获得模式数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getModeData(char *result );



/* ************************************************************************
 *  void getRoomData( char *result )
 *
 *  info: 从网关获得房间数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getRoomData(char *result );

/* ************************************************************************
 *  void setRoomData( char *data, int dataLen,char *result )
 *
 *  info: 设置网关获得房间数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setRoomData( char *data, int dataLen,char *result );

/* ************************************************************************
 *  void getDeviceNameData( char *result )
 *
 *  info: 从网关获得设备名数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getDeviceNameData(char *result );


/* ************************************************************************
 *  void setDeviceNameData( char *data, int dataLen,char *result )
 *
 *  info: 设置网关设备名数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setDeviceNameData( char *data, int dataLen,char *result );


/* ************************************************************************
 *  void getExtraDeviceData( char *result )
 *
 *  info: 从网关获得其它设备数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getExtraDeviceData(char *result );


/* ************************************************************************
 *  void setExtraDeviceData( char *data, int dataLen,char *result )
 *
 *  info: 设置网关获得其它设备数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setExtraDeviceData( char *data, int dataLen,char *result );

/* ************************************************************************
 *  void getIrDeviceData( char *result )
 *
 *  info: 从网关获得红外设备数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getIrDeviceData(char *result );


/* ************************************************************************
 *  void setIrDeviceData( char *data, int dataLen,char *result )
 *
 *  info: 设备网关红外设备数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setIrDeviceData( char *data, int dataLen,char *result );


/* ************************************************************************
 *  int handleSpMessage(const char *msg, int len, char* result)
 *
 *  info: 处理从网关收到的联动，模式，设备名，其它设备，红外设备等数据
 *  in:
 *  	data : 类型-char *  描述- json-urlcode encode 数据
 *  	dataLen: 类型-int    描述-数据长度
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
int handleSpMessage(const char *msg, int len, char* result);

#endif



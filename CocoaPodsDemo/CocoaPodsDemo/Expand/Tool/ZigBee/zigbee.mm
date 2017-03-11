//#define __ANDROID_VERSION__


#ifdef __ANDROID_VERSION__
#include <android/log.h>
#endif

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include "zigbee.h"

#define APP_GET_NETWORK_REQ			0x2902
#define AF_DATA_REQUEST				0x2401

#define APP_GET_NETWORK_REQ_SRSP		0x6902
#define AF_INCOMING_MSG					0x4481
#define APP_DEVICE_STATUS_NOTIFY		0x4983

#define SET_OPEN_LOCK_USER_ID			0x0000
#define SET_USER_INFO					0x0001
#define GET_USER_INFO					0x0002
#define LOCK_OPEN_NOTIFY				0x0003
#define GET_PHOTO_SENSITIVE_CFG			0x0004
#define SET_PHOTO_SENSITIVE_CFG			0x0005
#define GET_MOTION_CFG					0x0006
#define SET_MOTION_CFG					0x0007
#define SET_DOOR_PASSWORD				0x0008
#define GET_AT_HOME_MODE				0x0009
#define SET_AT_HOME_MODE				0x000A
#define GET_LEAVE_HOME_DELAY			0x000B
#define SET_LEAVE_HOME_DELAY			0x000C
#define ONE_KEY_CONTROL					0x000D
#define SET_LOCK_TIME					0x000E
#define SEND_REMOTE_CMD					0x000F
#define SET_DOOR						0x0010
#define REPORT_TEMPERATURE				0x0011
#define SEND_REMOTE_LEARN_KEY			0x0012
#define REMOTE_LEARN_END				0x0013

/* 2015-12-14 add for 情景模式 */
#define SET_MODE_DATA				0x0014
#define SET_LINK_DATA				0x0015
#define CLEAR_MODE_DATA				0X0016
#define SELECT_MODE_ID				0x0017
#define START_ADDING_MODE 			0x0018
#define GET_GW_VERSION				0x0019
#define DEVICE_DEL_CMD	            0x001A
#define DEL_MODE_DATA				0x001B
#define FW_OTA_UPDATA				0x001C
#define REPORT_NEW_DEVICE 			0x001D
#define DO_FACTORY					0x001E
#define APP_CTL_EVENT				0x001F
#define BGM_CTL_CMD					0x0020
#define BGM_REP_STATUS				0x0021
#define BGM_REP_DEVINFO				0x0022
#define DEL_LINK_DATA				0x0023
#define GW_PING						0x0024

#define GET_MODE_DATA				0x0025
#define GET_LINK_DATA				0x0026

#define GET_DEVICE_NAME_DATA		0x0027
#define GET_ROOM_DATA				0x0028
#define GET_EXTRA_DATA				0x0029
#define GET_IR_DATA					0x002A

#define SET_DEVICE_NAME_DATA		0x002B
#define SET_ROOM_DATA				0x002C
#define SET_EXTRA_DATA				0x002D
#define SET_IR_DATA					0x002E

#define MAX_DEVICE_IN_ONE_FRAME		8

#ifdef HAVE_POWER_DET
	#define REPORT_DEVICE_LEN	18
#else
	#define REPORT_DEVICE_LEN	17
#endif
int devPacketLen = 17;

unsigned char computeCheckSum( unsigned char *ptr, int len );
void changeBytesToStr( unsigned char *buff, int len, char *result );
void changeStrToBytes( const char *str, int len, unsigned char *buff, int buffLen );

//unsigned char keyBuff[208];

volatile int deviceCount = 0;
struct DeviceInfo_S *deviceInfo = NULL;
unsigned char senderEndPoint = 0xf0;//0;
unsigned char transId = 0;

void getNetworkRequest( char *result )
{
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 2;
	buff[2] = APP_GET_NETWORK_REQ >> 8;
	buff[3] = APP_GET_NETWORK_REQ & 0xFF;
	buff[4] = 0x00;
	buff[5] = 0x00;
	buff[6] = computeCheckSum( &buff[1], 5 );
	changeBytesToStr( buff, 7, result );
}

unsigned char computeCheckSum( unsigned char *ptr, int len )
{
    unsigned char xorResult;
    xorResult = 0;
    for( int i = 0; i < len; i++, ptr++ )
        xorResult = xorResult ^ *ptr;
    return xorResult;
}

int getChangeStrLen(int len)
{
	return len * 5;
}

void changeBytesToStr( unsigned char *buff, int len, char *result )
{
	int p = 0;
	for( int i = 0; i < len; i++ )
	{
		if( i != 0 )
			result[p++] = ' ';
		result[p++] = '0';
		result[p++] = 'x';
		if( buff[i] / 16 < 10 )
			result[p++] = '0' + buff[i] / 16;
		else
			result[p++] = 'a' + buff[i] / 16 - 10;
		if( buff[i] % 16 < 10 )
			result[p++] = '0' + buff[i] % 16;
		else
			result[p++] = 'a' + buff[i] % 16 - 10;
	}

	result[p++] = '\0';
}

void changeStrToBytes( const char *str, int len, unsigned char *buff, int buffLen )
{
	if( buffLen <= len / 5 )
	{
		printf( "ZIGBEE: changeStrToBytes buffLen too small!\r\n" );
		return;
	}
	int i, j;
	for( i = 0; i < len; i++ )
	{
		switch( i % 5 )
		{
			case 2:
				if( str[i] >= '0' && str[i] <= '9' )
					buff[i / 5] = str[i] - '0';
				else if( str[i] >= 'a' && str[i] <= 'f' )
					buff[i / 5] = str[i] - 'a' + 10;
				else if( str[i] >= 'A' && str[i] <= 'F' )
					buff[i / 5] = str[i] - 'A' + 10;
				break;
			case 3:
				if( str[i] >= '0' && str[i] <= '9' )
					buff[i / 5] = buff[i / 5] * 16 + str[i] - '0';
				else if( str[i] >= 'a' && str[i] <= 'f' )
					buff[i / 5] = buff[i / 5] * 16 + str[i] - 'a' + 10;
				else if( str[i] >= 'A' && str[i] <= 'F' )
					buff[i / 5] = buff[i / 5] * 16 + str[i] - 'A' + 10;
				break;
			default:
				break;
		}
	}
	
}

void changeHexStrToBytes( const char *str, int len, unsigned char *buff, int buffLen )
{
	if( buffLen <= len / 2 )
	{
		printf( "ZIGBEE: changeHexStrToBytes buffLen too small!\r\n" );
		return;
	}
	int i, j;
	for( i = 0; i < len; i++ )
	{
		switch( i % 2 )
		{
			case 0:
				if( str[i] >= '0' && str[i] <= '9' )
					buff[i / 2] = str[i] - '0';
				else if( str[i] >= 'a' && str[i] <= 'f' )
					buff[i / 2] = str[i] - 'a' + 10;
				else if( str[i] >= 'A' && str[i] <= 'F' )
					buff[i / 2] = str[i] - 'A' + 10;
				break;
			case 1:
				if( str[i] >= '0' && str[i] <= '9' )
					buff[i / 2] = buff[i / 2] * 16 + str[i] - '0';
				else if( str[i] >= 'a' && str[i] <= 'f' )
					buff[i / 2] = buff[i / 2] * 16 + str[i] - 'a' + 10;
				else if( str[i] >= 'A' && str[i] <= 'F' )
					buff[i / 2] = buff[i / 2] * 16 + str[i] - 'A' + 10;
				break;
			default:
				break;
		}
	}

}

int networkResponse( const char *response, int len )
{
	static int frameCnt = 0;
	static int frameNo = 0;

	unsigned char buff[400];
	memset(buff, 0, 400);
	changeStrToBytes( response, len, buff, 400 );

	int i, j;
	int cmd = (int)buff[2] * 0x100 + buff[3];

#ifdef __ANDROID_VERSION__
		__android_log_print( ANDROID_LOG_INFO, "lwj", "networkResponse cmd = 0x%x", cmd );
#endif

	if( cmd == APP_GET_NETWORK_REQ_SRSP && deviceInfo == NULL )
	{
#ifdef __ANDROID_VERSION__
		__android_log_print( ANDROID_LOG_INFO, "lwj", "ZIGBEE VERSION: %s", MODIFY_DATE );
#else
		printf("ZIGBEE VERSION: %s\n", MODIFY_DATE);
#endif
		int totalDevice = (int)buff[4] * 0x100 + buff[5];
		devPacketLen = (int)buff[6];
		if (buff[1] != 3)
			devPacketLen = 17;
		frameCnt = totalDevice / MAX_DEVICE_IN_ONE_FRAME + 1 + (( totalDevice % MAX_DEVICE_IN_ONE_FRAME ) != 0 ? 1: 0 );
		frameNo = 1;
		deviceCount = 0;		
		deviceInfo = (struct DeviceInfo_S *)malloc( sizeof( struct DeviceInfo_S ) * MAX_DEVICE );
		if( frameCnt == 1 )
			return 0;
		else
			return 1;
	}
	else if( cmd == 0x4982 && deviceInfo != NULL && frameNo < frameCnt )
	{
		int cnt = (int)buff[4] * 0x100 + buff[5];
#ifdef __ANDROID_VERSION__
		__android_log_print( ANDROID_LOG_INFO, "lwj", " CNT = %d", cnt );
#endif
		for( i = 0; i < cnt; i++ )
		{
			if( buff[6 + devPacketLen * i  + 11] == 0x01 &&  buff[6 + devPacketLen * i  + 10] == 0x04 )
			{
				deviceInfo[deviceCount].IEEEAddr = 0;
				for( j = 0; j < 8; j++ )
					deviceInfo[deviceCount].IEEEAddr = deviceInfo[deviceCount].IEEEAddr * 0x100 + buff[6 + devPacketLen * i + ( 7 - j )];
				deviceInfo[deviceCount].nwkAddr = (unsigned short)buff[6 + devPacketLen * i  + 9] * 0x100 + buff[6 + devPacketLen * i  + 8];
				deviceInfo[deviceCount].profileId = (unsigned short)buff[6 + devPacketLen * i  + 11] * 0x100 + buff[6 + devPacketLen * i  + 10];
				deviceInfo[deviceCount].deviceId = (unsigned short)buff[6 + devPacketLen * i  + 13] * 0x100 + buff[6 + devPacketLen * i  + 12];
				deviceInfo[deviceCount].endPoint = buff[6 + devPacketLen * i  + 14];
				deviceInfo[deviceCount].status = buff[6 + devPacketLen * i  + 15];
				deviceInfo[deviceCount].LQI = buff[6 + devPacketLen * i  + 16];
#ifdef HAVE_POWER_DET
				if (devPacketLen > 17)
					deviceInfo[deviceCount].powerStatus = buff[6 + devPacketLen * i  + 17];
#endif
				if (devPacketLen > 18)
					deviceInfo[deviceCount].dev_status = buff[6 + devPacketLen * i  + 18];

#ifdef HAVE_DEV_VERSION
				if (devPacketLen > 23)
					memcpy(deviceInfo[deviceCount].dev_ver, &buff[6 + devPacketLen * i  + 19], 5);
#endif

				if( deviceInfo[deviceCount].nwkAddr == 0x0000 )
					senderEndPoint = deviceInfo[deviceCount].endPoint;
				//if( deviceInfo[deviceCount].deviceId != 0x0501 || deviceInfo[deviceCount].endPoint % 2 == 0 )
				deviceCount++;
			}
		}
#ifdef __ANDROID_VERSION__
		__android_log_print( ANDROID_LOG_INFO, "lwj", " deviceCount = %d", deviceCount );
#endif
		frameNo++;
		if( frameNo >= frameCnt )
			return 0;
		else
			return 1;
	}

	return -1;	
}

void startReconnect()
{
	if( deviceInfo != NULL )
	{
		free( deviceInfo );
		deviceInfo = NULL;
	}
	deviceCount = 0;
}

int getDeviceCount()
{
	return deviceCount;
}

struct DeviceInfo_S *getDeviceInfo( int deviceNo )
{
	if( deviceNo >= deviceCount )
		return NULL;
	return &deviceInfo[deviceNo];
}

void getOnOffCmd( unsigned short int nwkAddr, unsigned char endPoint, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 15;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;		// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 5;		// msg len
	buff[14] = 0x10;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x00;	// cmd id;
	buff[17] = 0x00;	// ATTRID_ON_OFF
	buff[18] = 0x00;
	
	buff[19] = computeCheckSum( &buff[1], 18 );
	changeBytesToStr( buff, 20, result );
}

void setOnOffCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char onOff, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 13;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;		// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 3;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = onOff;	// cmd id;
	
	buff[17] = computeCheckSum( &buff[1], 16 );
	changeBytesToStr( buff, 18, result );
}

void getUserList( unsigned short int nwkAddr, unsigned char endPoint, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 13;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 3;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x04;	// cmd id;
	
	buff[17] = computeCheckSum( &buff[1], 16 );
	changeBytesToStr( buff, 18, result );
}

void sendKeyCmd( unsigned short int nwkAddr, unsigned char key, char *result )
{
	int deviceNo;
	for( deviceNo = 0; deviceNo < deviceCount; deviceNo++ )
		if( deviceInfo[deviceNo].nwkAddr == nwkAddr )
			break;
	if( deviceNo >= deviceCount )
	{
		printf( "ZIGBEE: setOnOffCmd nwkAddr wrong! %d\r\n", nwkAddr );
		return;
	}

	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 13;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = deviceInfo[deviceNo].endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 3;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = key;	// cmd id;
	
	buff[17] = computeCheckSum( &buff[1], 16 );
	changeBytesToStr( buff, 18, result );
}

void sendOpenLockCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char userId, char *result1, char *result2 )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = SET_OPEN_LOCK_USER_ID >> 8;
	buff[2] = SET_OPEN_LOCK_USER_ID & 0xFF;
	buff[3] = userId;
	changeBytesToStr( buff, 4, result1 );

	buff[0] = 0xFE;
	buff[1] = 13;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 3;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;	// cmd id;
	
	buff[17] = computeCheckSum( &buff[1], 16 );
	changeBytesToStr( buff, 18, result2 );
}

void sendOnOffStopCmd( unsigned short int nwkAddr, unsigned char value, char *result )
{
	int deviceNo;
	for( deviceNo = 0; deviceNo < deviceCount; deviceNo++ )
		if( deviceInfo[deviceNo].nwkAddr == nwkAddr )
			break;
	if( deviceNo >= deviceCount )
	{
		printf( "ZIGBEE: setOnOffCmd nwkAddr wrong! %d\r\n", nwkAddr );
		return;
	}

	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 13;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = deviceInfo[deviceNo].endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 3;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = value;	// cmd id;
	
	buff[17] = computeCheckSum( &buff[1], 16 );
	changeBytesToStr( buff, 18, result );
}

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
 * 旧版 2.0.0 以前
 * 普通设备 16  F6  01  ser  sum  08
 * 空调设备 16  FC  01  ser  sum  08
 *
 *
 *
 * */
void sendStartLearnCmd( unsigned short int nwkAddr, unsigned char endPoint, char type,  char keyVal, char *result )
{
	unsigned char buff[100];
	unsigned short checkSum = 0;
	buff[0] = 0xFE;
	buff[1] = 19;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 9;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;	// cmd id; //让zigbee模块收到后直接转发

	/* 组装发送给 RF模块的数据 */
	buff[17] = 0x16;
	if (type == 0x0)
		buff[18] = 0xF6;
	else if (type == 0x1)
		buff[18] = 0xFC;
	buff[19] = 0x01;
	buff[20] = keyVal;

	/* 这里需要确定下 是按位^ 还是求和 */
	//buff[21] = computeCheckSum( &buff[17], 4);
	for (int i = 0; i < 4; i++)
	{
		checkSum += buff[17+i];
	}

	buff[21] = checkSum & 0xff;

	buff[22] = 0x08;

	buff[23] = computeCheckSum( &buff[1], 22 );

	changeBytesToStr( buff, 24, result );
}

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
void sendStopLearnCmd( unsigned short int nwkAddr, unsigned char endPoint, char *result )
{
	unsigned char buff[100];
	unsigned short checkSum = 0;
	buff[0] = 0xFE;
	buff[1] = 18;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 8;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;	// cmd id; //让zigbee模块收到后直接转发

	/* 组装发送给 RF模块的数据 */
	buff[17] = 0x16;
	buff[18] = 0xFE;
	buff[19] = 0x00;

	/* 这里需要确定下 是按位^ 还是求和 */
	//buff[21] = computeCheckSum( &buff[17], 4);
	for (int i = 0; i < 3; i++)
	{
		checkSum += buff[17+i];
	}

	buff[20] = checkSum & 0xff;

	buff[21] = 0x08;

	buff[22] = computeCheckSum( &buff[1], 21 );

	changeBytesToStr( buff, 23, result );
}

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
void sendLearnKeyCmd( unsigned short int nwkAddr, unsigned char endPoint, char type,  char keyVal, char *result )
{
	unsigned char buff[100];
	unsigned short checkSum = 0;
	buff[0] = 0xFE;
	buff[1] = 19;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 9;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;	// cmd id; //让zigbee模块收到后直接转发阿尔维斯

	/* 组装发送给 RF模块的数据 */
	buff[17] = 0x16;
	if (type == 0x0)
		buff[18] = 0xF7;
	else if (type == 0x1)
		buff[18] = 0xFD;
	buff[19] = 0x01;
	buff[20] = keyVal;

	/* 这里需要确定下 是按位^ 还是求和 */
	//buff[21] = computeCheckSum( &buff[17], 4);
	for (int i = 0; i < 4; i++)
	{
		checkSum += buff[17+i];
	}

	buff[21] = checkSum & 0xff;

	buff[22] = 0x08;

	buff[23] = computeCheckSum( &buff[1], 22 );

	changeBytesToStr( buff, 24, result );
}

/* ************************************************************************
 *  int getLearnStatus( char *msgVal, int len )
 *
 *  info: 开始学习 APP----> gateway (转发) --> zigbee (转发) -serial-> RF模块
 *  in:
 *  	msgVal : 类型-char *  描述-message buf
 *  	len: 类型-int    描述-message length
 *  return:
 *  	0 学习失败
 *  	1 学习成功
 *
 * ************************************************************************/
/*
 * 学习成功返回：
 * 普通设备 16  E6  01  ser  sum  08
 * 空调设备 16  EC  01  ser  sum  08
 *
 *
 * */
int getLearnStatus( char *msgVal, int len )
{
	if (msgVal[3] == 0x16 && (msgVal[4] == 0xE6 ||  msgVal[4] == 0xEC))
	{
		return msgVal[5];
	}

	return 0;
}

/*
 * 发送遥控器参数：
 * 单独发送遥控器参数 01 Len0 Text0
 *
 *
 * */
void sendRemConParaCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int len,  char *para, char *result )
{
	unsigned char hexBuff[100];
	int hexLen = 0;

	changeHexStrToBytes( para, len, hexBuff, 100);

	hexLen = len/2;
	if (len%2 == 1)
		hexLen++;

	unsigned char buff[600];
	buff[0] = 0xFE;
	buff[1] = 15+hexLen;						// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;							// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;						// option
	buff[12] = 0x1E;						// radius
	buff[13] = 5+hexLen;						// msg len
	buff[14] = 0x01;						// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;						// cmd id; //让zigbee模块收到后直接转发阿尔维斯

	buff[17] = 0x01;						// user cmd id

	buff[18] = hexLen;

	memcpy(&buff[19], hexBuff, hexLen);


	buff[19+hexLen] = computeCheckSum( &buff[1], 19+hexLen-1 );

	changeBytesToStr( buff, 19+hexLen+1, result );
}

/*
 * 发送按键参数：
 * 单独发送遥控器KeyId 02 Len1 Text1
 *
 *
 * */
void sendRemConKeyParaCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int len,  char *para, char *result )
{
	unsigned char hexBuff[100];
	int hexLen = 0;

	changeHexStrToBytes( para, len, hexBuff, 100);

	hexLen = len/2;
	if (len%2 == 1)
		hexLen++;

	unsigned char buff[600];
	buff[0] = 0xFE;
	buff[1] = 15+hexLen;				// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;					// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;				// option
	buff[12] = 0x1E;				// radius
	buff[13] = 5+hexLen;				// msg len
	buff[14] = 0x01;				// frameControl
	buff[15] =  transId++;

	buff[16] = 0x01;				// cmd id; //让zigbee模块收到后直接转发阿尔维斯

	buff[17] = 0x02;						// user cmd id

	buff[18] = hexLen;

	memcpy(&buff[19], hexBuff, hexLen);


	buff[19+hexLen] = computeCheckSum( &buff[1], 19+hexLen-1 );

	changeBytesToStr( buff, 19+hexLen+1, result );
}

/*
 * 发送遥控器参数+按键参数：
 * 一起发送 03 Len0 Text0 Len1 Text1
 *
 * 如果 Len0 + Len1 长度 超过 70，需要拆分成2条指令发送：
 * 分别调用 sendRemConParaCmd + sendRemConKeyParaCmd 一次
 *
 *
 * */
void sendRemConAllParaCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int rem_len,  char *rem_para, unsigned short int key_len, char *key_para, char *result )
{
	unsigned char hexRemBuff[150];
	unsigned char hexKeyBuff[150];
	int hexRemLen = 0;
	int hexKeyLen = 0;

	changeHexStrToBytes( rem_para, rem_len, hexRemBuff, 150);
	changeHexStrToBytes( key_para, key_len, hexKeyBuff, 150);

	hexRemLen = rem_len/2;
	if (rem_len%2 == 1)
		hexRemLen++;

	hexKeyLen = key_len/2;
	if (key_len%2 == 1)
		hexKeyLen++;


	unsigned char buff[900];
	buff[0] = 0xFE;
	buff[1] = 16+hexRemLen+hexKeyLen;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;						// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;					// option
	buff[12] = 0x1E;					// radius
	buff[13] = 6+hexRemLen+hexKeyLen;	// msg len
	buff[14] = 0x01;					// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;					// cmd id; //让zigbee模块收到后直接转发阿尔维斯

	buff[17] = 0x03;						// user cmd id

	buff[18] = hexRemLen;

	memcpy(&buff[19], hexRemBuff, hexRemLen);

	buff[19+hexRemLen] = hexKeyLen;

	memcpy(&buff[20+hexRemLen], hexKeyBuff, hexKeyLen);

	buff[20+hexRemLen+hexKeyLen] = computeCheckSum( &buff[1], 20+hexRemLen+hexKeyLen-1 );

	changeBytesToStr( buff, 20+hexRemLen+hexKeyLen+1, result );
}










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

void sendAirConditionParamCmd( unsigned short int nwkAddr, unsigned char endPoint,
		unsigned char acMode, unsigned char acFan, unsigned char acTemp, unsigned short int len,  char *para, char *result )
{
	unsigned char hexBuff[100];
	int hexLen = 0;

	changeHexStrToBytes( para, len, hexBuff, 100);

	hexLen = len/2;
	if (len%2 == 1)
		hexLen++;

	unsigned char buff[100];
	unsigned short checkSum = 0;
	buff[0] = 0xFE;
	buff[1] = 18 + hexLen;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 3 + 5 + hexLen;		// msg len

	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;	// cmd id; //让zigbee模块收到后直接转发

	// 04 Mode Fan Temp paramLen acParam
	// 组装发送给 RF模块的数据
	buff[17] = 0x04;
	buff[18] = acMode;
	buff[19] = acFan;
	buff[20] = acTemp;
	buff[21] = hexLen;

	memcpy(&buff[22], hexBuff, hexLen);

	buff[22 + hexLen] = computeCheckSum( &buff[1], 22 + hexLen -1);

	changeBytesToStr( buff, 22 + hexLen + 1, result);
}

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
void sendAirConditionParamCmdAll( unsigned short int nwkAddr, unsigned char endPoint, unsigned char size,
		unsigned char acMode[], unsigned char acFan[], unsigned char acTemp[], unsigned short int len[],  char *para[], char *result )
{

	unsigned int i = 0;
	unsigned int length = 0;

	unsigned char hexBuff[2][150];
	int hexLen[2];

	/*__android_log_print( ANDROID_LOG_INFO, "gj", "-------start-------\n");

	__android_log_print( ANDROID_LOG_INFO, "gj", "acModeArr[0]=%d\n",acMode[0]);
	__android_log_print( ANDROID_LOG_INFO, "gj", "acModeArr[1]=%d\n",acMode[1]);

	__android_log_print( ANDROID_LOG_INFO, "gj", "acFanArr[0]=%d\n",acFan[0]);
	__android_log_print( ANDROID_LOG_INFO, "gj", "acFanArr[1]=%d\n",acFan[1]);

	__android_log_print( ANDROID_LOG_INFO, "gj", "acTempArr[0]=%d\n",acTemp[0]);
	__android_log_print( ANDROID_LOG_INFO, "gj", "acTempArr[1]=%d\n",acTemp[1]);

	__android_log_print( ANDROID_LOG_INFO, "gj", "acParamLenArr[0]=%d\n",len[0]);
	__android_log_print( ANDROID_LOG_INFO, "gj", "acParamLenArr[1]=%d\n",len[1]);

	__android_log_print( ANDROID_LOG_INFO, "gj", "para[0][0]=%d\n",para[0][0]);
	__android_log_print( ANDROID_LOG_INFO, "gj", "para[0][0]=%d\n",para[1][0]);

	__android_log_print( ANDROID_LOG_INFO, "gj", "char=%d", sizeof(char));
	__android_log_print( ANDROID_LOG_INFO, "gj", "short=%d", sizeof(short));
	__android_log_print( ANDROID_LOG_INFO, "gj", "int=%d", sizeof(int));
	__android_log_print( ANDROID_LOG_INFO, "gj", "long=%d", sizeof(long));*/


	for (i = 0; i < size; i++)
	{
		changeHexStrToBytes( para[i], len[i], hexBuff[i], 150);

		hexLen[i] = len[i] / 2;
		if (len[i] % 2 == 1)
			hexLen[i]++;
	}

	unsigned char buff[900];
	unsigned short checkSum = 0;
	buff[0] = 0xFE;
	buff[1] = 0;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 0;    	// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;	// cmd id; //让zigbee模块收到后直接转发

	// 04 Mode Fan Temp paramLen acParam
	// 组装发送给 RF模块的数据
	if (size == 1)
	{
		buff[17] = 0x04;
	}
	else if (size == 2)
	{
		buff[17] = 0x05;
	}

	length = 17;

	for (i = 0; i < size; i++)
	{
		buff[++length] = acMode[i];
		buff[++length] = acFan[i];
		buff[++length] = acTemp[i];
		buff[++length] = hexLen[i];

		memcpy(&buff[++length], hexBuff[i], hexLen[i]);
		length = length + hexLen[i] - 1;

	}

	length = length + 1;

	buff[1]  = (length + 1) - 4 -1;	   // msg len
	buff[13] = (length + 1) -14 -1;    // data len

	buff[length] = computeCheckSum( &buff[1], length + 1 - 2);

	changeBytesToStr( buff, length + 1, result);
}

/* ************************************************************************
 *  void sendSaveCodeCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int code, char *result )
 *  for: 空调遥控器
 *  info: 发送code 鎷组
 *  in:
 *  	nwkAddr : 类型-unsigned short int  描述-
 *  	endPoint: 类型-unsigned char  描述-服务器端口
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  	code: 兼容以前的
 *  return:
 *
 * ************************************************************************/
/*
 * 发送保存code按键：
 * 16  FF  01  00  sum  08
 *
 *
 * */
void sendSaveCodeCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned short int code, char *result )
{
	unsigned char buff[100];
	unsigned short checkSum = 0;
	buff[0] = 0xFE;
	buff[1] = 19;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;	// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 0x09;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;	// cmd id; //让zigbee模块收到后直接转发

	/* 组装发送给 RF模块的数据 */
	buff[17] = 0x16;
	buff[18] = 0xFF;
	buff[19] = 0x01;
	buff[20] = 0x00;

	for (int i = 0; i < 4; i++)
	{
		checkSum += buff[17+i];
	}

	buff[21] = checkSum & 0xff;

	buff[22] = 0x08;

	buff[23] = computeCheckSum( &buff[1], 22 );

	changeBytesToStr( buff, 24, result);
}




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
void sendDeviceDelCmd( char *data, int dataLen,char *result )
{
	unsigned char buff[51200];
	buff[0] = 0xEF;
	buff[1] = DEVICE_DEL_CMD>>8;
	buff[2] = DEVICE_DEL_CMD & 0xFF;
	for (int i = 0; i < dataLen; i++)
		buff[3+i] = data[i];
	changeBytesToStr( buff, dataLen+3, result );
}


void setUserInfo( unsigned char userId, char *name, int nameLen, unsigned char faceNo, char *result )
{
	unsigned char buff[100];
	if( userId >= 100 || nameLen > 8 )
		return;
	buff[0] = 0xEF;
	buff[1] = SET_USER_INFO >> 8;
	buff[2] = SET_USER_INFO & 0xFF;
	buff[3] = userId;
	buff[4] = faceNo;
	buff[5] = nameLen;
	for( int i = 0; i < nameLen; i++ )
		buff[6 + i] = (unsigned char)name[i];
	changeBytesToStr( buff, 6 + nameLen, result );
}

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
int handleSpMessage(const char *msg, int len, char* result)
{
	unsigned int buf_len = 100 * 1024;
	unsigned char *byteMessage = (unsigned char *)calloc(buf_len, 1);
	changeStrToBytes( msg, len, byteMessage, buf_len );
    memcpy(result, byteMessage + 3, buf_len - 3);
    free(byteMessage);
    return 0;
}


//#define GET_MODE_DATA				0x0025
//#define GET_LINK_DATA				0x0026
//#define GET_DEVICE_NAME_DATA		0x0027
//#define GET_ROOM_DATA				0x0028
//#define GET_EXTRA_DATA			0x0029
//#define GET_IR_DATA				0x002A
static int isSpMessage(const char *msg, int len, struct MsgInfo_S *msgInfo)
{
	int cmd;
	unsigned char buff[1000];
	int message_len = 0;

	if (len > 20) {
		message_len = 20;
	} else {
		message_len = len;
	}

	changeStrToBytes( msg, message_len, buff, 1000 );

	if (buff[0] == 0xEF)
	{
		cmd = (int)buff[1] * 0x100 + buff[2];
		switch( cmd )
		{
			case GET_MODE_DATA:
				msgInfo->type = MSG_TYPE_GET_MODE_DATA;
				return 1;
			case GET_LINK_DATA:
				msgInfo->type = MSG_TYPE_GET_LINK_DATA;
				return 1;
			case GET_DEVICE_NAME_DATA:
				msgInfo->type = MSG_TYPE_GET_DEVICE_NAME_DATA;
				return 1;
			case GET_ROOM_DATA:
				msgInfo->type = MSG_TYPE_GET_ROOM_DATA;
				return 1;
			case GET_EXTRA_DATA:
				msgInfo->type = MSG_TYPE_GET_EXTRA_DATA;
				return 1;
			case GET_IR_DATA:
				msgInfo->type = MSG_TYPE_GET_IR_DATA;
				return 1;
		}
	}

	return 0;
}


/**
 * int handleMsg( const char *msg, int len, struct MsgInfo_S *msgInfo )
 *
 * msg: xmpp message
 * msgInfo : msg report to jni
 */
int handleMsg( const char *msg, int len, struct MsgInfo_S *msgInfo )
{
	static int totalDevice = 0;
	int clusterID;
	int cmd;
	int i;

	if (isSpMessage(msg, len, msgInfo))
	{
		return 0;
	}

	unsigned char buff[1000];
	changeStrToBytes( msg, len, buff, 1000 );

	msgInfo->charValueLen = 0;

	#ifdef __ANDROID_VERSION__
		__android_log_print( ANDROID_LOG_INFO, "lwj", "handleMsg buff[0] = 0x%x", buff[0] );
	#endif

	// 普通设备控制消息返回
	if( buff[0] == 0xFE )
	{
		cmd = (int)buff[2] * 0x100 + buff[3];
		#ifdef __ANDROID_VERSION__
			__android_log_print( ANDROID_LOG_INFO, "lwj", "handleMsg cmd = 0x%x", cmd );
		#endif
		switch( cmd )
		{
			case AF_INCOMING_MSG:
				//遍历设备列表找到对应设备
				msgInfo->nwkAddr = (unsigned short)buff[9] * 0x100 + buff[8];
				msgInfo->endPoint = buff[10];
				for( i =0; i < deviceCount; i++ )
				{
					if( deviceInfo[i].nwkAddr == msgInfo->nwkAddr && deviceInfo[i].endPoint == msgInfo->endPoint )
						break;
				}
				if( i >= deviceCount )
				{
				#ifdef __ANDROID_VERSION__
					__android_log_print( ANDROID_LOG_INFO, "lwj", "ZIGBEE: handleMsg AF_INCOMING_MSG can not found nwkAddr!" );
				#else
					printf( "ZIGBEE: handleMsg AF_INCOMING_MSG can not found nwkAddr!\r\n" );
				#endif
					return -1;
				}

				#ifdef __ANDROID_VERSION__
					__android_log_print( ANDROID_LOG_INFO, "lwj", "deviceInfo[i].deviceId = 0x%x", deviceInfo[i].deviceId );
				#endif

				// 上报消息
				switch( deviceInfo[i].deviceId )
				{
					case ZCL_HA_DEVICEID_CTL_ONOFF:
					case ZCL_HA_DEVICEID_CTL_ONOFF_TWO:
					case ZCL_HA_DEVICEID_CTL_ONOFF_THR:
					{
						return 1;
					}
					case ZCL_HA_DEVICEID_DIMMER:
					{
						clusterID = (int)buff[7] * 0x100 + buff[6];
						if (buff[1] == 0x16 && buff[23] == 0x0B)
							return 1;
						if (clusterID == 0x0008) // onoff
						{
							msgInfo->type = MSG_TYPE_REPORT_STATE;
							if (buff[21] == 0x05)
								msgInfo->value = 1;
							else if (buff[21] == 0x06)
								msgInfo->value = 0;
							return 0;
						}
						else if (clusterID == 0x0300) // color
						{
							if (buff[21] == 0x00)
							{
								msgInfo->type = MSG_TYPE_REPORT_DIMMER_COLOR;
								msgInfo->charValueLen = 6;
								msgInfo->charValue[0] = buff[22]; // onoff
								msgInfo->charValue[1] = buff[23]; // mode
								msgInfo->charValue[2] = buff[24]; // col_w
								msgInfo->charValue[3] = buff[25]; // col_r
								msgInfo->charValue[4] = buff[26]; // col_g
								msgInfo->charValue[5] = buff[27]; // col_b
								return 0;
							}
						}
						else if (clusterID == 0x0005) // scene
						{
							if (buff[21] == 0x07)
							{
								msgInfo->type = MSG_TYPE_REPORT_DIMMER_SCENE;
								msgInfo->charValueLen = 51;
								memcpy(&msgInfo->charValue[0], &buff[22], 51); // 3 条： 每条：senceID 1/NAME_LEN 1/NAME 11/WRGB 4
								return 0;
							}
						}
					}
					break;
					case ZCL_HA_DEVICEID_ON_OFF_SWITCH:
					{
						clusterID = (int)buff[7] * 0x100 + buff[6];
						if (clusterID == 0x0016) //设备主动上报信息/app来获取电量数据信息的cluser ID为0x0016
						{
							/*
							 * 电量统计的数据格式为0x11 0x22  0x33 0x44 0x55 0x66 0x77 0x88。
        					   0x11 0x22 ：表示当前功率，高位在前低位在后，单位W。
       						   0x33 0x44 0x55 0x66 0x77 0x88：表示当前使用的电量，高位在前，低位在后。
       						   0x33 0x44 0x55 0x66 0x77：表示整数部分的值。0x88：表示小书部分的值。单位kw.h.
							 * */
							//暂时不做处理
							msgInfo->type = MSG_TYPE_REPORT_SWITCH_POWER;
							msgInfo->intValue = (buff[21]<<8) | buff[22];
							msgInfo->charValueLen = 6;
							msgInfo->charValue[0] = buff[23];
							msgInfo->charValue[1] = buff[24];
							msgInfo->charValue[2] = buff[25];
							msgInfo->charValue[3] = buff[26];
							msgInfo->charValue[4] = buff[27];
							msgInfo->charValue[5] = buff[28];
							return 0;
						}
					}
					case ZCL_HA_DEVICEID_ON_OFF_LIGHT:
					case ZCL_HA_DEVICEID_CURTAIN_CONTROL:
					case ZCL_HA_DEVICEID_LOCK:
					case ZCL_HA_DEVICEID_ELE_SLIDING_DEV: //电动推动器
						if( deviceInfo[i].deviceId == 0x0502 && deviceInfo[i].endPoint == 0x21 )
						{
							/*if( doorOpenCnt < 2 )
							{
								doorOpenCnt++;
								return 1;
							}
							else
							{
								msgInfo->type = MSG_TYPE_REPORT_DOOR_OPEN;
								msgInfo->value = 0;
								return 0;
							}*/
							return 1;
						}
						else if( deviceInfo[i].deviceId == 0x0501 && buff[1] == 0x1B )
						{
							msgInfo->type = MSG_TYPE_REPORT_CURTAIN_PROGRESS;
							msgInfo->intValue = buff[30] * 0x1000000 + buff[29] * 0x10000 + buff[28] * 0x100 + buff[27];
							return 0;
						}
						else if (deviceInfo[i].deviceId == 0x0505 && buff[1] == 0x1B)
						{
							msgInfo->type = MSG_TYPE_REPORT_CURTAIN_PROGRESS;
							msgInfo->intValue = buff[30] * 0x1000000 + buff[29] * 0x10000 + buff[28] * 0x100 + buff[27];
							return 0;
						}
						/*if( buff[23] == 0x0B )
						{
							msgInfo->type = MSG_TYPE_REPORT_STATE;
							msgInfo->value = buff[24];
						}
						else */
						if (buff[23] == 0x0A)
						{
							msgInfo->type = MSG_TYPE_REPORT_STATE;
							msgInfo->value = buff[27];
						}
						else if( buff[23] == 0x01 )
						{
							msgInfo->type = MSG_TYPE_REPORT_STATE;
							msgInfo->value = buff[28];
						}
						else
							return 1;
						return 0;
					case ZCL_HA_DEVICEID_POWER_LIGHT:	//POWER_LIGHT
						{
							clusterID = (int)buff[7] * 0x100 + buff[6];
							if (clusterID == 0x0006)
							{
								if (buff[1] == 0x17)
								{

									if (buff[21] == 0x01)
									{
										msgInfo->type = MSG_TYPE_REPORT_STATE;
										msgInfo->value = buff[23];
										msgInfo->intValue = buff[22];
										return 0;
									}
								}
							}
							else if (clusterID == 0x0016) //设备主动上报信息/app来获取电量数据信息的cluser ID为0x0016
							{
								/*
								 * 电量统计的数据格式为0x11 0x22  0x33 0x44 0x55 0x66 0x77 0x88。
								   0x11 0x22 ：表示当前功率，高位在前低位在后，单位W。
								   0x33 0x44 0x55 0x66 0x77 0x88：表示当前使用的电量，高位在前，低位在后。
								   0x33 0x44 0x55 0x66 0x77：表示整数部分的值。0x88：表示小书部分的值。单位kw.h.
								 * */

								//暂时不做处理
								msgInfo->type = MSG_TYPE_REPORT_SWITCH_POWER;
								msgInfo->intValue = (buff[24]<<8) | buff[25];
								msgInfo->charValueLen = 6;
								msgInfo->charValue[0] = buff[26];
								msgInfo->charValue[1] = buff[27];
								msgInfo->charValue[2] = buff[28];
								msgInfo->charValue[3] = buff[29];
								msgInfo->charValue[4] = buff[30];
								msgInfo->charValue[5] = buff[31];
								return 0;

			#if 0
								msgInfo->type = MSG_TYPE_REPORT_SWITCH_POWER;
								msgInfo->intValue = (buff[23]<<8) | buff[24];
								msgInfo->charValue[0] = buff[25];
								msgInfo->charValue[1] = buff[26];
								msgInfo->charValue[2] = buff[27];
								msgInfo->charValue[3] = buff[28];
								msgInfo->charValue[4] = buff[29];
								msgInfo->charValue[5] = buff[30];
			#endif
								return 1;
							}
							else if (clusterID == 0x0017) //功率校准上报
							{
								//packet[23]; //CMDID  0x02
								//packet[24]; // 0x00 已校准  0x01 未校准

								return 1;
							}
						}
					case ZCL_HA_DEVICEID_TEMPERATURE_SENSOR:
						clusterID = (int)buff[7] * 0x100 + buff[6];
						switch( clusterID )
						{
							case 0x402:
								// 温度是一个 float 范围为 -40 - 125
								// 所以这里需要执行一个算法
								// 1)先判断 buff[28] 的最高位是否为1，如果为1，则为
								msgInfo->type = MSG_TYPE_REPORT_TEMPERATURE;
								msgInfo->intValue = buff[28] * 0x100 + buff[27];
								return 0;
							case 0x405:
								msgInfo->type = MSG_TYPE_REPORT_HUMIDITY;
								msgInfo->intValue = buff[28] * 0x100 + buff[27];
								return 0;
							case 0x0407:
								#ifdef __ANDROID_VERSION__
									__android_log_print( ANDROID_LOG_INFO, "lwj", "send motion msg" );
								#endif
								msgInfo->type = MSG_TYPE_MOTION;
								msgInfo->value = 0;
								return 0;
							case 0x0408: //光敏 上报  0x01 白天  0x00 黑夜 预留

								msgInfo->type = MSG_TYPE_REPORT_DAYNIGHT;
								msgInfo->intValue = buff[27];
								return 0;
								break;
							default:
								break;
						}
						break;
					case ZCL_HA_DEVICEID_DOOR:
						#ifdef __ANDROID_VERSION__
							__android_log_print( ANDROID_LOG_INFO, "lwj", "buff[1] = 0x%x", buff[1] );
						#endif
						if( buff[1] == 0x18 ) 
						{
							/*if( buff[23] != 0x0A )
								return 1;
							msgInfo->type = MSG_TYPE_REPORT_STATE;
							msgInfo->value = buff[27];*/
							int dataLen = buff[20];
							if( buff[20 + dataLen] == 0x01 )
								msgInfo->type = MSG_TYPE_REPORT_DOOR_OPEN;
							msgInfo->value = 0;
							return 0;
						}
						else if( buff[1] == 0x15 )
						{
							#ifdef __ANDROID_VERSION__
								__android_log_print( ANDROID_LOG_INFO, "lwj", "buff[24] = 0x%x", buff[24] );
							#endif

							int dataLen = buff[20];

							if (buff[24] == 0x01) {
								msgInfo->type = MSG_TYPE_REPORT_DOOR_OPEN;
							} else if (buff[24] == 0x03) {
								msgInfo->type = MSG_TYPE_KNOCK_ON_THE_DOOR;
							} else if( buff[20 + dataLen] == 0x03) {
								msgInfo->type = MSG_TYPE_KNOCK_ON_THE_DOOR;
							}
							msgInfo->value = 0;
							return 0;
						}
						break;
					case ZCL_HA_DEVICEID_IAS_ZONE:
						switch( deviceInfo[i].endPoint )
						{
							case 0x40:
								msgInfo->type = MSG_TYPE_MOTION;
								msgInfo->value = 0;
								return 0;
							case 0x41:
								msgInfo->type = MSG_TYPE_SMOKE;
								msgInfo->value = 0;
								return 0;
							/* 2015-12-23 add for new somoke */
							case 0x20:
								msgInfo->type = MSG_TYPE_SMOKE;
								msgInfo->value = buff[3+buff[1]];
								return 0;
							default:
								break;
						}
						break;		
					case ZCL_HA_DEVICEID_SOS:
						if( buff[1] == 0x15 && buff[24] == 0x01 )
						{
							msgInfo->type = MSG_TYPE_REPORT_SOS;
							return 0;
						}
						break;
					case ZCL_HA_DEVICEID_CO_ALARM:
						/* 2015-12-23 add for new 燃气报警 */
						if( deviceInfo[i].endPoint == 0x20 && buff[1] == 0x15 )
						{
							if( buff[24] == 0x00 )
								msgInfo->type = MSG_TYPE_REPORT_CO_ALARM;
							else		//( buff[24] == 0x01 )
								msgInfo->type = MSG_TYPE_REPORT_CH4_ALARM;
							return 0;
						}
						break;

					case ZCL_HA_DEVICEID_INFRA_FORWARD:
						/*
						 *
						 * 0xfe 0x1a 0x44 0x81 0x00 0x00
						 * 0x06 0x00 0x3c 0x5c 0x20 0xf0
						 * 0x00 0xc5 0x00 0x70 0x92 0x0a
						 * 0x00 0x00 0x09 0x19 0x01 0x00
						 * 0x16 0xe6 0x01 0x00 0xfd 0x08
						 * 0x51
						 *
						 * */
						if( buff[1] == 0x1a )
						{
							msgInfo->type = MSG_TYPE_REPORT_REMOTER_LEARNING;
							/* modify for learn */
#if 0
							for( i = 0; i < 208; i++ )
								msgInfo->charValue[i] = buff[27 + i];
								//keyBuff[i] = buff[27 + i];
							return buff[27+3];
							msgInfo->intValue = 208;
							msgInfo->charValueLen = 208;
							return 0;
#endif
							msgInfo->intValue = (int)buff[26];
							return 0;
						}
						break;

					case ZCL_HA_DEVICEID_RAIN_ALARM: 	// 雨水探测器
						/* 2015-12-23 add for new 雨水探测器 */
						/*
						 * bit0(表示光的状态：0白天 1：黑夜)
						   bit1(表示水的状态：0：无水 1：有水 )
						 * */
						if( deviceInfo[i].endPoint == 0x20 )
						{
							msgInfo->type = MSG_TYPE_REPORT_RAIN_ALARM;
//							msgInfo->value = ( msgInfo->value & (0xFF ^ (0x1 << 0))) | (buff[3+buff[1]-1] << 0);
//							msgInfo->value = ( msgInfo->value & (0xFF ^ (0x1 << 1))) | (buff[3+buff[1]] << 1);
                            msgInfo->value = (buff[3+buff[1]]);
							return 0;
						}
						break;

					case ZCL_HA_DEVICEID_INTEL_REMOTE_CONTROL:		// 万能空调遥控器（带设备控制）
						if( deviceInfo[i].endPoint == 0x20 )
						{
							int dataLen = buff[20];
							int type = buff[20 + 4];
							msgInfo->type = MSG_TYPE_REPORT_SAVE_AC_KEY;

							if (dataLen == 7) {
								if (type == 4) {
									msgInfo->charValueLen = 3;
									msgInfo->charValue[0] = buff[20 + 5];
									msgInfo->charValue[1] = buff[20 + 6];
									msgInfo->charValue[2] = buff[20 + 7];
									return 0;
								}
							}

							if (dataLen == 10) {
								if (type == 5) {
									msgInfo->charValueLen = 6;
									msgInfo->charValue[0] = buff[20 + 5];
									msgInfo->charValue[1] = buff[20 + 6];
									msgInfo->charValue[2] = buff[20 + 7];
									msgInfo->charValue[3] = buff[20 + 8];
									msgInfo->charValue[4] = buff[20 + 9];
									msgInfo->charValue[5] = buff[20 + 10];
									return 0;
								}
							}
						}
						break;

					default:
						break;
				}
				break;
			case APP_DEVICE_STATUS_NOTIFY:
				msgInfo->type = MSG_TYPE_ONLINE_CHANGE;
				msgInfo->nwkAddr = (unsigned short)buff[13] * 0x100 + buff[12];
				msgInfo->endPoint = buff[14];
				for( i =0; i < deviceCount; i++ )
				{
					/*改用 iEEAddr 来判断 */
#if 0
					for( j = 0; j < 8; j++ )
						deviceInfo[deviceCount].IEEEAddr = deviceInfo[deviceCount].IEEEAddr * 0x100 + buff[6 + REPORT_DEVICE_LEN * i + ( 7 - j )];
#endif
					if( deviceInfo[i].nwkAddr == msgInfo->nwkAddr && deviceInfo[i].endPoint == msgInfo->endPoint )
					{
						msgInfo->value = buff[15];
						return 0;
					}
				}

			#ifdef __ANDROID_VERSION__
				__android_log_print( ANDROID_LOG_INFO, "lwj", "ZIGBEE: handleMsg AF_INCOMING_MSG can not found nwkAddr!" );
			#else
				printf( "ZIGBEE: handleMsg APP_DEVICE_STATUS_NOTIFY can not found nwkAddr!\r\n" );
			#endif				
				break;
			default:
				return 1;
		}
	}
	// 接收联动等特殊消息
	else if( buff[0] == 0xEF )
	{
		cmd = (int)buff[1] * 0x100 + buff[2];
		switch( cmd )
		{
			case GET_USER_INFO:
				{
					for( i =0; i < deviceCount; i++ )
					{
						if( deviceInfo[i].deviceId == 0x0502 && deviceInfo[i].status == 1 )
							break;
					}
					if( i >= deviceCount )
						return 1;
					msgInfo->type = MSG_TYPE_USER_LIST;
					msgInfo->nwkAddr = deviceInfo[i].nwkAddr;
					msgInfo->endPoint = deviceInfo[i].endPoint;
					int len = (int)buff[3] * 0x100 + buff[4];
					memcpy( msgInfo->charValue, &buff[5], len );
					msgInfo->charValueLen = len;
					return 0;
				}
				break;
			case LOCK_OPEN_NOTIFY:
				msgInfo->nwkAddr = (unsigned short)buff[4] * 0x100 + buff[3];
				msgInfo->endPoint = buff[5];
				msgInfo->type = MSG_TYPE_REPORT_LOCK_OPEN;
				memcpy( msgInfo->charValue, &buff[6], 14 );
				msgInfo->charValueLen = 14;
				return 0;
			case GET_PHOTO_SENSITIVE_CFG:
				for( i =0; i < deviceCount; i++ )
				{
					if( deviceInfo[i].deviceId == 0x0302 )
						break;
				}
				if( i >= deviceCount )
					return 1;
				msgInfo->type = MSG_TYPE_PHOTO_SENSITIVE_CFG;
				msgInfo->nwkAddr = deviceInfo[i].nwkAddr;
				msgInfo->endPoint = deviceInfo[i].endPoint;
				msgInfo->value = buff[3];
				msgInfo->intValue = (int)buff[3];
				return 0;
			case GET_MOTION_CFG:
				for( i =0; i < deviceCount; i++ )
				{
					if( deviceInfo[i].deviceId == 0x0302 )
						break;
				}
				if( i >= deviceCount )
					return 1;
				msgInfo->type = MSG_TYPE_MOTION_CFG;
				msgInfo->nwkAddr = deviceInfo[i].nwkAddr;
				msgInfo->endPoint = deviceInfo[i].endPoint;
				msgInfo->value = buff[3];
				msgInfo->intValue = (int)buff[3];
				return 0;
			case GET_AT_HOME_MODE:
				msgInfo->type = MSG_TYPE_REPORT_AT_HOME_MODE;
				msgInfo->value = buff[3];
				msgInfo->intValue = (int)buff[3];
				return 0;
			case GET_LEAVE_HOME_DELAY:
				msgInfo->type = MSG_TYPE_REPORT_LEAVE_HOME_DELAY;
				msgInfo->value = buff[3];
				msgInfo->intValue = (int)buff[3];
				return 0;
			case SET_MODE_DATA:
				msgInfo->type = MSG_TYPE_REPORT_MODEDATA_CHANGE;
				if (buff[3+(len+1)/5-3-1] == 0xEF && buff[3+(len+1)/5-3-2] == 0xFE)
				{
					memcpy( msgInfo->charValue, &buff[3], (len+1)/5-3-3 );
					msgInfo->charValueLen = (len+1)/5-3-3;
					msgInfo->intValue = buff[3+(len+1)/5-3-3];
				}
				else
				{
					memcpy( msgInfo->charValue, &buff[3], (len+1)/5-3 );
					msgInfo->charValueLen = (len+1)/5-3;
					msgInfo->intValue = 1;
				}
				return 0;
			case SET_LINK_DATA:
				msgInfo->type = MSG_TYPE_REPORT_LINKDATA_CHANGE;
				memcpy( msgInfo->charValue, &buff[3], (len+1)/5-3 );
				msgInfo->charValueLen = (len+1)/5-3;
				return 0;
			case GET_GW_VERSION:
				msgInfo->type = MSG_TYPE_REPORT_GW_VERSION;
				memcpy( msgInfo->charValue, &buff[3], (len+1)/5-3 );
				msgInfo->charValueLen = (len+1)/5-3;
				return 0;
			case DEVICE_DEL_CMD:
				msgInfo->type = MSG_TYPE_REPORT_DEVICE_DEL;
				memcpy(msgInfo->charValue, &buff[3], (len+1)/5-3);
				msgInfo->charValueLen = (len+1)/5-3;
				return 0;
			case REPORT_NEW_DEVICE:
				if (!deviceInfo)
					return 1;
				msgInfo->type = MSG_TYPE_NEW_DEVICE;
				deviceInfo[deviceCount].IEEEAddr = 0;
				for( i = 0; i < 8; i++ )
					deviceInfo[deviceCount].IEEEAddr = deviceInfo[deviceCount].IEEEAddr * 0x100 + buff[3  + ( 7 - i )];
				deviceInfo[deviceCount].nwkAddr = (unsigned short)buff[3 + 9] * 0x100 + buff[3 + 8];
				deviceInfo[deviceCount].profileId = (unsigned short)buff[3 + 11] * 0x100 + buff[3 + 10];
				deviceInfo[deviceCount].deviceId = (unsigned short)buff[3 + 13] * 0x100 + buff[3 + 12];
				deviceInfo[deviceCount].endPoint = buff[3 + 14];
				deviceInfo[deviceCount].status = buff[3 + 15];
				deviceInfo[deviceCount].LQI = buff[3 + 16];

#ifdef HAVE_POWER_DET
				if (devPacketLen > 17)
					deviceInfo[deviceCount].powerStatus = buff[3 + 17];
#endif

				if (devPacketLen > 18)
					deviceInfo[deviceCount].dev_status = buff[3 + 18];

#ifdef HAVE_DEV_VERSION
				if (devPacketLen > 23)
					memcpy(deviceInfo[deviceCount].dev_ver, &buff[3 + 19], 5);
#endif

				if( deviceInfo[deviceCount].deviceId != 0x0501 || deviceInfo[deviceCount].endPoint % 2 == 0 )
				{
					msgInfo->nwkAddr = deviceInfo[deviceCount].nwkAddr;
					msgInfo->endPoint = deviceInfo[deviceCount].endPoint;
					deviceCount++;
					memcpy(msgInfo->charValue, &buff[3], devPacketLen);
					msgInfo->charValueLen = devPacketLen;
					return 0;
				}
				break;
			case BGM_REP_STATUS:  // 背景音乐上报状态信息
				{
					// 上报信息：
					/*
					{"duration":%s,"playing":%s,"time":%s,"name":%s,"volMax":%s,"volCur":%s}
					*/
					msgInfo->type = MSG_TYPE_REPORT_BGM_STATUS;
					memcpy(msgInfo->charValue, &buff[3],(len+1)/5-3);				// Msg value by char array.
					msgInfo->charValueLen = (len+1)/5-3;							// Len of char array value.
					return 0;
				}
				break;
			case BGM_REP_DEVINFO: // 背景音乐设备信息
				{
					// 设备信息
					/*
					{"mac":"%s","devtype":"%s"}
					*/
					msgInfo->type = MSG_TYPE_REPORT_BGM_DEVINFO;
					memcpy(msgInfo->charValue, &buff[3], (len+1)/5-3);				// Msg value by char array.
					msgInfo->charValueLen = (len+1)/5-3;							// Len of char array value.
					return 0;
				}
				break;
			case DEL_LINK_DATA:
				msgInfo->type = MSG_TYPE_REPORT_LINK_DEL;
				memcpy(msgInfo->charValue, &buff[3], (len+1)/5-3);
				msgInfo->charValueLen = (len+1)/5-3;
				return 0;
			case GW_PING:
				msgInfo->type = MSG_TYPE_REPORT_GW_PING;
				return 0;
			default:
				break;
		}
	}

	return 1;
}

void getPhotoSensitiveCfg( char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = GET_PHOTO_SENSITIVE_CFG >> 8;
	buff[2] = GET_PHOTO_SENSITIVE_CFG & 0xFF;
	changeBytesToStr( buff, 3, result );
}

void setPhotoSensitiveCfg( bool beSet, unsigned long IEEEAddrSensitive, unsigned long IEEEAddrLight, char *result )
{
	unsigned char buff[100];
	int i;
	buff[0] = 0xEF;
	buff[1] = SET_PHOTO_SENSITIVE_CFG >> 8;
	buff[2] = SET_PHOTO_SENSITIVE_CFG & 0xFF;
	buff[3] = (char)beSet;
	unsigned long tempIEEEAddr = IEEEAddrSensitive;
	for( i = 0; i < 8; i++ )
	{
		buff[4 + i] = tempIEEEAddr % 0x100;
		tempIEEEAddr = tempIEEEAddr / 0x100;
	}
	tempIEEEAddr = IEEEAddrLight;
	for( i = 0; i < 8; i++ )
	{
		buff[12 + i] = tempIEEEAddr % 0x100;
		tempIEEEAddr = tempIEEEAddr / 0x100;
	}
	changeBytesToStr( buff, 20, result );
}

void getMotionCfg( char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = GET_MOTION_CFG >> 8;
	buff[2] = GET_MOTION_CFG & 0xFF;
	changeBytesToStr( buff, 3, result );
}

void setMotionCfg( bool beSet, unsigned long IEEEAddrSensitive, unsigned long IEEEAddrLight, char *result )
{
	unsigned char buff[100];
	int i;
	buff[0] = 0xEF;
	buff[1] = SET_MOTION_CFG >> 8;
	buff[2] = SET_MOTION_CFG & 0xFF;
	buff[3] = (char)beSet;
	unsigned long tempIEEEAddr = IEEEAddrSensitive;
	for( i = 0; i < 8; i++ )
	{
		buff[4 + i] = tempIEEEAddr % 0x100;
		tempIEEEAddr = tempIEEEAddr / 0x100;
	}
	tempIEEEAddr = IEEEAddrLight;
	for( i = 0; i < 8; i++ )
	{
		buff[12 + i] = tempIEEEAddr % 0x100;
		tempIEEEAddr = tempIEEEAddr / 0x100;
	}
	changeBytesToStr( buff, 20, result );
}

void setDoorPassword( unsigned char type, unsigned char startYear, unsigned char startMonth, unsigned char startDay, unsigned char startHour, unsigned char startMinute, unsigned char endYear, unsigned char endMonth, unsigned char endDay, unsigned char endHour, unsigned char endMinute, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = SET_DOOR_PASSWORD>>8;
	buff[2] = SET_DOOR_PASSWORD & 0xFF;
	buff[3] = type;
	buff[4] = startYear;
	buff[5] = startMonth;
	buff[6] = startDay;
	buff[7] = startHour;
	buff[8] = startMinute;
	buff[9] = endYear;
	buff[10] = endMonth;
	buff[11] = endDay;
	buff[12] = endHour;
	buff[13] = endMinute;
	changeBytesToStr( buff, 14, result );
}

void getAtHomeMode( char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = GET_AT_HOME_MODE >> 8;
	buff[2] = GET_AT_HOME_MODE & 0xFF;
	changeBytesToStr( buff, 3, result );
}

void setAtHomeMode( int mode, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = SET_AT_HOME_MODE >> 8;
	buff[2] = SET_AT_HOME_MODE & 0xFF;
	buff[3] = (unsigned char)mode;
	changeBytesToStr( buff, 4, result );
}

void getLeaveHomeDelay( char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = GET_LEAVE_HOME_DELAY >> 8;
	buff[2] = GET_LEAVE_HOME_DELAY & 0xFF;
	changeBytesToStr( buff, 3, result );
}

void setLeaveHomeDelay( int delay, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = SET_LEAVE_HOME_DELAY >> 8;
	buff[2] = SET_LEAVE_HOME_DELAY & 0xFF;
	buff[3] = (unsigned char)delay;
	changeBytesToStr( buff, 4, result );
}

void oneKeyControl( int type, int control, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = ONE_KEY_CONTROL >> 8;
	buff[2] = ONE_KEY_CONTROL & 0xFF;
	buff[3] = (unsigned char)type;
	buff[4] = (unsigned char)control;
	changeBytesToStr( buff, 5, result );
}

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
int setModeData( char *data, int dataLen,char *result )
{
	unsigned char buff[102400];
	int strLen = 0;

	buff[0] = 0xEF;
	buff[1] = SET_MODE_DATA>>8;
	buff[2] = SET_MODE_DATA & 0xFF;
	for (int i = 0; i < dataLen; i++)
		buff[3+i] = data[i];

	strLen = getChangeStrLen(dataLen + 3);
	//__android_log_print( ANDROID_LOG_INFO, "lwj", "strLen=%d", strLen);
	if (strLen >= 102400)
	{
		//__android_log_print( ANDROID_LOG_INFO, "lwj", ">102400");
		return -1;
	}
	changeBytesToStr( buff, dataLen+3, result );
	return 1;
}

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
int setLinkData( char *data, int dataLen,char *result )
{
	unsigned char buff[102400];
	int strLen = 0;

	buff[0] = 0xEF;
	buff[1] = SET_LINK_DATA>>8;
	buff[2] = SET_LINK_DATA & 0xFF;
	for (int i = 0; i < dataLen; i++)
		buff[3+i] = data[i];

	strLen = getChangeStrLen(dataLen + 3);
	//__android_log_print( ANDROID_LOG_INFO, "lwj", "strLen=%d", strLen);
	if (strLen >= 102400)
	{
		//__android_log_print( ANDROID_LOG_INFO, "lwj", ">102400");
		return -1;
	}
	changeBytesToStr( buff, dataLen+3, result );
	return 1;
}

/* ************************************************************************
 *  void getLinkData(char *result )
 *
 *  info: 从网关获得联动数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getLinkData(char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = GET_LINK_DATA>>8;
	buff[2] = GET_LINK_DATA & 0xFF;
	changeBytesToStr( buff, 3, result );
}

/* ************************************************************************
 *  void getModeData( char *result )
 *
 *  info: 从网关获得模式数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getModeData(char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = GET_MODE_DATA>>8;
	buff[2] = GET_MODE_DATA & 0xFF;

	changeBytesToStr( buff, 3, result );
}

/* ************************************************************************
 *  void getRoomData( char *result )
 *
 *  info: 从网关获得房间数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getRoomData(char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = GET_ROOM_DATA>>8;
	buff[2] = GET_ROOM_DATA & 0xFF;

	changeBytesToStr( buff, 3, result );
}

/* ************************************************************************
 *  void setRoomData( char *data, int dataLen,char *result )
 *
 *  info: 设置网关获得房间数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setRoomData( char *data, int dataLen,char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = SET_ROOM_DATA>>8;
	buff[2] = SET_ROOM_DATA & 0xFF;
	for (int i = 0; i < dataLen; i++)
		buff[3+i] = data[i];
	if (getChangeStrLen(dataLen + 3) >= 102400)
	{
		return -1;
	}
	changeBytesToStr( buff, dataLen+3, result );
	return 1;
}

/* ************************************************************************
 *  void getDeviceNameData( char *result )
 *
 *  info: 从网关获得设备名数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getDeviceNameData(char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = GET_DEVICE_NAME_DATA>>8;
	buff[2] = GET_DEVICE_NAME_DATA & 0xFF;

	changeBytesToStr( buff, 3, result );
}

/* ************************************************************************
 *  void setDeviceNameData( char *data, int dataLen,char *result )
 *
 *  info: 设置网关设备名数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setDeviceNameData( char *data, int dataLen,char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = SET_DEVICE_NAME_DATA>>8;
	buff[2] = SET_DEVICE_NAME_DATA & 0xFF;
	for (int i = 0; i < dataLen; i++)
		buff[3+i] = data[i];
	if (getChangeStrLen(dataLen + 3) >= 102400)
	{
		return -1;
	}
	changeBytesToStr( buff, dataLen+3, result );
	return 1;
}

/* ************************************************************************
 *  void getExtraDeviceData( char *result )
 *
 *  info: 从网关获得其它设备数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getExtraDeviceData(char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = GET_EXTRA_DATA>>8;
	buff[2] = GET_EXTRA_DATA & 0xFF;

	changeBytesToStr( buff, 3, result );
}


/* ************************************************************************
 *  void setExtraDeviceData( char *data, int dataLen,char *result )
 *
 *  info: 设置网关获得其它设备数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setExtraDeviceData( char *data, int dataLen,char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = SET_EXTRA_DATA>>8;
	buff[2] = SET_EXTRA_DATA & 0xFF;

	if (getChangeStrLen(dataLen + 3) >= 102400)
	{
		return -1;
	}
	changeBytesToStr( buff, 3, result );
	return 1;
}


/* ************************************************************************
 *  void getIrDeviceData( char *result )
 *
 *  info: 从网关获得红外设备数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getIrDeviceData(char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = GET_IR_DATA>>8;
	buff[2] = GET_IR_DATA & 0xFF;

	changeBytesToStr( buff, 3, result );
}


/* ************************************************************************
 *  void setIrDeviceData( char *data, int dataLen,char *result )
 *
 *  info: 设备网关红外设备数据
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return: 0: success -1: fail
 *
 * ************************************************************************/
int setIrDeviceData( char *data, int dataLen,char *result )
{
	unsigned char buff[102400];
	buff[0] = 0xEF;
	buff[1] = SET_IR_DATA>>8;
	buff[2] = SET_IR_DATA & 0xFF;

	if (getChangeStrLen(dataLen + 3) >= 102400)
	{
		return -1;
	}

	changeBytesToStr( buff, 3, result );

	return 1;
}


/* ************************************************************************
 *  void sendModeDataClear( char *result )
 *
 *  info: 联动数据通知 数据包设置
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendModeDataClear( char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = CLEAR_MODE_DATA>>8;
	buff[2] = CLEAR_MODE_DATA & 0xFF;
	changeBytesToStr( buff, 3, result );
}



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
void sendSelMode( char *data, int dataLen, unsigned char value , char *result )
{
	unsigned char buff[400];
	buff[0] = 0xEF;
	buff[1] = SELECT_MODE_ID>>8;
	buff[2] = SELECT_MODE_ID & 0xFF;
	for (int i=0; i<dataLen; i++)
		buff[i+3] = data[i];
	buff[dataLen+3] = value;
	changeBytesToStr( buff, dataLen+4, result );
}

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
void sendDelMode( char *data, int dataLen, unsigned char value , char *result )
{
	unsigned char buff[400];
	buff[0] = 0xEF;
	buff[1] = DEL_MODE_DATA>>8;
	buff[2] = DEL_MODE_DATA & 0xFF;
	for (int i=0; i<dataLen; i++)
		buff[i+3] = data[i];
	buff[dataLen+3] = value;
	changeBytesToStr( buff, dataLen+4, result );
}

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
void sendDelLink( char *data, int dataLen,char *result )
{
	unsigned char buff[51200];
	buff[0] = 0xEF;
	buff[1] = DEL_LINK_DATA>>8;
	buff[2] = DEL_LINK_DATA & 0xFF;
	for (int i = 0; i < dataLen; i++)
		buff[3+i] = data[i];
	changeBytesToStr( buff, dataLen+3, result );
}

/* ************************************************************************
 *  void startAddingMode( unsigned char value , char *result )
 *
 *  info: 设置选择的场景ID
 *  in:
 *  	value: 类型-unsigned char 描述-0 取消 1 设置
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void startAddingMode( unsigned char value , char *result )
{
	unsigned char buff[400];
	buff[0] = 0xEF;
	buff[1] = START_ADDING_MODE>>8;
	buff[2] = START_ADDING_MODE & 0xFF;
	buff[3] = value;
	changeBytesToStr( buff, 4, result );
}

/* ************************************************************************
 *  void getGwVersion( char *result )
 *
 *  info: 获取网关版本号
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getGwVersion( char *result )
{
	unsigned char buff[400];
	buff[0] = 0xEF;
	buff[1] = GET_GW_VERSION>>8;
	buff[2] = GET_GW_VERSION & 0xFF;
	changeBytesToStr( buff, 3, result );
}

/* ************************************************************************
 *  void sendDoFactory( char *result )
 *
 *  info: 清空设备
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendDoFactory( char *result )
{
	unsigned char buff[400];
	buff[0] = 0xEF;
	buff[1] = DO_FACTORY>>8;
	buff[2] = DO_FACTORY & 0xFF;
	changeBytesToStr( buff, 3, result );
}

/* ************************************************************************
 *  void sendAppCtlEventCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char event, unsigned char val, char *result )
 *  for: 中控开关3路事件， 万能遥控器按键控制事件 2个窗帘按键 4个灯光按键
 *  info: 发送APP EVENT
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendAppCtlEventCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char event, unsigned char val, char *result )
{

	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = APP_CTL_EVENT>>8;
	buff[2] = APP_CTL_EVENT & 0xFF;
	buff[3] = nwkAddr & 0xFF;
	buff[4] = nwkAddr >> 8;
	buff[5] = endPoint;
	buff[6] = event;
	buff[7] = val;
	changeBytesToStr( buff, 8, result );
}

/* ************************************************************************
 *  void sendFwOTAUpdate( char *result )
 *
 *  info: 让网关进行OTA升级，APP需要先对当前的网关的固件版本与云端的网关的固件版本进行比对，来确定是否需要发送该命令
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendFwOTAUpdate( char *result )
{
	unsigned char buff[400];
	buff[0] = 0xEF;
	buff[1] = FW_OTA_UPDATA>>8;
	buff[2] = FW_OTA_UPDATA & 0xFF;
	changeBytesToStr( buff, 3, result );
}

/* ************************************************************************
 *  void getDevicePowerCmd( unsigned short int nwkAddr, unsigned char endPoint, char *result )
 *
 *  info: 获取智能插作已消耗电量和当前功率
 *  	  电量统计的数据格式为0x11 0x22  0x33 0x44 0x55 0x66 0x77 0x88。
 *        0x11 0x22 ：表示当前功率，高位在前低位在后，单位W。
 *        0x33 0x44 0x55 0x66 0x77 0x88：表示当前使用的电量，高位在前，低位在后。
 *        0x33 0x44 0x55 0x66 0x77：表示整数部分的值。
 *        0x88：表示小书部分的值。单位kw.h.
 *        发送 目的 clusterID 0x0016
 *  in:
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void getDevicePowerCmd( unsigned short int nwkAddr, unsigned char endPoint, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 13;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;		// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 3;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x05;	// cmd id

	buff[17] = computeCheckSum( &buff[1], 16 );
	changeBytesToStr( buff, 18, result );
}

void setLockTime( unsigned char year, unsigned char month, unsigned char day, unsigned char hour, unsigned char minute, unsigned char second, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = SET_LOCK_TIME>>8;
	buff[2] = SET_LOCK_TIME & 0xFF;
	buff[3] = year;
	buff[4] = month;
	buff[5] = day;
	buff[6] = hour;
	buff[7] = minute;
	buff[8] = second;
	changeBytesToStr( buff, 9, result );
}

void sendRemoteCmd( unsigned short int nwkAddr, unsigned char endPoint, int cmd, unsigned char device, int group, unsigned char keyval, unsigned char *param, int paramLen, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = SEND_REMOTE_CMD>>8;
	buff[2] = SEND_REMOTE_CMD & 0xFF;
	unsigned char *p = &buff[3];
	*(int *)p = htonl( cmd );
	p += sizeof( int );
	*p = (unsigned char)device;
	p++;
	*(int *)p = htonl( group );
	p += sizeof( int );
	*p = (unsigned char)keyval;
	p++;
	*(int *)p = htonl( paramLen );
	p += sizeof( int );
	for( int i = 0; i < paramLen; i++ )
		*p++ = param[i];
	*p++ = nwkAddr & 0xFF;
	*p++ = nwkAddr >> 8;
	*p++ = endPoint;

	changeBytesToStr( buff, p - buff, result );
}

void sendRemoteLearnKey( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char *keyValue, char *result )
{
	unsigned char buff[250];
	buff[0] = 0xEF;
	buff[1] = SEND_REMOTE_LEARN_KEY>>8;
	buff[2] = SEND_REMOTE_LEARN_KEY & 0xFF;
	buff[3] = type;
	unsigned char *p = &buff[4];
	for( int i = 0; i < 208; i++ )
		*p++ = keyValue[i];
		//*p++ = keyBuff[i];
	*p++ = nwkAddr & 0xFF;
	*p++ = nwkAddr >> 8;
	*p++ = endPoint;

	changeBytesToStr( buff, p - buff, result );
}

void remoteLearnEnd(  unsigned short int nwkAddr, unsigned char endPoint, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = REMOTE_LEARN_END>>8;
	buff[2] = REMOTE_LEARN_END & 0xFF;
	buff[3] = nwkAddr & 0xFF;
	buff[4] = nwkAddr >> 8;
	buff[5] = endPoint;
	changeBytesToStr( buff, 6, result );
}

void setDoor( unsigned long IEEEAddrDoor, char *result )
{
	unsigned char buff[100];
	int i;
	buff[0] = 0xEF;
	buff[1] = SET_DOOR >> 8;
	buff[2] = SET_DOOR & 0xFF;
	unsigned long doorIEEEAddr = IEEEAddrDoor;
	for( i = 0; i < 8; i++ )
	{
		buff[3 + i] = doorIEEEAddr % 0x100;
		doorIEEEAddr = doorIEEEAddr / 0x100;
	}
	changeBytesToStr( buff, 11, result );
}

/* ************************************************************************
 *  void sendDimmerOnOffCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char OnOff, char *result )
 *
 *  info: 发送dimmer on/off 状态
 *  in:
 *	type : 0x00 get 0x01 set
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendDimmerOnOffCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char OnOff, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 13;			// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x08;			// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;		// option
	buff[12] = 0x1E;		// radius
	buff[13] = 3;			// msg len
	buff[14] = 0x01;		// frameControl
	buff[15] =  transId++;
	if (OnOff == 0x00) 		// 关
		buff[16] = 0x06;	// cmd id
	else
		buff[16] = 0x05;	// cmd id

	buff[17] = computeCheckSum( &buff[1], 16 );
	changeBytesToStr( buff, 18, result );
}

/* ************************************************************************
 *  void sendDimmerColorCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char mode, unsigned char col_r, unsigned char col_g, unsigned char col_b, char *result )
 *
 *  info: get/set dimmer 颜色/模式 状态
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
void sendDimmerColorCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char mode, unsigned char col_w, unsigned char col_r, unsigned char col_g, unsigned char col_b, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x00;			// clusterId
	buff[9] = 0x03;
	buff[10] = transId;
	buff[11] = 0x10;		// option
	buff[12] = 0x1E;		// radius
	buff[14] = 0x01;		// frameControl
	buff[15] = transId++;
	buff[16] = type;		// cmd id;
	if (type == 0x00)
	{
		buff[1]  = 13;		// length
		buff[13] = 3;		// msg len
		buff[17] = computeCheckSum( &buff[1], 16 );
		changeBytesToStr( buff, 18, result );
	}
	else if (type == 0x01)
	{
		buff[1]  = 19;		// length
		buff[13] = 9;		// msg len
		buff[17] = 0x00;	// onoff hulue
		buff[18] = mode;	// mode
		buff[19] = col_w;	// col_w
		buff[20] = col_r; 	// col_r
		buff[21] = col_g;	// col_g
		buff[22] = col_b;	// col_b

		buff[23] = computeCheckSum( &buff[1], 22 );
		changeBytesToStr( buff, 24, result );
	}
}

/* ************************************************************************
 *  void sendDimmerSceneCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char sel, unsigned char col_w, unsigned char col_r, unsigned char col_g, unsigned char col_b, char *name, char *result );
 *
 *  info: get/set/select dimmer 预设值 状态
 *  in:
 *  	type:   类型 unsigned char 描述:0x00 get, 0x01 set, 0x02 select
 *  	sel: 	类型 unsigned char 描述:0x00~0x08 总共有9个
 *  	col_w:  类型 unsigned char 描述:0~0xff
 *  	col_r:  类型 unsigned char 描述:0~0xff
 *  	col_g:	类型 unsigned char 描述:0~0xff
 *  	col_b:	类型 unsigned char 描述:0~0xff
 *      name:	类型 char 	  描述:名称
 *  	result: 类型-char *  描述-用于保存返回的结果
 *  return:
 *
 * ************************************************************************/
void sendDimmerSceneCmd( unsigned short int nwkAddr, unsigned char endPoint, unsigned char type, unsigned char sel, unsigned char col_w, unsigned char col_r, unsigned char col_g, unsigned char col_b, char *name, char *result )
{
	// this is the define of set
	// | 0xFE | DATALEN (1字节 长度从第5字节开始)| CMD TYPE（1字节）|CMD ID （1字节）|NWK（字节）|ENDPOINT（1字节）|clusterID(2字节 低位在前)|transID(1字节)|OPT(1字节)|radius(1字节)|userDateLEN(1字节)|framecontrol(1字节)|transID(1字节)
	// | cmdID(1字节)| status (1字节)|groupID(2字节)|senceID(1字节)|tansTIME(2字节)|scene name len(1字节 max 15)|scene name(11字节)|col_w(1字节)|col_r(1字节)|col_g(1字节)|col_b(1字节)|CRC
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x05;			// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;		// option
	buff[12] = 0x1E;		// radius
	buff[14] = 0x01;		// frameControl
	buff[15] = transId++;
	//buff[16] = type;		// cmd id;
	buff[17] = 0x00;		// status
	buff[18] = 0x00;		// groupID low
	buff[19] = 0x00;		// groupID high
	if (type == 0x00)
	{
		buff[16] = 0x07;	// cmd id;
		buff[1]  = 16;		// length
		buff[13] = 6;		// msg len
		buff[20] = computeCheckSum( &buff[1], 19 );
		changeBytesToStr( buff, 21, result );
	}
	else if (type == 0x01)
	{
		buff[16] = 0x00;	// cmd id;
		buff[1]  = 35;		// length
		buff[13] = 25;		// msg len
		buff[20] = sel;
		buff[21] = 0x00;	// transTIME low
		buff[22] = 0x00;	// transTIME high
		buff[23] = 11;		// scene name len
		memset(&buff[24], '\0', 11);
		memcpy(&buff[24], name, strlen(name));
		buff[35] = col_w;
		buff[36] = col_r;
		buff[37] = col_g;
		buff[38] = col_b;
		buff[39] = computeCheckSum( &buff[1], 38 );
		changeBytesToStr( buff, 40, result );
	}
	else if (type == 0x02)
	{
		buff[16] = 0x01;	// cmd id;
		buff[1]  = 17;
		buff[13] = 7;
		buff[20] = sel;
		buff[21] = computeCheckSum( &buff[1], 20 );
		changeBytesToStr( buff, 22, result );
	}
}

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
void sendBgmusicCmd( char *iEEEAddr, unsigned char cmd, char extLen, char *extVal, char *result )
{
	unsigned char buff[400];
	buff[0] = 0xEF;
	buff[1] = BGM_CTL_CMD>>8;
	buff[2] = BGM_CTL_CMD & 0xFF;
	memcpy(&buff[3], iEEEAddr, 8);
	buff[11] = cmd;
	buff[12] = extLen;
	if (extLen > 0)
		memcpy(&buff[13], extVal, extLen);
	changeBytesToStr( buff, 3+8+1+1+extLen, result );
}

/*
 * 带电量检测灯控开关 SET：
 * #define ZCL_HA_DEVICEID_POWER_LIGHT			0x0510			// 带电量检测智能开关 被动设备
 *
 *
 * */
void sendPLightSetCmd( unsigned short int nwkAddr, unsigned char endPoint, char key,  char onoff, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 15;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;		// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 5;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x01;	// cmdid set;
	buff[17] = key;		// key;
	buff[18] = onoff;	// onoff;
	buff[19] = computeCheckSum( &buff[1], 18 );
	changeBytesToStr( buff, 20, result );
}

/*
 * 带电量检测灯控开关 SET：
 * #define ZCL_HA_DEVICEID_POWER_LIGHT			0x0510			// 带电量检测智能开关 被动设备
 *
 *
 * */
void sendPLightGetCmd( unsigned short int nwkAddr, unsigned char endPoint, char *result )
{
	unsigned char buff[100];
	buff[0] = 0xFE;
	buff[1] = 13;		// length
	buff[2] = AF_DATA_REQUEST >> 8;
	buff[3] = AF_DATA_REQUEST & 0xFF;
	buff[4] = nwkAddr & 0xFF;
	buff[5] = nwkAddr >> 8;
	buff[6] = endPoint;
	buff[7] = senderEndPoint;
	buff[8] = 0x06;		// clusterId
	buff[9] = 0x00;
	buff[10] = transId;
	buff[11] = 0x10;	// option
	buff[12] = 0x1E;	// radius
	buff[13] = 3;		// msg len
	buff[14] = 0x01;	// frameControl
	buff[15] =  transId++;
	buff[16] = 0x00;	// cmdid get;
	buff[17] = computeCheckSum( &buff[1], 16 );
	changeBytesToStr( buff, 18, result );
}

/*
 * GWPING
 *
 * */
void sendGwPingCmd( char *result )
{
	unsigned char buff[100];
	buff[0] = 0xEF;
	buff[1] = GW_PING >> 8;
	buff[2] = GW_PING & 0xFF;
	changeBytesToStr( buff, 3, result );
}




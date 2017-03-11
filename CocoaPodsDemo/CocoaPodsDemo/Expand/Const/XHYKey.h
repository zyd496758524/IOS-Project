//
//  XHYKey.h
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/24.
//  Copyright © 2016年  XHY. All rights reserved.
//

#ifndef XHYKey_h
#define XHYKey_h

//刷新广播

//楼层信息改变 （重新刷新设备列表界面）
#define XHYDeviceFloorInfoChanged @"XHYDEVICEFLOORINFOCHANGED"

//自定义名信息改变
#define XHYDeviceNameChanged @"XHYDEVICENAMECHANGED"

//设备工作状态改变
#define XHYDeviceWorkStatusChanged @"XHYDEVICEWORKSTATUSCHANGED"

//设备在线状态改变
#define XHYDeviceOnlineStatusChanged @"XHYDEVICEONLINESTATUSCHANGED"

//设备删除消息
#define XHYDeviceDelete @"XHYDEVICEDELETE"

//窗帘进度改变
#define XHYCurtainProgressChanged @"XHYCURTAINPROGRESSCHANGED"

//接收到需要显示的消息（日志消息 或 报警消息）
#define XHYReceiveNeedDisplayMessage @"XHYRECEIVENEEDDISPLAYMESSAGE"


#endif /* XHYKey_h */

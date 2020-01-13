/*
 CSCBluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth 作者：刘彦玮
 https://github.com/coolnameismy/CSCBluetooth
 
@brief  预定义一些库的执行行为和配置
 
 */

// Created by 刘彦玮 on 6/4/19.
//  Copyright © 2016年 liuyanwei. All rights reserved.
//  

#import <Foundation/Foundation.h>


# pragma mark - CSC 行为定义

//CSC if show log 是否打印日志，默认1：打印 ，0：不打印
#define KCSC_IS_SHOW_LOG 1

//CBcentralManager等待设备打开次数
# define KCSC_CENTRAL_MANAGER_INIT_WAIT_TIMES 5

//CBcentralManager等待设备打开间隔时间
# define KCSC_CENTRAL_MANAGER_INIT_WAIT_SECOND 2.0

//CSCRhythm默认心跳时间间隔
#define KCSCRHYTHM_BEATS_DEFAULT_INTERVAL 3;

//CSC默认链式方法channel名称
#define KCSC_DETAULT_CHANNEL @"CSCDefault"

# pragma mark - CSC通知

//蓝牙系统通知
//centralManager status did change notification
#define CSCNotificationAtCentralManagerDidUpdateState @"CSCNotificationAtCentralManagerDidUpdateState"
//did discover peripheral notification
#define CSCNotificationAtDidDiscoverPeripheral @"CSCNotificationAtDidDiscoverPeripheral"
//did connection peripheral notification
#define CSCNotificationAtDidConnectPeripheral @"CSCNotificationAtDidConnectPeripheral"
//did filed connect peripheral notification
#define CSCNotificationAtDidFailToConnectPeripheral @"CSCNotificationAtDidFailToConnectPeripheral"
//did disconnect peripheral notification
#define CSCNotificationAtDidDisconnectPeripheral @"CSCNotificationAtDidDisconnectPeripheral"
//did discover service notification
#define CSCNotificationAtDidDiscoverServices @"CSCNotificationAtDidDiscoverServices"
//did discover characteristics notification
#define CSCNotificationAtDidDiscoverCharacteristicsForService @"CSCNotificationAtDidDiscoverCharacteristicsForService"
//did read or notify characteristic when received value  notification
#define CSCNotificationAtDidUpdateValueForCharacteristic @"CSCNotificationAtDidUpdateValueForCharacteristic"
//did write characteristic and response value notification
#define CSCNotificationAtDidWriteValueForCharacteristic @"CSCNotificationAtDidWriteValueForCharacteristic"
//did change characteristis notify status notification
#define CSCNotificationAtDidUpdateNotificationStateForCharacteristic @"CSCNotificationAtDidUpdateNotificationStateForCharacteristic"
//did read rssi and receiced value notification
#define CSCNotificationAtDidReadRSSI @"CSCNotificationAtDidReadRSSI"

//蓝牙扩展通知
// did centralManager enable notification
#define CSCNotificationAtCentralManagerEnable @"CSCNotificationAtCentralManagerEnable"



# pragma mark - CSC 定义的方法

//CSC log
#define CSCLog(fmt, ...) if(KCSC_IS_SHOW_LOG) { NSLog(fmt,##__VA_ARGS__); }





@interface CSCDefine : NSObject

@end

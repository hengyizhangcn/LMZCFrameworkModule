/*
 CSCBluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth 作者：刘彦玮
 https://github.com/coolnameismy/CSCBluetooth
 
 @brief  蓝牙外设模式实现类
 
 */


//  Created by 刘彦玮 on 15/12/12.
//  Copyright © 2015年 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CSCToy.h"
#import "CSCSpeaker.h"


@interface CSCPeripheralManager : NSObject<CBPeripheralManagerDelegate> {

@public
    //回叫方法
    CSCSpeaker *cscSpeaker;
}

/**
 添加服务
 */
- (CSCPeripheralManager *(^)(NSArray *array))addServices;

/**
启动广播
 */
- (CSCPeripheralManager *(^)())startAdvertising;

//外设管理器
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, copy) NSString *localName;
@property (nonatomic, strong) NSMutableArray *services;

@end


/**
 *  构造Characteristic，并加入service
 *  service:CBService
 
 *  param`ter for properties ：option 'r' | 'w' | 'n' or combination
 *	r                       CBCharacteristicPropertyRead
 *	w                       CBCharacteristicPropertyWrite
 *	n                       CBCharacteristicPropertyNotify
 *  default value is rw     Read-Write

 *  paramter for descriptor：be uesd descriptor for characteristic
 */

void makeCSCCharacteristicToService(CBMutableService *service,NSString *UUID,NSString *properties,NSString *descriptor);

/**
 *  构造一个包含初始值的Characteristic，并加入service,包含了初值的characteristic必须设置permissions和properties都为只读
 *  make characteristic then add to service, a static characteristic mean it has a initial value .according apple rule, it must set properties and permissions to CBCharacteristicPropertyRead and CBAttributePermissionsReadable
*/
void makeCSCStaticCharacteristicToService(CBMutableService *service,NSString *UUID,NSString *descriptor,NSData *data);
/**
 生成CBService
 */
CBMutableService* makeCSCCBService(NSString *UUID);

/**
 生成UUID
 */
NSString* genCSCUUID();

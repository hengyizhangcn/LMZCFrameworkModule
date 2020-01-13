//
//  SmartLockBluetoothManager.h
//  SmartLockSDK
//
//  Created by ccks on 2019/7/30.
//  Copyright © 2019 SmartLockSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SLKeyInfoListModel.h"
#import <CSCFrameworkV2/CSCFrameworkV2.h>
#import <ICCKSV2/ICCKSV2.h>

NS_ASSUME_NONNULL_BEGIN

@interface SmartLockBluetoothManager : NSObject

+ (instancetype)shareManager;


@property (nonatomic, assign) BOOL isReadRandomNum;

@property (nonatomic, assign) BOOL isWriteRandomNum;

@property (nonatomic, assign) BOOL isOpenLock;

@property (nonatomic, strong) SLKeyInfoListModel *model;

@property (nonatomic, strong) CSCApplyCardResult *CardResult;

@property (nonatomic, strong) NSString *mac;

@property (nonatomic,strong)CBCharacteristic *characteristic;

@property (nonatomic,strong)CBPeripheral *currPeripheral;

@property (nonatomic, strong) CSCBluetooth *babyBluetooth;

 @property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, assign) CBManagerState state;

-(void)starScan;
@end

NS_ASSUME_NONNULL_END

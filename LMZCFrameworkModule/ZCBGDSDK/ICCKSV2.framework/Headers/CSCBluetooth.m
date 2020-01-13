/*
 CSCBluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth 作者：刘彦玮
 https://github.com/coolnameismy/CSCBluetooth
 */

//  Created by 刘彦玮 on 15/3/31.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.


#import "CSCBluetooth.h"



@implementation CSCBluetooth{
    CSCCentralManager *cscCentralManager;
    CSCPeripheralManager *cscPeripheralManager;
    CSCSpeaker *cscSpeaker;
    int CENTRAL_MANAGER_INIT_WAIT_TIMES;
    NSTimer *timerForStop;
}
//单例模式
+ (instancetype)shareCSCBluetooth {
    static CSCBluetooth *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[CSCBluetooth alloc]init];
    });
   return share;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //初始化对象
        cscCentralManager = [[CSCCentralManager alloc]init];
        cscSpeaker = [[CSCSpeaker alloc]init];
        cscCentralManager->cscSpeaker = cscSpeaker;
        
        cscPeripheralManager = [[CSCPeripheralManager alloc]init];
        cscPeripheralManager->cscSpeaker = cscSpeaker;
    }
    return self;
    
}

#pragma mark - CSCbluetooth的委托
/*
 默认频道的委托
 */
//设备状态改变的委托
- (void)setBlockOnCentralManagerDidUpdateState:(void (^)(CBCentralManager *central))block {
    [[cscSpeaker callback]setBlockOnCentralManagerDidUpdateState:block];
}
//找到Peripherals的委托
- (void)setBlockOnDiscoverToPeripherals:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block{
    [[cscSpeaker callback]setBlockOnDiscoverPeripherals:block];
}
//连接Peripherals成功的委托
- (void)setBlockOnConnected:(void (^)(CBCentralManager *central,CBPeripheral *peripheral))block {
    [[cscSpeaker callback]setBlockOnConnectedPeripheral:block];
}
//连接Peripherals失败的委托
- (void)setBlockOnFailToConnect:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[cscSpeaker callback]setBlockOnFailToConnect:block];
}
//断开Peripherals的连接
- (void)setBlockOnDisconnect:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[cscSpeaker callback]setBlockOnDisconnect:block];
}
//设置查找服务回叫
- (void)setBlockOnDiscoverServices:(void (^)(CBPeripheral *peripheral,NSError *error))block {
    [[cscSpeaker callback]setBlockOnDiscoverServices:block];
}
//设置查找到Characteristics的block
- (void)setBlockOnDiscoverCharacteristics:(void (^)(CBPeripheral *peripheral,CBService *service,NSError *error))block {
    [[cscSpeaker callback]setBlockOnDiscoverCharacteristics:block];
}
//设置获取到最新Characteristics值的block
- (void)setBlockOnReadValueForCharacteristic:(void (^)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error))block {
    [[cscSpeaker callback]setBlockOnReadValueForCharacteristic:block];
}
//设置查找到Characteristics描述的block
- (void)setBlockOnDiscoverDescriptorsForCharacteristic:(void (^)(CBPeripheral *peripheral,CBCharacteristic *service,NSError *error))block {
    [[cscSpeaker callback]setBlockOnDiscoverDescriptorsForCharacteristic:block];
}
//设置读取到Characteristics描述的值的block
- (void)setBlockOnReadValueForDescriptors:(void (^)(CBPeripheral *peripheral,CBDescriptor *descriptor,NSError *error))block {
    [[cscSpeaker callback]setBlockOnReadValueForDescriptors:block];
}

//写Characteristic成功后的block
- (void)setBlockOnDidWriteValueForCharacteristic:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[cscSpeaker callback]setBlockOnDidWriteValueForCharacteristic:block];
}
//写descriptor成功后的block
- (void)setBlockOnDidWriteValueForDescriptor:(void (^)(CBDescriptor *descriptor,NSError *error))block {
    [[cscSpeaker callback]setBlockOnDidWriteValueForDescriptor:block];
}
//characteristic订阅状态改变的block
- (void)setBlockOnDidUpdateNotificationStateForCharacteristic:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[cscSpeaker callback]setBlockOnDidUpdateNotificationStateForCharacteristic:block];
}
//读取RSSI的委托
- (void)setBlockOnDidReadRSSI:(void (^)(NSNumber *RSSI,NSError *error))block {
    [[cscSpeaker callback]setBlockOnDidReadRSSI:block];
}
//discoverIncludedServices的回调，暂时在CSCbluetooth中无作用
- (void)setBlockOnDidDiscoverIncludedServicesForService:(void (^)(CBService *service,NSError *error))block {
    [[cscSpeaker callback]setBlockOnDidDiscoverIncludedServicesForService:block];
}
//外设更新名字后的block
- (void)setBlockOnDidUpdateName:(void (^)(CBPeripheral *peripheral))block {
    [[cscSpeaker callback]setBlockOnDidUpdateName:block];
}
//外设更新服务后的block
- (void)setBlockOnDidModifyServices:(void (^)(CBPeripheral *peripheral,NSArray *invalidatedServices))block {
    [[cscSpeaker callback]setBlockOnDidModifyServices:block];
}

//设置蓝牙使用的参数参数
- (void)setCSCOptionsWithScanForPeripheralsWithOptions:(NSDictionary *) scanForPeripheralsWithOptions
                          connectPeripheralWithOptions:(NSDictionary *) connectPeripheralWithOptions
                        scanForPeripheralsWithServices:(NSArray *)scanForPeripheralsWithServices
                                  discoverWithServices:(NSArray *)discoverWithServices
                           discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics {
    CSCOptions *option = [[CSCOptions alloc]initWithscanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectPeripheralWithOptions scanForPeripheralsWithServices:scanForPeripheralsWithServices discoverWithServices:discoverWithServices discoverWithCharacteristics:discoverWithCharacteristics];
    [[cscSpeaker callback]setCSCOptions:option];
}

/*
 channel的委托
 */
//设备状态改变的委托
- (void)setBlockOnCentralManagerDidUpdateStateAtChannel:(NSString *)channel
                                                 block:(void (^)(CBCentralManager *central))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnCentralManagerDidUpdateState:block];
}
//找到Peripherals的委托
- (void)setBlockOnDiscoverToPeripheralsAtChannel:(NSString *)channel
                                          block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverPeripherals:block];
}

//连接Peripherals成功的委托
- (void)setBlockOnConnectedAtChannel:(NSString *)channel
                              block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnConnectedPeripheral:block];
}

//连接Peripherals失败的委托
- (void)setBlockOnFailToConnectAtChannel:(NSString *)channel
                                  block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnFailToConnect:block];
}

//断开Peripherals的连接
- (void)setBlockOnDisconnectAtChannel:(NSString *)channel
                               block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDisconnect:block];
}

//设置查找服务回叫
- (void)setBlockOnDiscoverServicesAtChannel:(NSString *)channel
                                     block:(void (^)(CBPeripheral *peripheral,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverServices:block];
}

//设置查找到Characteristics的block
- (void)setBlockOnDiscoverCharacteristicsAtChannel:(NSString *)channel
                                            block:(void (^)(CBPeripheral *peripheral,CBService *service,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverCharacteristics:block];
}
//设置获取到最新Characteristics值的block
- (void)setBlockOnReadValueForCharacteristicAtChannel:(NSString *)channel
                                               block:(void (^)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnReadValueForCharacteristic:block];
}
//设置查找到Characteristics描述的block
- (void)setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:(NSString *)channel
                                                         block:(void (^)(CBPeripheral *peripheral,CBCharacteristic *service,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverDescriptorsForCharacteristic:block];
}
//设置读取到Characteristics描述的值的block
- (void)setBlockOnReadValueForDescriptorsAtChannel:(NSString *)channel
                                            block:(void (^)(CBPeripheral *peripheral,CBDescriptor *descriptor,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnReadValueForDescriptors:block];
}

//写Characteristic成功后的block
- (void)setBlockOnDidWriteValueForCharacteristicAtChannel:(NSString *)channel
                                                        block:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidWriteValueForCharacteristic:block];
}
//写descriptor成功后的block
- (void)setBlockOnDidWriteValueForDescriptorAtChannel:(NSString *)channel
                                      block:(void (^)(CBDescriptor *descriptor,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidWriteValueForDescriptor:block];
}
//characteristic订阅状态改变的block
- (void)setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:(NSString *)channel
                                                                     block:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidUpdateNotificationStateForCharacteristic:block];
}
//读取RSSI的委托
- (void)setBlockOnDidReadRSSIAtChannel:(NSString *)channel
                                block:(void (^)(NSNumber *RSSI,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidReadRSSI:block];
}
//discoverIncludedServices的回调，暂时在CSCbluetooth中无作用
- (void)setBlockOnDidDiscoverIncludedServicesForServiceAtChannel:(NSString *)channel
                                                          block:(void (^)(CBService *service,NSError *error))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidDiscoverIncludedServicesForService:block];
}
//外设更新名字后的block
- (void)setBlockOnDidUpdateNameAtChannel:(NSString *)channel
                                  block:(void (^)(CBPeripheral *peripheral))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidUpdateName:block];
}
//外设更新服务后的block
- (void)setBlockOnDidModifyServicesAtChannel:(NSString *)channel
                                      block:(void (^)(CBPeripheral *peripheral,NSArray *invalidatedServices))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidModifyServices:block];
}


//设置蓝牙运行时的参数
- (void)setCSCOptionsAtChannel:(NSString *)channel
 scanForPeripheralsWithOptions:(NSDictionary *) scanForPeripheralsWithOptions
  connectPeripheralWithOptions:(NSDictionary *) connectPeripheralWithOptions
    scanForPeripheralsWithServices:(NSArray *)scanForPeripheralsWithServices
          discoverWithServices:(NSArray *)discoverWithServices
   discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics {
    
    CSCOptions *option = [[CSCOptions alloc]initWithscanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectPeripheralWithOptions scanForPeripheralsWithServices:scanForPeripheralsWithServices discoverWithServices:discoverWithServices discoverWithCharacteristics:discoverWithCharacteristics];
     [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setCSCOptions:option];
}

#pragma mark - CSCbluetooth filter委托
//设置查找Peripherals的规则
- (void)setFilterOnDiscoverPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[cscSpeaker callback]setFilterOnDiscoverPeripherals:filter];
}
//设置连接Peripherals的规则
- (void)setFilterOnConnectToPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[cscSpeaker callback]setFilterOnconnectToPeripherals:filter];
}
//设置查找Peripherals的规则
- (void)setFilterOnDiscoverPeripheralsAtChannel:(NSString *)channel
                                      filter:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setFilterOnDiscoverPeripherals:filter];
}
//设置连接Peripherals的规则
- (void)setFilterOnConnectToPeripheralsAtChannel:(NSString *)channel
                                     filter:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setFilterOnconnectToPeripherals:filter];
}

#pragma mark - CSCbluetooth Special
//CSCBluettooth cancelScan方法调用后的回调
- (void)setBlockOnCancelScanBlock:(void(^)(CBCentralManager *centralManager))block {
    [[cscSpeaker callback]setBlockOnCancelScan:block];
}
//CSCBluettooth cancelAllPeripheralsConnectionBlock 方法调用后的回调
- (void)setBlockOnCancelAllPeripheralsConnectionBlock:(void(^)(CBCentralManager *centralManager))block{
    [[cscSpeaker callback]setBlockOnCancelAllPeripheralsConnection:block];
}
//CSCBluettooth cancelScan方法调用后的回调
- (void)setBlockOnCancelScanBlockAtChannel:(NSString *)channel
                                    block:(void(^)(CBCentralManager *centralManager))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnCancelScan:block];
}
//CSCBluettooth cancelAllPeripheralsConnectionBlock 方法调用后的回调
- (void)setBlockOnCancelAllPeripheralsConnectionBlockAtChannel:(NSString *)channel
                                                        block:(void(^)(CBCentralManager *centralManager))block {
    [[cscSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnCancelAllPeripheralsConnection:block];
}

#pragma mark - 链式函数
//查找Peripherals
- (CSCBluetooth *(^)()) scanForPeripherals {
    return ^CSCBluetooth *() {
        [cscCentralManager->pocket setObject:@"YES" forKey:@"needScanForPeripherals"];
        return self;
    };
}

//连接Peripherals
- (CSCBluetooth *(^)()) connectToPeripherals {
    return ^CSCBluetooth *() {
        [cscCentralManager->pocket setObject:@"YES" forKey:@"needConnectPeripheral"];
        return self;
    };
}

//发现Services
- (CSCBluetooth *(^)()) discoverServices {
    return ^CSCBluetooth *() {
        [cscCentralManager->pocket setObject:@"YES" forKey:@"needDiscoverServices"];
        return self;
    };
}

//获取Characteristics
- (CSCBluetooth *(^)()) discoverCharacteristics {
    return ^CSCBluetooth *() {
        [cscCentralManager->pocket setObject:@"YES" forKey:@"needDiscoverCharacteristics"];
        return self;
    };
}

//更新Characteristics的值
- (CSCBluetooth *(^)()) readValueForCharacteristic {
    return ^CSCBluetooth *() {
        [cscCentralManager->pocket setObject:@"YES" forKey:@"needReadValueForCharacteristic"];
        return self;
    };
}

//设置查找到Descriptors名称的block
- (CSCBluetooth *(^)()) discoverDescriptorsForCharacteristic {
    return ^CSCBluetooth *() {
        [cscCentralManager->pocket setObject:@"YES" forKey:@"needDiscoverDescriptorsForCharacteristic"];
        return self;
    };
}

//设置读取到Descriptors值的block
- (CSCBluetooth *(^)()) readValueForDescriptors {
    return ^CSCBluetooth *() {
        [cscCentralManager->pocket setObject:@"YES" forKey:@"needReadValueForDescriptors"];
        return self;
    };
}

//开始并执行
- (CSCBluetooth *(^)()) begin {
    return ^CSCBluetooth *() {
        //取消未执行的stop定时任务
        [timerForStop invalidate];
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self resetSeriseParmeter];
            //处理链式函数缓存的数据
            if ([[cscCentralManager->pocket valueForKey:@"needScanForPeripherals"] isEqualToString:@"YES"]) {
                cscCentralManager->needScanForPeripherals = YES;
            }
            if ([[cscCentralManager->pocket valueForKey:@"needConnectPeripheral"] isEqualToString:@"YES"]) {
                cscCentralManager->needConnectPeripheral = YES;
            }
            if ([[cscCentralManager->pocket valueForKey:@"needDiscoverServices"] isEqualToString:@"YES"]) {
                cscCentralManager->needDiscoverServices = YES;
            }
            if ([[cscCentralManager->pocket valueForKey:@"needDiscoverCharacteristics"] isEqualToString:@"YES"]) {
                cscCentralManager->needDiscoverCharacteristics = YES;
            }
            if ([[cscCentralManager->pocket valueForKey:@"needReadValueForCharacteristic"] isEqualToString:@"YES"]) {
                cscCentralManager->needReadValueForCharacteristic = YES;
            }
            if ([[cscCentralManager->pocket valueForKey:@"needDiscoverDescriptorsForCharacteristic"] isEqualToString:@"YES"]) {
                cscCentralManager->needDiscoverDescriptorsForCharacteristic = YES;
            }
            if ([[cscCentralManager->pocket valueForKey:@"needReadValueForDescriptors"] isEqualToString:@"YES"]) {
                cscCentralManager->needReadValueForDescriptors = YES;
            }
            //调整委托方法的channel，如果没设置默认为缺省频道
            NSString *channel = [cscCentralManager->pocket valueForKey:@"channel"];
            [cscSpeaker switchChannel:channel];
            //缓存的peripheral
            CBPeripheral *cachedPeripheral = [cscCentralManager->pocket valueForKey:NSStringFromClass([CBPeripheral class])];
            //校验series合法性
            [self validateProcess];
            //清空pocjet
            cscCentralManager->pocket = [[NSMutableDictionary alloc]init];
            //开始扫描或连接设备
            [self start:cachedPeripheral];
        });
        return self;
    };
}


//私有方法，扫描或连接设备
- (void)start:(CBPeripheral *)cachedPeripheral {
    if (cscCentralManager->centralManager.state == CBCentralManagerStatePoweredOn) {
        CENTRAL_MANAGER_INIT_WAIT_TIMES = 0;
        //扫描后连接
        if (cscCentralManager->needScanForPeripherals) {
            //开始扫描peripherals
            [cscCentralManager scanPeripherals];
        }
        //直接连接
        else {
            if (cachedPeripheral) {
                [cscCentralManager connectToPeripheral:cachedPeripheral];
            }
        }
        return;
    }
    //尝试重新等待CBCentralManager打开
    CENTRAL_MANAGER_INIT_WAIT_TIMES ++;
    if (CENTRAL_MANAGER_INIT_WAIT_TIMES >= KCSC_CENTRAL_MANAGER_INIT_WAIT_TIMES ) {
        CSCLog(@">>> 第%d次等待CBCentralManager 打开任然失败，请检查你蓝牙使用权限或检查设备问题。",CENTRAL_MANAGER_INIT_WAIT_TIMES);
        return;
        //[NSException raise:@"CBCentralManager打开异常" format:@"尝试等待打开CBCentralManager5次，但任未能打开"];
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, KCSC_CENTRAL_MANAGER_INIT_WAIT_SECOND * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self start:cachedPeripheral];
    });
    CSCLog(@">>> 第%d次等待CBCentralManager打开",CENTRAL_MANAGER_INIT_WAIT_TIMES);
}

//sec秒后停止
- (CSCBluetooth *(^)(int sec)) stop {
    
    return ^CSCBluetooth *(int sec) {
        CSCLog(@">>> stop in %d sec",sec);
        
        //听见定时器执行CSCStop
        timerForStop = [NSTimer timerWithTimeInterval:sec target:self selector:@selector(CSCStop) userInfo:nil repeats:NO];
        [timerForStop setFireDate: [[NSDate date]dateByAddingTimeInterval:sec]];
        [[NSRunLoop currentRunLoop] addTimer:timerForStop forMode:NSRunLoopCommonModes];
        
        return self;
    };
}

//私有方法，停止扫描和断开连接，清空pocket
- (void)CSCStop {
    CSCLog(@">>>did stop");
    [timerForStop invalidate];
    [self resetSeriseParmeter];
    cscCentralManager->pocket = [[NSMutableDictionary alloc]init];
    //停止扫描，断开连接
    [cscCentralManager cancelScan];
    [cscCentralManager cancelAllPeripheralsConnection];
}

//重置串行方法参数
- (void)resetSeriseParmeter {
    cscCentralManager->needScanForPeripherals = NO;
    cscCentralManager->needConnectPeripheral = NO;
    cscCentralManager->needDiscoverServices = NO;
    cscCentralManager->needDiscoverCharacteristics = NO;
    cscCentralManager->needReadValueForCharacteristic = NO;
    cscCentralManager->needDiscoverDescriptorsForCharacteristic = NO;
    cscCentralManager->needReadValueForDescriptors = NO;
}

//持有对象
- (CSCBluetooth *(^)(id obj)) having {
    return ^(id obj) {
        [cscCentralManager->pocket setObject:obj forKey:NSStringFromClass([obj class])];
        return self;
    };
}


//切换委托频道
- (CSCBluetooth *(^)(NSString *channel)) channel {
    return ^CSCBluetooth *(NSString *channel) {
        //先缓存数据，到begin方法统一处理
        [cscCentralManager->pocket setValue:channel forKey:@"channel"];
        return self;
    };
}

- (void)validateProcess {
    
    NSMutableArray *faildReason = [[NSMutableArray alloc]init];
    
    //规则：不执行discoverDescriptorsForCharacteristic()时，不能执行readValueForDescriptors()
    if (!cscCentralManager->needDiscoverDescriptorsForCharacteristic) {
        if (cscCentralManager->needReadValueForDescriptors) {
            [faildReason addObject:@"未执行discoverDescriptorsForCharacteristic()不能执行readValueForDescriptors()"];
        }
    }
    
    //规则：不执行discoverCharacteristics()时，不能执行readValueForCharacteristic()或者是discoverDescriptorsForCharacteristic()
    if (!cscCentralManager->needDiscoverCharacteristics) {
        if (cscCentralManager->needReadValueForCharacteristic||cscCentralManager->needDiscoverDescriptorsForCharacteristic) {
            [faildReason addObject:@"未执行discoverCharacteristics()不能执行readValueForCharacteristic()或discoverDescriptorsForCharacteristic()"];
        }
    }
    
    //规则： 不执行discoverServices()不能执行discoverCharacteristics()、readValueForCharacteristic()、discoverDescriptorsForCharacteristic()、readValueForDescriptors()
    if (!cscCentralManager->needDiscoverServices) {
        if (cscCentralManager->needDiscoverCharacteristics||cscCentralManager->needDiscoverDescriptorsForCharacteristic ||cscCentralManager->needReadValueForCharacteristic ||cscCentralManager->needReadValueForDescriptors) {
             [faildReason addObject:@"未执行discoverServices()不能执行discoverCharacteristics()、readValueForCharacteristic()、discoverDescriptorsForCharacteristic()、readValueForDescriptors()"];
        }
        
    }

    //规则：不执行connectToPeripherals()时，不能执行discoverServices()
    if(!cscCentralManager->needConnectPeripheral) {
        if (cscCentralManager->needDiscoverServices) {
             [faildReason addObject:@"未执行connectToPeripherals()不能执行discoverServices()"];
        }
    }
    
    //规则：不执行needScanForPeripherals()，那么执行connectToPeripheral()方法时必须用having(peripheral)传入peripheral实例
    if (!cscCentralManager->needScanForPeripherals) {
        CBPeripheral *peripheral = [cscCentralManager->pocket valueForKey:NSStringFromClass([CBPeripheral class])];
        if (!peripheral) {
            [faildReason addObject:@"若不执行scanForPeripherals()方法，则必须执行connectToPeripheral方法并且需要传入参数(CBPeripheral *)peripheral"];
        }
    }
    
    //抛出异常
    if ([faildReason lastObject]) {
        NSException *e = [NSException exceptionWithName:@"BadyBluetooth usage exception" reason:[faildReason lastObject]  userInfo:nil];
        @throw e;
    }
  
}

- (CSCBluetooth *) and {
    return self;
}
- (CSCBluetooth *) then {
    return self;
}
- (CSCBluetooth *) with {
    return self;
}

- (CSCBluetooth *(^)()) enjoy {
    return ^CSCBluetooth *(int sec) {
        self.connectToPeripherals().discoverServices().discoverCharacteristics()
        .readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
        return self;
    };
}

#pragma mark - 工具方法
//断开连接
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    [cscCentralManager cancelPeripheralConnection:peripheral];
}
//断开所有连接
- (void)cancelAllPeripheralsConnection {
    [cscCentralManager cancelAllPeripheralsConnection];
}
//停止扫描
- (void)cancelScan{
    [cscCentralManager cancelScan];
}
//读取Characteristic的详细信息
- (CSCBluetooth *(^)(CBPeripheral *peripheral,CBCharacteristic *characteristic)) characteristicDetails {
    //切换频道
    [cscSpeaker switchChannel:[cscCentralManager->pocket valueForKey:@"channel"]];
    cscCentralManager->pocket = [[NSMutableDictionary alloc]init];
    
    return ^(CBPeripheral *peripheral,CBCharacteristic *characteristic) {
        //判断连接状态
        if (peripheral.state == CBPeripheralStateConnected) {
            self->cscCentralManager->oneReadValueForDescriptors = YES;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
        }
        else {
            CSCLog(@"!!!设备当前处于非连接状态");
        }
        
        return self;
    };
}

- (void)notify:(CBPeripheral *)peripheral
characteristic:(CBCharacteristic *)characteristic
        block:(void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))block {
    //设置通知
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    [cscSpeaker addNotifyCallback:characteristic withBlock:block];
}

- (void)cancelNotify:(CBPeripheral *)peripheral
     characteristic:(CBCharacteristic *)characteristic {
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
    [cscSpeaker removeNotifyCallback:characteristic];
}

//获取当前连接的peripherals
- (NSArray *)findConnectedPeripherals {
     return [cscCentralManager findConnectedPeripherals];
}

//获取当前连接的peripheral
- (CBPeripheral *)findConnectedPeripheral:(NSString *)peripheralName {
     return [cscCentralManager findConnectedPeripheral:peripheralName];
}

//获取当前corebluetooth的centralManager对象
- (CBCentralManager *)centralManager {
    return cscCentralManager->centralManager;
}

/**
 添加断开自动重连的外设
 */
- (void)AutoReconnect:(CBPeripheral *)peripheral{
    [cscCentralManager sometimes_ever:peripheral];
}

/**
 删除断开自动重连的外设
 */
- (void)AutoReconnectCancel:(CBPeripheral *)peripheral{
    [cscCentralManager sometimes_never:peripheral];
}
 
- (CBPeripheral *)retrievePeripheralWithUUIDString:(NSString *)UUIDString {
    CBPeripheral *p = nil;
    @try {
        NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:UUIDString];
        p = [self.centralManager retrievePeripheralsWithIdentifiers:@[uuid]][0];
    } @catch (NSException *exception) {
        CSCLog(@">>> retrievePeripheralWithUUIDString error:%@",exception)
    } @finally {
    }
    return p;
}

#pragma mark - peripheral model

//进入外设模式

- (CBPeripheralManager *)peripheralManager {
    return cscPeripheralManager.peripheralManager;
}

- (CSCPeripheralManager *(^)()) bePeripheral {
    return ^CSCPeripheralManager* () {
        return cscPeripheralManager;
    };
}
- (CSCPeripheralManager *(^)(NSString *localName)) bePeripheralWithName {
    return ^CSCPeripheralManager* (NSString *localName) {
        cscPeripheralManager.localName = localName;
        return cscPeripheralManager;
    };
}

- (void)peripheralModelBlockOnPeripheralManagerDidUpdateState:(void(^)(CBPeripheralManager *peripheral))block {
    [[cscSpeaker callback]setBlockOnPeripheralModelDidUpdateState:block];
}
- (void)peripheralModelBlockOnDidAddService:(void(^)(CBPeripheralManager *peripheral,CBService *service,NSError *error))block {
    [[cscSpeaker callback]setBlockOnPeripheralModelDidAddService:block];
}
- (void)peripheralModelBlockOnDidStartAdvertising:(void(^)(CBPeripheralManager *peripheral,NSError *error))block {
    [[cscSpeaker callback]setBlockOnPeripheralModelDidStartAdvertising:block];
}
- (void)peripheralModelBlockOnDidReceiveReadRequest:(void(^)(CBPeripheralManager *peripheral,CBATTRequest *request))block {
    [[cscSpeaker callback]setBlockOnPeripheralModelDidReceiveReadRequest:block];
}
- (void)peripheralModelBlockOnDidReceiveWriteRequests:(void(^)(CBPeripheralManager *peripheral,NSArray *requests))block {
    [[cscSpeaker callback]setBlockOnPeripheralModelDidReceiveWriteRequests:block];
}
- (void)peripheralModelBlockOnDidSubscribeToCharacteristic:(void(^)(CBPeripheralManager *peripheral,CBCentral *central,CBCharacteristic *characteristic))block {
    [[cscSpeaker callback]setBlockOnPeripheralModelDidSubscribeToCharacteristic:block];
}
- (void)peripheralModelBlockOnDidUnSubscribeToCharacteristic:(void(^)(CBPeripheralManager *peripheral,CBCentral *central,CBCharacteristic *characteristic))block {
    [[cscSpeaker callback]setBlockOnPeripheralModelDidUnSubscribeToCharacteristic:block];
}

@end



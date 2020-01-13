/*
 CSCBluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth 作者：刘彦玮
 https://github.com/coolnameismy/CSCBluetooth
 */

//  Created by 刘彦玮 on 15/9/2.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "CSCSpeaker.h"
#import "CSCDefine.h"


typedef NS_ENUM(NSUInteger, CSCSpeakerType) {
    CSCSpeakerTypeDiscoverPeripherals,
    CSCSpeakerTypeConnectedPeripheral,
    CSCSpeakerTypeDiscoverPeripheralsFailToConnect,
    CSCSpeakerTypeDiscoverPeripheralsDisconnect,
    CSCSpeakerTypeDiscoverPeripheralsDiscoverServices,
    CSCSpeakerTypeDiscoverPeripheralsDiscoverCharacteristics,
    CSCSpeakerTypeDiscoverPeripheralsReadValueForCharacteristic,
    CSCSpeakerTypeDiscoverPeripheralsDiscoverDescriptorsForCharacteristic,
    CSCSpeakerTypeDiscoverPeripheralsReadValueForDescriptorsBlock
};


@implementation CSCSpeaker {
    //所有委托频道
    NSMutableDictionary *channels;
    //当前委托频道
    NSString *currChannel;
    //notifyList
    NSMutableDictionary *notifyList;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CSCCallback *defaultCallback = [[CSCCallback alloc]init];
        notifyList = [[NSMutableDictionary alloc]init];
        channels = [[NSMutableDictionary alloc]init];
        currChannel = KCSC_DETAULT_CHANNEL;
        [channels setObject:defaultCallback forKey:KCSC_DETAULT_CHANNEL];
    }
    return self;
}

- (CSCCallback *)callback {
    return [channels objectForKey:KCSC_DETAULT_CHANNEL];
}

- (CSCCallback *)callbackOnCurrChannel {
    return [self callbackOnChnnel:currChannel];
}

- (CSCCallback *)callbackOnChnnel:(NSString *)channel {
    if (!channel) {
        [self callback];
    }
    return [channels objectForKey:channel];
}

- (CSCCallback *)callbackOnChnnel:(NSString *)channel
               createWhenNotExist:(BOOL)createWhenNotExist {
    
    CSCCallback *callback = [channels objectForKey:channel];
    if (!callback && createWhenNotExist) {
        callback = [[CSCCallback alloc]init];
        [channels setObject:callback forKey:channel];
    }
    
    return callback;
}

- (void)switchChannel:(NSString *)channel {
    if (channel) {
        if ([self callbackOnChnnel:channel]) {
            currChannel = channel;
            CSCLog(@">>>已切换到%@",channel);
        }
        else {
            CSCLog(@">>>所要切换的channel不存在");
        }
    }
    else {
        currChannel = KCSC_DETAULT_CHANNEL;
            CSCLog(@">>>已切换到默认频道");
    }
}

//添加到notify list
- (void)addNotifyCallback:(CBCharacteristic *)c
           withBlock:(void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))block {
    [notifyList setObject:block forKey:c.UUID.description];
}

//添加到notify list
- (void)removeNotifyCallback:(CBCharacteristic *)c {
    [notifyList removeObjectForKey:c.UUID.description];
}

//获取notify list
- (NSMutableDictionary *)notifyCallBackList {
    return notifyList;
}

//获取notityBlock
- (void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))notifyCallback:(CBCharacteristic *)c {
    return [notifyList objectForKey:c.UUID.description];
}
@end

/*
 CSCBluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth 作者：刘彦玮
 https://github.com/coolnameismy/CSCBluetooth
 */

//  Created by 刘彦玮 on 15/9/2.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "CSCCallback.h"

@implementation CSCCallback


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
            if (![peripheralName isEqualToString:@""]) {
                return YES;
            }
            return NO;
        }];
        [self setFilterOnconnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
            if (![peripheralName isEqualToString:@""]) {
                return YES;
            }
            return NO;
        }];
    }
    return self;
}
@end

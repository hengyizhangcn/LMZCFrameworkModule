//
//  SmartLockSDK.h
//  SmartLockSDK
//
//  Created by ccks on 2019/9/6.
//  Copyright © 2019 Stone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LoadSDKViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^SmartLockSDKDismissBlock)(void);
@interface SmartLockSDK : NSObject

@property (nonatomic, strong) SmartLockSDKDismissBlock dismissBlock;
+ (instancetype)shareManager;

/**
 初始化SDK

 @param extUserId 外部用户号
 @param leftButtonItemAction SDK页面销毁回调
 @return SDK导航控制器
 */
+ (nullable UINavigationController *)initSDKWithExtUserId:(NSString *)extUserId leftButtonItemAction:(nullable SmartLockSDKDismissBlock)leftButtonItemAction;

@end

NS_ASSUME_NONNULL_END

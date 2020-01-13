//
//  CSCSDKUserTemp.h
//  CSCFramework
//
//  Created by zcsmart on 2018/7/11.
//  Copyright © 2018年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSCSDKUserTemp, CSCUserTemp, CSCUserInfo;

@interface CSCSDKUserTemp : NSObject

+ (instancetype)sharedInstance;

/**
 @brief 申请用户匿名se
 @param userId  用户号
 @param block   结果
 */
- (void)userInitTemp:(NSString *)userId block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCUserTemp* userTemp))block;

@end

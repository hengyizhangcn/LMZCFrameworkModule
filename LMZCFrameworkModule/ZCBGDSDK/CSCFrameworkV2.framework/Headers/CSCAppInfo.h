//
//  CSCAppInfo.h
//  CSCVirtualCardSDK
//
//  Created by yinzhihao on 17/5/26.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import "CSCBaseModel.h"

/**
 @brief 常用参数管理，如app接口地址，版本信息等
 */
@interface CSCAppInfo : CSCBaseModel

// APP 初始化信息
@property (nonatomic, copy) NSString *externalUserId; //外部用户号
@property (nonatomic, copy) NSString *externalUserIdTemp; //外部用户号-匿名
@property (nonatomic, copy) NSString *appPhone; //用户手机号
@property (nonatomic, copy) NSString *appId; //应用名称
@property (nonatomic, copy) NSString *appVersion; //版本号


@end

//
//  CSCOrderInfo.h
//  CSCVirtualCardSDK
//
//  Created by yinzhihao on 17/5/25.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSCOrderInfo : NSObject

@property (nonatomic, copy) NSString *orderNo;//订单编号
@property (nonatomic, copy) NSString *tradeType;//交易类型
@property (nonatomic, copy) NSString *merId;//商户号
@property (nonatomic, copy) NSString *softCardNo;//卡号
@property (nonatomic, copy) NSString *tradeTime;//交易时间
@property (nonatomic, copy) NSString *amount;//交易金额
@property (nonatomic, copy) NSString *tradeStatus;//交易状态
@property (nonatomic, copy) NSString *extRequestTime;//外部请求时间

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

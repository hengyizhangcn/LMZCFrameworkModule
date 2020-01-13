//
//  CSCPayInfo.h
//  TestBJTDemo
//
//  Created by yinzhihao on 17/7/5.
//  Copyright © 2017年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSCPayInfo : NSObject

@property (nonatomic, copy) NSString *payId;//支付活动id
@property (nonatomic, copy) NSString *payName;//支付活动名字
@property (nonatomic, copy) NSString *currAvailAt;//可用余额
@property (nonatomic, copy) NSString *prdtTitle;//产品名称
@property (nonatomic, copy) NSString *prdtNo;//产品号
@property (nonatomic, copy) NSString *sttlUnit;//单位 1次2元3积分
@property (nonatomic, copy) NSString *payAmt;//折现率-消费数量 以分为单位
@property (nonatomic, copy) NSString *exchAmt;//折现率-折现数量 以分为单位

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

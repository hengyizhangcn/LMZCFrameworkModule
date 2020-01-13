//
//  CSCMerInfo.h
//  TestBJTDemo
//
//  Created by yinzhihao on 17/7/5.
//  Copyright © 2017年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSCMerInfo : NSObject

@property (nonatomic, copy) NSString *token;//token码
@property (nonatomic, copy) NSString *merId;//商户号
@property (nonatomic, copy) NSString *merName;//商户名称
@property (nonatomic, copy) NSString *merAddress;//商户地址

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

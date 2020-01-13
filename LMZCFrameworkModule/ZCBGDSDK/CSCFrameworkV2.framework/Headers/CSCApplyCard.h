//
//  CSCApplyCard.h
//  TestBJTDemo
//
//  Created by yinzhihao on 2017/8/8.
//  Copyright © 2017年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSCApplyCard : NSObject

@property (nonatomic, copy) NSString *brhId;//发卡机构号
@property (nonatomic, copy) NSString *brandId;//品牌号
@property (nonatomic, copy) NSString *userName;//姓名
@property (nonatomic, copy) NSString *userIdType;//证件类型
@property (nonatomic, copy) NSString *userIDNo;//证件号码 (与证件类型保持一致)
@property (nonatomic, copy) NSString *phone;//手机号码
@property (nonatomic, copy) NSString *hardCardNo;//硬卡号 (非必填)

@end

//
//  CSCApplyCardResult.h
//  TestBJTDemo
//
//  Created by yinzhihao on 17/7/5.
//  Copyright © 2017年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>



//申请/找回虚拟卡 结果
@interface CSCApplyCardResult : NSObject
@property (nonatomic, copy) NSString *ccksId;
@property (nonatomic, copy) NSString *stdType;
@property (nonatomic, copy) NSString *aid;
@property (nonatomic, copy) NSString *brandId;
@property (nonatomic, copy) NSString *brhId;
@property (nonatomic, copy) NSString *cardId;
@property (nonatomic, copy) NSString *cardInfo;


+(BOOL)saveCardResult:(CSCApplyCardResult *)cardResult WithUserId:(NSString *)userId withCardId:(NSString *)cardId;

+( CSCApplyCardResult * _Nullable )readCardResultWithUserId:(NSString *)userId withCardId:(NSString *)cardId;

+(BOOL)deleteCardResultWithUserId:(NSString *)userId withCardId:(NSString *)cardId;

@end

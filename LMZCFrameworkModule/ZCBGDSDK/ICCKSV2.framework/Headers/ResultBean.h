//
//  ResultBean.h
//  securitycontrols
//
//  Created by yinzhihao on 16/7/18.
//  Copyright © 2016年 csc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CSCCardFile15, CSCCardFile19;

@interface ResultBean : NSObject

@property (nonatomic) Boolean successful;
@property (nonatomic) NSInteger balance;
@property (nonatomic) NSData *cmdSendToCard;
@property (nonatomic, strong) CSCCardFile15 *cardFile15;
@property (nonatomic, strong) CSCCardFile19 *cardFile19;

/**
 * retCode 返回码 0 success 1 failed
 */
@property (nonatomic) int retCode;
/**
 * retInfo 返回信息
 */
@property (nonatomic) NSString *retInfo;
@property (nonatomic) NSString *cardNumber;

@property (nonatomic) int type;
@property (nonatomic) NSInteger currentStep;
/**
 *  totalStep 总步数/loopNum
 */
@property (nonatomic) NSInteger totalStep;

@end

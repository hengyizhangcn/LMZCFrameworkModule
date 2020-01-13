//
//  OutBean.h
//  securitycontrols
//
//  Created by yinzhihao on 16/7/19.
//  Copyright © 2016年 csc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 解析卡返回的参数
 */
@interface OutBean : NSObject
@property (nonatomic) NSData* type;
@property (nonatomic) NSData* loopNum;
@property (nonatomic) NSData* balance;
@property (nonatomic) NSData* cmdLen;
@property (nonatomic) NSData* cmdSendToCard;

@end

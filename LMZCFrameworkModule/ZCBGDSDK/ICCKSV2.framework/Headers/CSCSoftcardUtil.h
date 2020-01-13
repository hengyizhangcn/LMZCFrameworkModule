//
//  CSCSoftcardUtil.h
//  SoftpodsDemo
//
//  Created by zcsmart on 2017/7/18.
//  Copyright © 2017年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OutBean;

@interface CSCSoftcardUtil : NSObject

/**
 *  初始化 load软卡
 *
 *  @param ctx1     用户se 加解密虚拟卡，解密id文件用
 *  @param ctx2     交易 认证签名验签用
 *  @param ccksId   ccksId
 *  @param cardPath 虚拟卡路径
 *  @param codePath 密钥文件路径
 *  @param logPath  日志文件路径
 *
 *  @return return value description
 */

+ (void *)load_file_system:(void *)ctx1
                signCtx:(void *)ctx2
                 ccksId:(NSString*)ccksId
               cardPath:(NSString *)cardPath
               codePath:(NSString *)codePath
                   logPath:(NSString *)logPath;

/**
 * [command_proxy 处理指令接口]
 * @param  cmd  [指令]
 * @return 传回pos的指令
 */
+ (NSData *)command_proxy:(NSData *)cmd error:(NSError**)error;


/*
 *  获取认证信息
 *  ctx1 用户SE
 *  ctx2 电子证件虚拟卡SE
 *  stand         //1---住建部标准     2---交通部标准     3---CCKS标准
 *  ccksId ccksId
 *  aid 指令
 *  qrcode 码头
 *  cardPath 电子证件虚拟卡路径
 *  codePath 电子证件密钥文件路径
 *  logPath 日志路径
 *  error 错误
 */
+ (NSData *)getAuthInfo:(void *)ctx1
                signCtx:(void *)ctx2
                  stand:(int)stand
                 ccksId:(NSString *)ccksId
                    aid:(NSString *)aid
                 qrcode:(NSString *)qrcode
               cardId:(NSString *)cardId
               codePath:(NSString *)codePath
                logPath:(NSString *)logPath
                  error:(NSError *__autoreleasing *)error;

/*
 *  验证认证信息
 *  stand         //1---住建部标准     2---交通部标准     3---CCKS标准
 *  服务端验证使用 sdk暂时无法验证
 */
+ (BOOL)checkAuthInfo:(void *)ctx1
              signCtx:(void *)ctx2
                stand:(int)stand
               ccksId:(NSString*)ccksId
                  aid:(NSString *)aid
                 authData:(NSData *)authData
               cardPath:(NSString *)cardPath
               codePath:(NSString *)codePath
                logPath:(NSString *)logPath
                  error:(NSError**)error;

/**
 * 解析卡cmd
 */
+ (OutBean*)parseCardCmd:(NSData*)cmd;


+ (BOOL)compareLastByte:(NSData *)comData;

+ (NSError*)errorWithReason:(NSString*)reason
                       code:(NSInteger)code;


@end

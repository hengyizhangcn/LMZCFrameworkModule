//
//  Cks2Controller.h
//  Cks2Demo
//
//  Created by dengyu on 2019/8/13.
//  Copyright © 2019 zcsmart. All rights reserved.
//
//  说明：鉴于c层softkey接口的调整，特重新封装，以区别前一版本的CCKSController
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

//日志级别
#define ELOG_LVL_ASSERT                      0
#define ELOG_LVL_ERROR                       1
#define ELOG_LVL_WARN                        2
#define ELOG_LVL_INFO                        3
#define ELOG_LVL_DEBUG                       4
#define ELOG_LVL_VERBOSE                     5

typedef enum {
    ENKEY_TYPE_KSZ_ECPSZ_X_Y = 0,           ///< key长度(1B)|公钥点长度(1B)|X|Y
    ENKEY_TYPE_ECPSZ_X_Y,                   ///< 公钥点长度(1B)|X|Y
    ENKEY_TYPE_SZ_ECPSZ_X_Y,                ///< 长度(4B)|公钥点长度(1B)|X|Y
    ENKEY_TYPE_SZ1_ECPSZ_X_Y,               ///< 长度(1B)|公钥点长度(1B)|X|Y
    ENKEY_TYPE_NONE
} CKS_ENKEY_EXPORT_TYPE;

typedef enum {
    SKA_PADDING_PKCS7 = 0,                  ///< PKCS7 padding (default).
    SKA_PADDING_ONE_AND_ZEROS,              ///< ISO/IEC 7816-4 padding.
    SKA_PADDING_ZEROS_AND_LEN,              ///< ANSI X.923 padding.
    SKA_PADDING_ZEROS,                      ///< Zero padding (not reversible).
    SKA_PADDING_NONE,                       ///< Never pad (full blocks only).
    SKA_PADING_NOT_SUPPORT
}SKA_PADDING_TYPE;

typedef enum {
    SKA_AES_128_ECB = 0x10,
    SKA_AES_128_CBC,
    SKA_AES_128_GCM,
    SKA_AES_192_ECB = 0x20,
    SKA_AES_192_CBC,
    SKA_AES_192_GCM,
    SKA_AES_256_ECB = 0x30,
    SKA_AES_256_CBC,
    SKA_AES_256_GCM,
    SKA_DES_ECB = 0x40,
    SKA_DES_CBC,
    SKA_3DES_ECB = 0x50,
    SKA_3DES_CBC
}SKA_CIPHER_TYPE;

typedef enum {
    SIGN_TYPE_CSZ_C_SSZ_S = 0,              ///< C长度(1字节)|C|S长度(1字节)|S
    SIGN_TYPE_SZ_CSZ_C_S,                   ///< 长度(1字节)|C长度(1字节)|C|S
    SIGN_TYPE_CSZ_C_S,                      ///< C长度(1字节)|C|S
    SIGN_TYPE_SZ4_CSZ_C_S                   ///< 长度(4字节)|C长度(1字节)|C|S
}CKS_SIGN_EXPORT_TYPE;

enum {
    SIGN_DATA_HASH_NONE = 0,                ///< 签名时，不对数据进行hash
    SIGN_DATA_HASH_SHA2,                    ///< 签名时，采用sha2 256处理数据
    SIGN_DATA_HASH_SHA3,                    ///< 签名时，采用sha3 256处理数据
    SIGN_DATA_HASH_END
};

@interface Cks2Controller : NSObject

/**
 @brief 获取单例对象
 @return instancetype
 */
+ (instancetype)sharedManager;

/**
 * 开启日志
 * @param logPath           日志路径
 * @param level             日志级别
 */
- (void)cksStartLog:(NSString*)logPath
             level:(int)level;
/**
 * 设置日志级别
 * @param level             日志级别
 */
- (void)cksSetLogLevel:(int)level;

/**
 * 创建ccks执行环境
 * @param seData            SE数据（二进制数据，非文件路径）
 * @param mse               管理SE，如果没有则为NULL
 * @param ctxId             执行环境id（若加载相同的SE，ctxId相同则不会分配新的环境地址，不同则分配新的环境地址）
 * @return ccks执行环境地址
 */
- (void *)cksCreateCtx:(NSData*)seData
                                mse:(void *)mse
                              ctxId:(NSString*)ctxId;

/**
 * 销毁ccks执行环境
 * @param ctx               ccks执行环境地址
 */
- (void)cksDestoryCtx:(void *)ctx;

/**
 * 获取硬件号
 * @param                   ctx ccks执行环境地址
 * @return 硬件号，失败为NULL
 */
- (NSString*)cksGetSn:(void *)ctx;

/**
 * 获取挑战码
 * @param ctx               ccks执行环境地址
 * @return 挑战码，失败为NULL
 */
- (NSData*)cksGetChallCode:(void *)ctx
                     error:(NSError**)error;

/**
 * 初始化加密（此处使用c层softkey_init_encipher_old以兼容）
 * @param ctx               ccks执行环境地址
 * @param challCode         挑战码
 * @param data              待加密数据
 * @return 加密结果数据（格式：挑战码长度  + 加密数据长度 + 挑战码 + 加密数据），失败为NULL
 */
- (NSData*)cksInitEnc:(void*)ctx
            challCode:(NSData*)challCode
                 data:(NSData*)data
                error:(NSError**)error;

/**
 * 初始化解密
 * @param ctx               ccks执行环境地址
 * @param endata            加密数据（格式：挑战码长度  + 加密数据长度 + 挑战码 + 加密数据）
 * @return 解密结果
 */
- (NSData*)cksInitDec:(void*)ctx
               endata:(NSData*)endata
                error:(NSError**)error;

/**
 * 获取ccks域名
 * @param ctx               ccks执行环境地址
 * @return ccks域名，失败为NULL
 */
- (NSString*)cksGetDomain:(void*)ctx;

/**
 * 获取ccksid数量
 * @param ctx               ccks执行环境地址
 * @return ccksid数目，失败为<=0
 */
- (int)cksGetIdCnt:(void*)ctx;

/**
 * 获取第一个ccksid
 * @param ctx               ccks执行环境地址
 * @return ccksid，失败为NULL
 */
- (NSString*)cksGetFirstId:(void*)ctx;

/**
 * 获取ccksid，根据索引位
 * @param ctx               ccks执行环境地址
 * @param index             ID偏移，从1开始
 * @return ccksid，失败为NULL
 */
- (NSString*)cksGetId:(void*)ctx
                index:(uint32_t)index
                error:(NSError**)error;

/**
 * ccks加密，简化方法（使用常用加密参数）
 * @param ctx               ccks执行环境地址
 * @param ccksid            ccksid
 * @param data              待加密数据
 * @return 加密后数据，失败为NULL
 */
- (NSData*)cksEncSimple:(void*)ctx
                 ccksid:(NSString*)ccksid
                   data:(NSData*)data
                  error:(NSError**)error;


/**
 * ccks加密，根据不同算法加密
 */
- (NSData*)cksEncSimple:(void*)ctx
                 ccksid:(NSString*)ccksid
                   data:(NSData*)data
                   type:(SKA_CIPHER_TYPE)type
                  error:(NSError**)error;

/**
 * ccks解密，简化方法（使用常用加密参数）
 * @param ctx               ccks执行环境地址
 * @param ccksid            ccksid
 * @param data              待解密数据
 * @return 解密后数据，失败为NULL
 */
- (NSData*)cksDecSimple:(void*)ctx
                 ccksid:(NSString*)ccksid
                   data:(NSData*)data
                  error:(NSError**)error;

/**
 * ccks签名，简化方法（使用常用签名参数）
 * @param ctx               ccks执行环境地址
 * @param ccksid            ccksid
 * @param subdmid           子域id
 * @param data              待签名数据
 * @return 签名，失败为NULL
 */
- (NSData*)cksSignSimple:(void*)ctx
                  ccksid:(NSString*)ccksid
                 subdmid:(uint32_t)subdmid
                    data:(NSData*)data
                   error:(NSError**)error;

/**
 * ccks验签，简化方法（使用常用签名参数）
 * @param ctx               ccks执行环境地址
 * @param ccksid            ccksid
 * @param subdmid           子域id
 * @param data              签名数据
 * @param sign              签名
 * @return 验签成功返回0
 */
- (int)cksSignCheckSimple:(void*)ctx
                       ccksid:(NSString*)ccksid
                      subdmid:(uint32_t)subdmid
                         data:(NSData*)data
                         sign:(NSData*)sign
                        error:(NSError**)error;

/**
 * 个人收款二维码生成
 * @param ctx              se环境
 * @param ccksId               ccksid
 * @param codeHead        码头
 * @param codeBody        码体
 * @retrun  0 success
 */
- (NSString *)ccksQRCode_encode:(void *)ctx
                         ccksId:(NSString *)ccksId
                       codeHead:(NSString *)codeHead
                         cardNo:(NSString *)cardNo
                          money:(NSString *)money
                          error:(NSError **)error;


/**
 * 商户收款二维码生成
 * @param ctx              se环境
 * @param ccksId               ccksid
 * @param codeHead        码头
 * @param codeBody        码体
 * @retrun  0 success
 */
- (NSString *)ccksMerQRCode_encode:(void *)ctx
                            ccksId:(NSString *)ccksId
                          codeHead:(NSString *)codeHead
                        merchantNo:(NSString *)merchantNo
                             error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

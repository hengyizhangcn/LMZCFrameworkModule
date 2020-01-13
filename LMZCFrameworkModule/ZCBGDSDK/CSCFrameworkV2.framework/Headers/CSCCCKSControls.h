//
//  CSCCCKSControls.h
//  CSCVirtualCardSDK
//
//  Created by yinzhihao on 17/5/27.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief ios ckeys安全控件接口，待完成异常返回错误信息或其他方式返回错误信息NSError
 */
@interface CSCCCKSControls : NSObject

/**
 @brief 获取单例对象
 @return instancetype
 */
+ (instancetype)sharedInstance;


/**
 @brief 获取安全id
 @return id
 */
- (NSString *)getCurrentId;

/**
 @brief 加密
 @param plainStr 明文，必须UTF-8编码
 @return 密文
 */
- (NSData *)encryptData:(NSString *)plainStr;

/**
 @brief 加密
 @param plainStr 明文，必须UTF-8编码
 @param cpkId 安全id
 @return 密文
 */
- (NSData *)encryptData:(NSString *)plainStr cpkId:(NSString *)cpkId;



/**
 @brief 解密
 @param encryptData  加密的数据
 @return 解密数据
 */
- (NSString *)decodeData:(NSData *)encryptData;


/**
 @brief 给数据签名
 @param plainStr 待签名数据
 @return 返回签名后的数据，nil表示签名失败
 */
- (NSString *)signData:(NSString *)plainStr;


/**
 @brief 验证签名
 @param plainData 明文
 @param signData 签名数据
 @param cpkId 安全id
 @return 状态，非0表示失败
 */
- (BOOL)validSign:(NSData *)plainData signData:(NSData *)signData cpkId:(NSString *)cpkId;


#pragma mark - 添加tag

/**
 @brief 获取安全id
 @param tag 0.设备SE 1.用户SE 2.INIT.pack
 @return id
 */
- (NSString *)getCurrentId:(NSInteger)tag;

/**
 @brief 加密
 @param plainStr 明文，必须UTF-8编码
 @param tag 0.设备SE 1.用户SE 2.INIT.pack
 @return 密文
 */
- (NSData *)encryptData:(NSString *)plainStr tag:(NSInteger)tag;

/**
 @brief 加密
 @param plainStr 明文，必须UTF-8编码
 @param cpkId 安全id
 @param tag 0.设备SE 1.用户SE 2.INIT.pack
 @return 密文
 */
- (NSData *)encryptData:(NSString *)plainStr cpkId:(NSString *)cpkId tag:(NSInteger)tag;

/**
 @brief 根据算法加密
 @param plainStr 明文，必须UTF-8编码
 @param cpkId 安全id
 @param tag 0.设备SE 1.用户SE 2.INIT.pack
 @param enType 加密算法
 @return 密文
 */
- (NSData *)encryptData:(NSString *)plainStr cpkId:(NSString *)cpkId tag:(NSInteger)tag enType:(uint32_t)enType;



/**
 @brief 解密
 @param encryptData  加密的数据
 @param tag 0.设备SE 1.用户SE 2.INIT.pack
 @return 解密数据
 */
- (NSString *)decodeData:(NSData *)encryptData tag:(NSInteger)tag;

/**
 @brief 给数据签名
 @param plainStr 待签名数据
 @param tag 0.设备SE 1.用户SE 2.INIT.pack
 @return 返回签名后的数据，nil表示签名失败
 */
- (NSString *)signData:(NSString *)plainStr tag:(NSInteger)tag;

/**
 @brief 验证签名
 @param plainData 明文
 @param signData 签名数据
 @param cpkId 安全id
 @param tag 0.设备SE 1.用户SE 2.INIT.pack
 @return 状态，非0表示失败
 */
- (BOOL)validSign:(NSData *)plainData signData:(NSData *)signData cpkId:(NSString *)cpkId tag:(NSInteger)tag;

- (NSString *)getSn:(NSInteger)tag; //获取硬件号

@end

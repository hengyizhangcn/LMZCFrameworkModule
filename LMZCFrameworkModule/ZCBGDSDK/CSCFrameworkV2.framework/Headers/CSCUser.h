//
//  CSCUser.h
//  TestBJTDemo
//
//  Created by yinzhihao on 17/7/5.
//  Copyright © 2017年 zcsmart. All rights reserved.
//
#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
@class CSCApplyCardResult, CSCVirtualCard, CSCApplyCardResult, CSCVirtualCert, CSCCardInfo, CSCCertInfo, CSCPayInfo, CSCOrderInfo, CSCApplyCard, CSCCCKSListInfo,SEObject;

@interface CSCUser : NSObject

+ (instancetype)sharedInstance;

- (SEObject *)getUserSE;

#pragma mark - VC
/**
 @brief 容器修复
 @param cardFile 修复数据
 @param block   结果
 */
- (void)ContainerRestoreWithCardFile:(NSString *)cardFile block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, NSDictionary* result))block;

/**
 获取默认卡
 @param cardType 卡类型
 */
-(void)getDefaultCardWithCardType:(NSString *)cardType Withblock:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, NSDictionary* result))block;


/**
 @brief VC-01容器开卡
 @param applyCard 申请卡信息（除硬卡号外，其他为必填）
 @param block   结果
 */
- (void)applyCard:(CSCApplyCard *)applyCard block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, NSDictionary* result))block;

/**
 @brief VC-02加载虚拟卡
 @param cardId  卡号
 @param block   结果
 */
- (void)loadCard:(NSString *)cardId block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCVirtualCard* virtualCard))block;

/**
 @brief VC-03容器找回卡
 @param cardId  卡号
 @param block   结果
 */
- (void)getBackCard:(NSString *)cardId block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, NSDictionary* result))block;

//保存默认卡
- (void)saveVirtualCardFileWithUserId:(NSString *)userId WithCardResult:(CSCApplyCardResult *)cardResult block:(void (^)(BOOL isSuccess,NSString* retInfo))block;

//保存虚拟卡
- (void)saveCardFileWithCardResult:(CSCApplyCardResult *)cardResult block:(void (^)(BOOL isSuccess,NSString* retInfo))block;


//保存虚拟卡字典
- (void)saveCardFileWithCardData:(NSDictionary *)cardData block:(void (^)(BOOL isSuccess,NSString* retInfo))block;

#pragma mark - CERT
/**
 @brief CER-01 申请电子证件虚拟卡
 @param certInfo  证件信息
 @param block   结果
 */
- (void)applyElectronicId:(CSCCertInfo *)certInfo block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCApplyCardResult* result))block;

/**
 @brief CER-02 找回电子证件虚拟卡
 @param certId  电子证件的虚拟卡号
 @param block   结果
 */
- (void)getBackElectronicId:(NSString *)certId block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCApplyCardResult* result))block;

/**
 @brief 电子证件虚拟卡加载
 @param certId  电子证件的虚拟卡号
 @param block   结果
 */
- (void)loadCert:(NSString *)certId block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCVirtualCert* virtualCert))block;

/**
 @brief 电子证照签约
 @param block   结果
 */
- (void)signCert:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCVirtualCert* virtualCert))block;

#pragma mark - Q
/**
 @brief Q-01查询卡信息列表
 @param block   结果
 */
- (void)queryCardList:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, NSArray<CSCCardInfo *>* cardInfoList))block;

/**
 @brief Q-02查询卡信息
 @param cardId  卡号
 @param block   结果
 */
- (void)queryCardInfo:(NSString *)cardId block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, NSArray<CSCCardInfo *>* cardInfo))block;

/**
 @brief Q-03查询订单信息（通过ID）
 @param externalOrderId 外部订单号
 @param block   结果
 */
- (void)queryOrderInfoById:(NSString *)externalOrderId block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCOrderInfo* orderInfo))block;

/**
 @brief Q-04查询证件信息
 @param idNumber    证件号码
 @param block       结果
 */
- (void)queryCertInfo:(NSString *)idNumber block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCCertInfo* certInfo))block;

/**
 @brief Q-05查询证件列表
 @param block   结果
 */
- (void)queryCertInfoList:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, NSArray<CSCCertInfo *>* certInfoList))block;


/**
 @brief 获取商户信息（用户扫商户码）
 @param QRcode  二维码串
 @param block   结果
 */
- (void)decodeMerQrCode:(NSString *)QRcode block: (void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCMerInfo* merInfo))block;

/**
 @brief 获取支付信息列表
 @param merId  商户号
 @param cardId  卡号
 @param block   结果
 */
- (void)getPayInfo:(NSString *)merId cardId:(NSString *)cardId block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, NSArray<CSCPayInfo *>* payInfoList))block;


//根据卡号查找对应加密CCKS_ID和AID
- (void)queryCCKSListByCardId:(NSString *)vcardId block:(void (^)(BOOL isSuccessful, NSString *retCode, NSString *retInfo, CSCCCKSListInfo *ccksInfo))block;

/**
 @brief 释放资源，关闭后CSCUser不能再使用。
 */
- (void)close;

@end

//
//  CSCVirtualCard.h
//  TestBJTDemo
//
//  Created by yinzhihao on 17/7/5.
//  Copyright © 2017年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CSCMerInfo, CSCQrCodeResult, CSCMacResult;

@interface CSCVirtualCard : NSObject

+ (instancetype)sharedInstance;

//#pragma mark - 用户扫商户二维码支付
///**
// @brief 获取商户信息（用户扫商户码）
// @param QRcode  二维码串
// @param cardId  卡号
// @param block   结果
// */
//- (void)decodeMerQrCode:(NSString *)QRcode cardId:(NSString *)cardId block: (void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCMerInfo* merInfo))block;
//
///**
// @brief 二维码支付初始化（用户扫商户码）
// @param cardId  卡号
// @param money   金额(单位：分)
// @param block   结果（验卡信息）
// */
//- (void)merCodePayInit:(NSString *)cardId money:(NSString *)money block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCMacResult* result))block;
//
//
//#pragma mark - 商户扫描个人二维码支付
//
///**
// @brief 申请二维码串（商户扫用户码）
// @param cardId  卡号
// @param block   结果
// */
//- (void)qrCodePayInit:(NSString *)cardId block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCQrCodeResult* result))block;
//
//
//#pragma mark - 充值
//
///**
// @brief 联机充值初始化
// @param cardId  卡号
// @param money   金额(单位：分)
// @param block   结果（验卡信息）
// */
//- (void)rechargeInit:(NSString *)cardId money:(NSString *)money block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCMacResult* result))block;
//
//
//#pragma mark - 退货
///**
// @brief 退货初始化
// @param orderId 订单号
// @param cardId  卡号
// @param block   结果
// */
//- (void)refundInit:(NSString *)orderId cardId:(NSString *)cardId money:(NSString *)money block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, CSCQrCodeResult* result))block;

/**
 @brief 释放虚拟卡
 */
- (void)close;

@end

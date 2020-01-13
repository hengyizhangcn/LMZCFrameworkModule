//
//  ZCBGDFrameworkManager.h
//  ZCBGDFramework
//
//  Created by zcsmart on 2018/10/17.
//  Copyright © 2018年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ZCBGDSDKDismissBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface ZCBGDFrameworkManager : NSObject

/**
 * 初始化SDK - 通过APP内入口
 * @param extUserId 外部用户号
 * @param brhld 机构号（选填）
 * @param brandId brandId（选填）
 * @param appDownloadUrl 应用在AppStore的下载地址（选填）
 * @param leftButtonItemAction 设置首页leftButtonItem的点击事件，若leftButtonItemAction为nil将隐藏leftButtonItem
 * @return SDK导航控制器
 */
+ (nullable UINavigationController *)initSDKWithExtUserId:(NSString *)extUserId WithPhone:(NSString *)phone withBrhId:(nullable NSString*)brhld WithBrandId:(nullable NSString *)brandId appDownloadUrl:(nullable NSString *)appDownloadUrl leftButtonItemAction:(nullable ZCBGDSDKDismissBlock)leftButtonItemAction;


/*
//测试AFN
+ (void)testAFN;

//测试北京通SDK
+ (void)testBJTSDK;

//测试OC调用OC
+ (void)testOC_OC;

//测试OC调用Swift
+ (void)testOC_Swift;

//测试Swift调用OC
+ (void)testSwift_OC;

//测试Swift调用Swift
+ (void)testSwift_Swift;

//测试添加图片，storeboard，xib等资源文件
+ (void)testBundleFile;
*/

@end

NS_ASSUME_NONNULL_END

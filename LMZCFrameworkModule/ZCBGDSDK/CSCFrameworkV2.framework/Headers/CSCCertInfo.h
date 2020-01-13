///Users/yinzhihao/BeijingSDK/TestBJTDemo/TestBJTDemo/sdk
//  CSCCertInfo.h
//  CSCVirtualCardSDK
//
//  Created by yinzhihao on 17/6/19.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CSCCertInfo : NSObject

@property (nonatomic, copy) NSString *brhId;//发卡机构号
@property (nonatomic, copy) NSString *userCertName;//证件人名称
@property (nonatomic, copy) NSString *certStartDate;//证件有效开始日期
@property (nonatomic, copy) NSString *certEndDate;//证件有效结束日期
@property (nonatomic, copy) NSString *certType;//证照类型 1身份证 3护照 6居住证 7驾照
@property (nonatomic, copy) NSString *certNo;//证件号码
//注：申请电子证照时，以上为必填

@property (nonatomic) NSDictionary *certOthInfo;//模板数据（如有图片需传UIImage对象）
@property (nonatomic, copy) NSString *templateType;//模板类型

@property (nonatomic, copy) NSString *vcardId; //虚拟卡号

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

//
//  CSCUserInfo.h
//  Farmwork
//
//  Created by yinzhihao on 17/5/20.
//  Copyright © 2017年 Andy. All rights reserved.
//

#import <Foundation/Foundation.h>

//认证方式（0 未认证、1 公安、2 银行、3 电信运营商）
typedef NS_ENUM(NSInteger, AuthenticationType)
{
    AuthenticationTypeNone = 0,
    AuthenticationTypePublic = 1,
    AuthenticationTypeBank = 2,
    AuthenticationTypeTelecom = 3
};

//认证结果（0 无、1 通过、2 不通过）
typedef NS_ENUM(NSUInteger, AuthenticationResult) {
    AuthenticationResultNone = 0,
    AuthenticationResultPass = 1,
    AuthenticationResultNotPass = 2
};

@interface CSCUserInfo : NSObject

@property (nonatomic, copy) NSString *extUserId; //外部用户id（必填）
@property (nonatomic, copy) NSString *brhNo; //机构号
@property (nonatomic, copy) NSString *customerId; //推荐客户
@property (nonatomic, copy) NSString *customerType; //客户类别
@property (nonatomic, copy) NSString *customerLev; //客户级别
@property (nonatomic, copy) NSString *validLevel; //验证级别
@property (nonatomic, copy) NSString *applyLevel; //申请类别
@property (nonatomic, copy) NSString *cnName; //中文名 (必填)
@property (nonatomic, copy) NSString *enName; //英文名
@property (nonatomic, copy) NSString *pidType; //证件类型 （必填）1-身份证，2-户口本，3-护照，4-军人证，5-回乡证，6-居住证，7-驾照，8-企业代码证，9-经营许可证，A-事业执照，B-事业法人证 …X-其他 Y-电子邮件 Z-手机号码
@property (nonatomic, copy) NSString *pidCd; //证件号码 （必填）
@property (nonatomic, copy) NSString *eduLevel; //学历
@property (nonatomic, copy) NSString *health; //健康状况
@property (nonatomic, copy) NSString *status; //客户信息状态
@property (nonatomic, copy) NSString *email; //电子信箱
@property (nonatomic, copy) NSString *cell; //移动电话（必填）
@property (nonatomic, copy) NSString *nationatity; //国籍
@property (nonatomic, copy) NSString *province; //所属省份
@property (nonatomic, copy) NSString *city; // 所属城市
@property (nonatomic, copy) NSString *address; // 地址
@property (nonatomic, copy) NSString *postCode; // 邮编
@property (nonatomic, copy) NSString *tell; // 固定电话
@property (nonatomic, copy) NSString *fax; // 传真
@property (nonatomic, copy) NSString *lawName; // 法人代表姓名
@property (nonatomic, copy) NSString *lawPid; // 法人代表身份证
@property (nonatomic, copy) NSString *lawPidDt; // 法人代表身份证有效期
@property (nonatomic, copy) NSString *sex; // 性别
@property (nonatomic, copy) NSString *birthDate; // 出生日期
@property (nonatomic, copy) NSString *maritalStatus; // 婚姻状况
@property (nonatomic, copy) NSString *child; // 有无子女
@property (nonatomic, copy) NSString *bussType; // 职业类型
@property (nonatomic, copy) NSString *perIncome; // 个人年收入
@property (nonatomic, copy) NSString *familyIncome; // 家庭年收入
@property (nonatomic, copy) NSString *mailFlag; // 是否信函获取活动信息
@property (nonatomic, copy) NSString *cellFlag; // 是否手机短信获取活动信息
@property (nonatomic, copy) NSString *emailFlag; // 是否email获取活动信息
@property (nonatomic, copy) NSString *telFlag; // 是否电话获取活动信息
@property (nonatomic, copy) NSString *actContact; // 活动联系方式
@property (nonatomic, copy) NSString *flag; // 标识 （不传）
@property (nonatomic, copy) NSString *validCode; // 校验码 （不传）

@property (nonatomic, copy) NSString *isAuth; // 是否需要实名校验，0不校验，1校验（非必填，默认值0）


@end

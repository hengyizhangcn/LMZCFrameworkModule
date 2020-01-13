//
//  SLKeyInfoListModel.h
//  SmartLockSDK
//
//  Created by ccks on 2019/9/4.
//  Copyright © 2019 Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Keyinfolist,Electronkeys,Allowtimelist,SkeyList;
@interface SLKeyInfoListModel : NSObject

+(BOOL)saveKeyInfoList:(NSArray<SLKeyInfoListModel *> *)keyInfoList;

+(NSArray<SLKeyInfoListModel *> *)readKeyInfoList;

+(BOOL)deleteKeyInfoList;

@property (nonatomic, assign) NSTimeInterval saveTime;

@property (nonatomic, copy) NSString *lockNum;

@property (nonatomic, copy) NSString *accountRole;

@property (nonatomic, copy) NSString *termId;

@property (nonatomic, copy) NSString *startDt;

@property (nonatomic, copy) NSString *termMacc;

@property (nonatomic, copy) NSString *psamId;

@property (nonatomic, strong) NSArray<Electronkeys *> *electronKeys;

@property (nonatomic, copy) NSString *openType;

@property (nonatomic, copy) NSString *psamInfo;

@property (nonatomic, copy) NSString *endDt;

@property (nonatomic, copy) NSString *lockName;

@property (nonatomic, copy) NSString *keyId;

@property (nonatomic, assign) NSInteger keyUpdateTime;

@end

@interface Electronkeys : NSObject

@property (nonatomic, copy) NSString *keyId;

@property (nonatomic, strong) NSArray<SkeyList *> *skeyList;

@property (nonatomic, strong) NSArray<Allowtimelist *> *allowTimeList;

@property (nonatomic, copy) NSString *termId;

@property (nonatomic, copy) NSString *skeyTimeSlice;

@property (nonatomic, copy) NSString *lockMacAddr;

@property (nonatomic, copy) NSString *termMcc;

@property (nonatomic, copy) NSString *authStartDt;

@property (nonatomic, copy) NSString *authEndDt;

@property (nonatomic, assign) NSInteger keyType;

@property (nonatomic, copy) NSString *listSize;

@property (nonatomic, copy) NSString *cardId;

@property (nonatomic, copy) NSString *ccksIdLen;

@property (nonatomic, copy) NSString *orgData;

@property (nonatomic, copy) NSString *signData;

@property (nonatomic, copy) NSString *ccksId;

@end

@interface Allowtimelist : NSObject

@property (nonatomic, copy) NSString *keyId;

@property (nonatomic, copy) NSString *startTm;

@property (nonatomic, copy) NSString *endTm;

@end


@interface SkeyList : NSObject

@property (nonatomic, copy) NSString *skey;

@property (nonatomic, copy) NSString *startTime;

@property (nonatomic, copy) NSString *endTime;

@end

NS_ASSUME_NONNULL_END

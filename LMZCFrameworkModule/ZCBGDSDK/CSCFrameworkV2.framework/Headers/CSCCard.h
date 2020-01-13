//
//  CCKSCard.h
//  CCKSCardPack
//
//  Created by ccks on 2019/8/23.
//  Copyright © 2019 Stone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSCUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSCCard : NSObject

@property (nonatomic, assign) void *ctn;

+ (instancetype)sharedInstance;


/**
 初始化路径
 */
-(void)PathInit;

/**
 初始化容器
 @param ctx 用户SE
 @param userId 用户标识
 @param ctnId 容器标识
 */
-(void)packInitwithCtx:(void *)ctx
                withUserId:(NSString * _Nonnull)userId
                 withCtnId:(int )ctnId
                      with:(void (^)(BOOL isSuccess, NSError *error , void * ctn))block;

/**
 释放容器环境
 */
- (void)ctnFree;

/**
 删除容器

 @param ctx 用户SE
 @param userId 用户标识
 @param ctnId 容器标识
 */
- (void)ctnRemoveWithCtx:(void *)ctx
              WithUserId:(NSString*)userId
               WithCtnId:(int)ctnId
                    with:(void (^)(BOOL isSuccess))block;


/**
 添加文件

 @param fileName 文件名
 @param fileData 文件数据
 */
- (void)ctnAddFile:(NSString*)fileName
          fileData:(NSData*)fileData
              with:(void (^)(BOOL isSuccess))block;


/**
 获取文件
 @param fileName 文件名
 @return 文件描述符
 */
- (void*)GetFileWithFileName:(NSString*)fileName;


/**
 检查文件是否存在

 */
-(BOOL)checkFileExistsWithFileName:(NSString*)fileNam;


/**
 删除文件
 @param fileName 文件名
 */
- (void)DeleteFileWithFileName:(NSString*)fileName
                          with:(void (^)(BOOL isSuccess))block;


/**
 查找容器修复数据

 @param ctx 用户SE
 @param userId 用户标识
 @param ctnId 容器标识
 @param onlyUserId 当1时，只使用userId计算路径
 */
- (void)FindRestoreWithCtx:(void*)ctx
                WithUserId:(NSString*)userId
                 WithCtnId:(int)ctnId
            WithOnlyUserId:(int)onlyUserId
                      With:(void (^)(BOOL isSuccess , NSData *FindData))block;


/**
 导入修复数据
 @param repairData 修复过的数据
 */
- (void)RepairWithRepairData:(NSData*)repairData
                        With:(void (^)(BOOL isSuccess))block;


/**
 导入修复数据
 @param ctx 用户SE
 @param userId 用户标识
 @param ctnId 容器标识
 @param repairData 修复过的数据
 */
- (void)RepairWithCtx:(void*)ctx
           WithuserId:(NSString*)userId
            WithCtnId:(int)ctnId
       WithRepairData:(NSData *)repairData
                 With:(void (^)(BOOL isSuccess))block;

/**
 加载虚拟卡
 @param fileName 卡文件
 @param ctx 用户se
 */
-(void)loadCard:(void *)fileName
        WithCtx:(void*)ctx
           with:(void (^)(BOOL isSuccess))block;

/**
 发送指令
 */
-(void)command_proxy:(NSData *)cmd
                with:(void (^)(BOOL isSuccess,NSData *nscmd,NSData *retCode))block;


/**
 加载容器
 */
-(void)containerInitWithUserSE:(CSCUser *)user
                         block:(void (^)(BOOL isSuccess, NSString* retCode, NSString* retInfo, NSError *error,CSCCard* card))block;

-(void)checkCommand_proxy:(NSData *)cmd
                                with:(void (^)(BOOL isSuccess,NSData *nscmd,NSData *retCode))block;


- (NSData *)getAuthInfo:(void *)ctx1 signCtx:(void *)ctx2 stand:(int)stand ccksId:(NSString *)ccksId aid:(NSString *)aid qrcode:(NSString *)qrcode cardId:(NSString *)cardId codePath:(NSString *)codePath logPath:(NSString *)logPath error:(NSError *__autoreleasing *)errorl;

@end

NS_ASSUME_NONNULL_END

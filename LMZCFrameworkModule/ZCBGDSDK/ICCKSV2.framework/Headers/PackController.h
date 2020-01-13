//
//  PackController.h
//  Cks2Demo
//
//  Created by zcsmart on 2019/8/14.
//  Copyright © 2019 zcsmart. All rights reserved.
//
//  容器
//

#import <Foundation/Foundation.h>
#import "Cks2Controller.h"


NS_ASSUME_NONNULL_BEGIN

@interface PackController : NSObject

/**
 @brief 获取单例对象
 @return instancetype
 */
+ (instancetype)sharedManager;

/**
 * 初始化路径
 */
- (void)ctnPathInit;

/**
 * 初始化容器
 * @param cfgData           容器配置数据（二进制数据）
 * @param ctx               用户SE
 * @param userId            用户标识
 * @param ctnId             容器标识
 * @return 容器描述符
 */
- (void*)ctnInit:(NSData*)cfgData
                            ctx:(void*)ctx
                         userId:(NSString*)userId
                          ctnId:(int)ctnId
                          error:(NSError**)error;

/**
 * 初始化容器
 * @param cfgData           容器配置数据（二进制数据）
 * @param ctx               用户SE
 * @param ctnId             容器标识
 * @return 容器描述符
 */
- (void*)ctnInit:(NSData*)cfgData
                            ctx:(void*)ctx
                          ctnId:(int)ctnId
                          error:(NSError**)error;

/**
 * 释放容器环境
 * @param ctn               容器描述符
 */
- (void)ctnFree:(void*)ctn;

/**
 * 删除容器
 * @param cfgData           容器配置数据（二进制数据）
 * @param ctx               用户SE
 * @param userId            用户标识
 * @param ctnId             容器标识
 * @return 成功0，其他失败
 */
- (int)ctnRemove:(NSData*)cfgData
             ctx:(void*)ctx
          userId:(NSString*)userId
           ctnId:(int)ctnId;

/**
 * 添加文件
 * @param ctn               容器描述符
 * @param fileName          文件名
 * @param fileData          文件数据
 * @return 成功0，其他失败
 */
- (int)ctnAddFile:(void*)ctn
         fileName:(NSString*)fileName
         fileData:(NSData*)fileData;

/**
 * 获取文件
 * @param ctn               容器描述符
 * @param fileName          文件名
 * @return 文件描述符
 */
- (void*)ctnGetFile:(void*)ctn
                     fileName:(NSString*)fileName;

/**
 * 删除文件
 * @param ctn               容器描述符
 * @param fileName          文件名
 * @return 成功0，其他失败
 */
- (int)ctnDeleteFile:(void*)ctn
            fileName:(NSString*)fileName;

/**
 * 查找容器修复数据
 * @param cfgData           容器配置数据（二进制数据）
 * @param ctx               用户SE
 * @param userId            用户标识
 * @param ctnId             容器标识
 * @return 成功返回恢复数据，失败返回NULL
 */
- (NSData*)ctnFindRestore:(NSData*)cfgData
                      ctx:(void*)ctx
                   userId:(NSString*)userId
                    ctnId:(int)ctnId;

/**
 * 查找容器修复数据
 * @param cfgData           容器配置数据（二进制数据）
 * @param ctx               用户SE
 * @param userId            用户标识
 * @param ctnId             容器标识
 * @param onlyUserId        当1时，只使用userId计算路径
 * @return 成功返回恢复数据，失败返回NULL
 */
- (NSData*)ctnFindRestore:(NSData*)cfgData
                      ctx:(void*)ctx
                   userId:(NSString*)userId
                    ctnId:(int)ctnId
               onlyUserId:(int)onlyUserId;

/**
 * 导入修复数据
 * @param ctn               容器描述符
 * @param repairData        修复过的数据
 * @return 成功0
 */
- (int)ctnRepair:(void*)ctn
       repairData:(NSData*)repairData;

/**
 * 导入修复数据
 * @param cfgData           容器配置数据（二进制数据）
 * @param ctx               用户SE
 * @param userId            用户标识
 * @param ctnId             容器标识
 * @param repairData        修复过的数据
 * @return 成功0
 */
- (int)ctnRepair:(NSData*)cfgData
             ctx:(void*)ctx
          userId:(NSString*)userId
           ctnId:(int)ctnId
      repairData:(NSData *)repairData;


/**
 加载虚拟卡

 @param fileName 虚拟卡文件
 @param ctx 用户se
 @return 0成功
 */
-(int)loadCard:(void *)fileName
       WithCtx:(void*)ctx;

-(int)loadCard:(void *)fileName
       WithCtx:(void*)ctx
    WithCcksid:(NSString *)ccksId;


/**
 发送指令
 */
- (NSData *)command_proxy:(NSData *)cmd;

-(NSData *)checkCommand_proxy:(NSData *)cmd;

@end

NS_ASSUME_NONNULL_END

//
//  CSCSoftpodsUtil.h
//  SoftpodsDemo
//
//  Created by zcsmart on 2017/7/18.
//  Copyright © 2017年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ResultBean;

//交易类型
typedef enum PayTypeEnum
{
    Off_line, //脱机
    On_line  //联机
    
}PayTypeEnum;

@interface CSCSoftpodsUtil : NSObject

+ (int)softpos_certification_init:(NSString *)log_path;
+ (NSData *)softpos_select_aid_cmd:(NSError**)error;
+ (NSData *)softpos_get_cert_authentication_cmd:(NSString *)msg error:(NSError**)error;
+ (NSData *)softpos_check_cert_authentication_cmd:(NSData *)authData error:(NSError**)error;
#pragma mark -初始化 软pos
/**
 *  初始化 软pos
 *
 *  @param stand         //1---住建部标准     2---交通部标准     3---CCKS标准
 *  @param payTypeEnum   交易类型
 *  @param cityCode      城市代码
 *  @param termCode      终端号
 *  @param cardCode      发卡方代码
 *  @param cityBlankList 白名单列表
 *  @param logPath       创建目录路径
 *  @param pack          容器的路径,暂时不用
 *  @param sckIP         后面的传输暂时不用：随便传
 *  @param sckPort
 *  @param error         错误信息
 *
 *  @return 返回状态
 */
- (int)softpos_container_open:(void *)ctx
                        stand:(int)stand
                  PayTypeEnum:(PayTypeEnum)payTypeEnum
                     cityCode:(NSData *)cityCode
                     termCode:(NSData *)termCode
                     cardCode:(NSData *)cardCode
                cityBlankList:(NSArray<NSData*> *)cityBlankList
                      logPath:(NSString *)logPath
                   domainName:(NSString *)domainName
                      keyFile:(NSString *)keyFile
                        error:(NSError**)error;

/**
 *  softpos初始化，无se
 *
 *  @param payTypeEnum   交易类型
 *  @param cityCode      城市代码
 *  @param termCode      终端号
 *  @param cardCode      发卡方代码
 *  @param cityBlankList 白名单列表
 *  @param logPath       创建目录路径
 *  @param error         错误信息
 *
 *  @return 返回状态
 */
- (int)softpos_container_initdata:(PayTypeEnum)payTypeEnum
                         cityCode:(NSData *)cityCode
                         termCode:(NSData *)termCode
                         cardCode:(NSData *)cardCode
                    cityBlankList:(NSArray<NSData*> *)cityBlankList
                          logPath:(NSString *)logPath
                            error:(NSError**)error;

//workType 1.获取15文件对象 2.获取19文件对象
- (int)softpos_query:(int)workType stand:(int)stand step:(int *)step input:(void *)input inputSize:(int)inputSize output:(void *)output;
/*
 * 获取15文件对象
 */
- (ResultBean *)cardFile15:(int)stand finish:(void(^)(id cardFileModel))blockFinish;
/*
 * 获取19文件对象
 */
- (ResultBean *)cardFile19:(int)stand finish:(void(^)(id cardFileModel))blockFinish;
/*
 * 获取验卡信息
 */
- (ResultBean *)checkCardInfo:(int)stand finish:(void(^)(id cardFileModel))blockFinish;

/**
 *  验卡接口
 *  //1---住建部标准     2---交通部标准     3---CCKS标准
 *  @param step      int型的指针 步数
 *  @param input     传入的参数 char数组（char指针） 软卡command_proxy返回的数据 sen_buf
 *  @param inputSize 传入参数的长度     				软卡command_proxy返回的数据 sen_size
 *  @param output    传出参数
 *
 *  @return 返回状态
 */
- (int)softpos_check_card:(char)stand
                     step:(int *)step
                    input:(void *)input
                inputSize:(int)inputSize
                   output:(void *)output;

/**
 *  验卡接口 EX 兼容
 *  //1---住建部标准     2---交通部标准     3---CCKS标准
 *  @param step      int型的指针 步数
 *  @param input     传入的参数 char数组（char指针） 软卡command_proxy返回的数据 sen_buf
 *  @param inputSize 传入参数的长度     				软卡command_proxy返回的数据 sen_size
 *  @param output    传出参数
 *
 *  @return 返回状态
 */
- (int)softpos_check_cardEX:(char)stand
                       step:(int *)step
                      input:(void *)input
                  inputSize:(int)inputSize
                     output:(void *)output;

/**
 *  关闭pos
 *
 *  @param error 错误信息
 *
 *  
 */
+ (void)softpos_container_close:(NSError**)error;

/*
    //1---住建部标准     2---交通部标准     3---CCKS标准
    aid 指令
 */
+ (int)softpos_select_application:(int)stand aid:(NSString *)aid error:(NSError**)error;

#pragma mark -验卡接口
/**
 *  验卡接口
 *  //1---住建部标准     2---交通部标准     3---CCKS标准
 *  @param blockFinish 回调
 *
 *  @return 返回信息
 */
- (ResultBean*)softpos_check_cardWithStand:(int)stand finish:(void(^)(NSData* cmdSendToCard))blockFinish;
/**
 *  验卡接口 ex 兼容
 *  //1---住建部标准     2---交通部标准     3---CCKS标准
 *  @param blockFinish 回调
 *
 *  @return 返回信息
 */
- (ResultBean*)softpos_check_cardEXWithStand:(int)stand finish:(void(^)(NSData* cmdSendToCard))blockFinish;



@end

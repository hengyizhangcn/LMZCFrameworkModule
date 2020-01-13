/*
 CSCBluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth 作者：刘彦玮
 https://github.com/coolnameismy/CSCBluetooth
 
 @brief  CSCbluetooth Rhythm用于检测蓝牙的任务执行情况，处理复杂的蓝牙流程操作
 
 */
//
//  Created by ZTELiuyw on 15/9/15.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSCDefine.h"


@interface CSCRhythm : NSObject


typedef void (^BBBeatsBreakBlock)(CSCRhythm *bry);
typedef void (^BBBeatsOverBlock)(CSCRhythm *bry);

//timer for beats
@property (nonatomic, strong) NSTimer *beatsTimer;

//beat interval
@property NSInteger beatsInterval;



#pragma mark beats
//心跳
- (void)beats;
//主动中断心跳
- (void)beatsBreak;
//结束心跳，结束后会进入BlockOnBeatOver，并且结束后再不会在触发BlockOnBeatBreak
- (void)beatsOver;
//恢复心跳，beatsOver操作后可以使用beatsRestart恢复心跳，恢复后又可以进入BlockOnBeatBreak方法
- (void)beatsRestart;

//心跳中断的委托
- (void)setBlockOnBeatsBreak:(void(^)(CSCRhythm *bry))block;
//心跳结束的委托
- (void)setBlockOnBeatsOver:(void(^)(CSCRhythm *bry))block;

@end

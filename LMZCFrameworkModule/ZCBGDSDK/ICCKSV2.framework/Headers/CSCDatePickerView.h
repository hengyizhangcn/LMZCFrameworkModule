//
//  CSCDatePickerView.h
//  CSCPickerViewDemo
//
//  Created by 任波 on 2017/8/11.
//  Copyright © 2017年 renb. All rights reserved.
//
//  最新代码下载地址：https://github.com/91renb/CSCPickerView

#import "CSCBaseView.h"
#import "NSDate+CSCPickerView.h"

/// 弹出日期类型
typedef NS_ENUM(NSInteger, CSCDatePickerMode) {
    // --- 以下4种是系统自带的样式 ---
    // UIDatePickerModeTime
    CSCDatePickerModeTime,              // HH:mm
    // UIDatePickerModeDate
    CSCDatePickerModeDate,              // yyyy-MM-dd
    // UIDatePickerModeDateAndTime
    CSCDatePickerModeDateAndTime,       // yyyy-MM-dd HH:mm
    // UIDatePickerModeCountDownTimer
    CSCDatePickerModeCountDownTimer,    // HH:mm
    // --- 以下7种是自定义样式 ---
    // 年月日时分
    CSCDatePickerModeYMDHM,      // yyyy-MM-dd HH:mm
    // 月日时分
    CSCDatePickerModeMDHM,       // MM-dd HH:mm
    // 年月日
    CSCDatePickerModeYMD,        // yyyy-MM-dd
    // 年月
    CSCDatePickerModeYM,         // yyyy-MM
    // 年
    CSCDatePickerModeY,          // yyyy
    // 月日
    CSCDatePickerModeMD,         // MM-dd
    // 时分
    CSCDatePickerModeHM          // HH:mm
};

typedef void(^CSCDateResultBlock)(NSString *selectValue);
typedef void(^CSCDateCancelBlock)(void);

@interface CSCDatePickerView : CSCBaseView

/**
 *  1.显示时间选择器
 *
 *  @param title            标题
 *  @param dateType         日期显示类型
 *  @param defaultSelValue  默认选中的时间（值为空/值格式错误时，默认就选中现在的时间）
 *  @param resultBlock      选择结果的回调
 *
 */
+ (void)showDatePickerWithTitle:(NSString *)title
                       dateType:(CSCDatePickerMode)dateType
                defaultSelValue:(NSString *)defaultSelValue
                    resultBlock:(CSCDateResultBlock)resultBlock;

/**
 *  2.显示时间选择器（支持 设置自动选择 和 自定义主题颜色）
 *
 *  @param title            标题
 *  @param dateType         日期显示类型
 *  @param defaultSelValue  默认选中的时间（值为空/值格式错误时，默认就选中现在的时间）
 *  @param minDate          最小时间，可为空（请使用 NSDate+CSCPickerView 分类中和显示类型格式对应的方法创建 minDate）
 *  @param maxDate          最大时间，可为空（请使用 NSDate+CSCPickerView 分类中和显示类型格式对应的方法创建 maxDate）
 *  @param isAutoSelect     是否自动选择，即选择完(滚动完)执行结果回调，传选择的结果值
 *  @param themeColor       自定义主题颜色
 *  @param resultBlock      选择结果的回调
 *
 */
+ (void)showDatePickerWithTitle:(NSString *)title
                       dateType:(CSCDatePickerMode)dateType
                defaultSelValue:(NSString *)defaultSelValue
                        minDate:(NSDate *)minDate
                        maxDate:(NSDate *)maxDate
                   isAutoSelect:(BOOL)isAutoSelect
                     themeColor:(UIColor *)themeColor
                    resultBlock:(CSCDateResultBlock)resultBlock;

/**
 *  3.显示时间选择器（支持 设置自动选择、自定义主题颜色、取消选择的回调）
 *
 *  @param title            标题
 *  @param dateType         日期显示类型
 *  @param defaultSelValue  默认选中的时间（值为空/值格式错误时，默认就选中现在的时间）
 *  @param minDate          最小时间，可为空（请使用 NSDate+CSCPickerView 分类中和显示类型格式对应的方法创建 minDate）
 *  @param maxDate          最大时间，可为空（请使用 NSDate+CSCPickerView 分类中和显示类型格式对应的方法创建 maxDate）
 *  @param isAutoSelect     是否自动选择，即选择完(滚动完)执行结果回调，传选择的结果值
 *  @param themeColor       自定义主题颜色
 *  @param resultBlock      选择结果的回调
 *  @param cancelBlock      取消选择的回调
 *
 */
+ (void)showDatePickerWithTitle:(NSString *)title
                       dateType:(CSCDatePickerMode)dateType
                defaultSelValue:(NSString *)defaultSelValue
                        minDate:(NSDate *)minDate
                        maxDate:(NSDate *)maxDate
                   isAutoSelect:(BOOL)isAutoSelect
                     themeColor:(UIColor *)themeColor
                    resultBlock:(CSCDateResultBlock)resultBlock
                    cancelBlock:(CSCDateCancelBlock)cancelBlock;

@end

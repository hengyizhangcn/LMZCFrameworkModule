
#ifndef __CSCExtensionConst__H__
#define __CSCExtensionConst__H__

#import <Foundation/Foundation.h>

#ifndef MJ_LOCK
#define MJ_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef MJ_UNLOCK
#define MJ_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

// 信号量
#define MJExtensionSemaphoreCreate \
static dispatch_semaphore_t signalSemaphore; \
static dispatch_once_t onceTokenSemaphore; \
dispatch_once(&onceTokenSemaphore, ^{ \
    signalSemaphore = dispatch_semaphore_create(1); \
});

#define MJExtensionSemaphoreWait MJ_LOCK(signalSemaphore)
#define MJExtensionSemaphoreSignal MJ_UNLOCK(signalSemaphore)

// 过期
#define MJExtensionDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 构建错误
#define MJExtensionBuildError(clazz, msg) \
NSError *error = [NSError errorWithDomain:msg code:250 userInfo:nil]; \
[clazz setMj_error:error];

// 日志输出
#ifdef DEBUG
#define MJExtensionLog(...) NSLog(__VA_ARGS__)
#else
#define MJExtensionLog(...)
#endif

/**
 * 断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define MJExtensionAssertError(condition, returnValue, clazz, msg) \
[clazz setMj_error:nil]; \
if ((condition) == NO) { \
    MJExtensionBuildError(clazz, msg); \
    return returnValue;\
}

#define MJExtensionAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

/**
 * 断言
 * @param condition   条件
 */
#define MJExtensionAssert(condition) MJExtensionAssert2(condition, )

/**
 * 断言
 * @param param         参数
 * @param returnValue   返回值
 */
#define MJExtensionAssertParamNotNil2(param, returnValue) \
MJExtensionAssert2((param) != nil, returnValue)

/**
 * 断言
 * @param param   参数
 */
#define MJExtensionAssertParamNotNil(param) MJExtensionAssertParamNotNil2(param, )

/**
 * 打印所有的属性
 */
#define MJLogAllIvars \
- (NSString *)description \
{ \
    return [self mj_keyValues].description; \
}
#define MJExtensionLogAllProperties MJLogAllIvars

/** 仅在 Debugger 展示所有的属性 */
#define MJImplementDebugDescription \
- (NSString *)debugDescription \
{ \
return [self mj_keyValues].debugDescription; \
}

/**
 *  类型（属性类型）
 */
FOUNDATION_EXPORT NSString *const CSCPropertyTypeInt;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeShort;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeFloat;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeDouble;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeLong;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeLongLong;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeChar;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeBOOL1;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeBOOL2;
FOUNDATION_EXPORT NSString *const CSCPropertyTypePointer;

FOUNDATION_EXPORT NSString *const CSCPropertyTypeIvar;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeMethod;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeBlock;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeClass;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeSEL;
FOUNDATION_EXPORT NSString *const CSCPropertyTypeId;

#endif

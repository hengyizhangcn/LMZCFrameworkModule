/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "CSCmetamacros.h"

#ifndef CSC_LOCK
#define CSC_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef CSC_UNLOCK
#define CSC_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

#ifndef CSC_OPTIONS_CONTAINS
#define CSC_OPTIONS_CONTAINS(options, value) (((options) & (value)) == (value))
#endif

#ifndef weakify
#define weakify(...) \
sd_keywordify \
metamacro_foreach_cxt(sd_weakify_,, __weak, __VA_ARGS__)
#endif

#ifndef strongify
#define strongify(...) \
sd_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
metamacro_foreach(sd_strongify_,, __VA_ARGS__) \
_Pragma("clang diagnostic pop")
#endif

#define sd_weakify_(INDEX, CONTEXT, VAR) \
CONTEXT __typeof__(VAR) metamacro_concat(VAR, _weak_) = (VAR);

#define sd_strongify_(INDEX, VAR) \
__strong __typeof__(VAR) VAR = metamacro_concat(VAR, _weak_);

#if DEBUG
#define sd_keywordify autoreleasepool {}
#else
#define sd_keywordify try {} @catch (...) {}
#endif

#ifndef onExit
#define onExit \
sd_keywordify \
__strong sd_cleanupBlock_t metamacro_concat(sd_exitBlock_, __LINE__) __attribute__((cleanup(sd_executeCleanupBlock), unused)) = ^
#endif

typedef void (^sd_cleanupBlock_t)(void);

#if defined(__cplusplus)
extern "C" {
#endif
    void sd_executeCleanupBlock (__strong sd_cleanupBlock_t *block);
#if defined(__cplusplus)
}
#endif

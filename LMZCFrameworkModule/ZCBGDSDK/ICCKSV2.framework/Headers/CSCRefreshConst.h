//  代码地址: https://github.com/CoderCSCLee/CSCRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
#import <UIKit/UIKit.h>
#import <objc/message.h>

// 弱引用
#define CSCWeakSelf __weak typeof(self) weakSelf = self;

// 日志输出
#ifdef DEBUG
#define CSCRefreshLog(...) NSLog(__VA_ARGS__)
#else
#define CSCRefreshLog(...)
#endif

// 过期提醒
#define CSCRefreshDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 运行时objc_msgSend
#define CSCRefreshMsgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define CSCRefreshMsgTarget(target) (__bridge void *)(target)

// RGB颜色
#define CSCRefreshColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 文字颜色
#define CSCRefreshLabelTextColor CSCRefreshColor(90, 90, 90)

// 字体大小
#define CSCRefreshLabelFont [UIFont boldSystemFontOfSize:14]

// 常量
UIKIT_EXTERN const CGFloat CSCRefreshLabelLeftInset;
UIKIT_EXTERN const CGFloat CSCRefreshHeaderHeight;
UIKIT_EXTERN const CGFloat CSCRefreshFooterHeight;
UIKIT_EXTERN const CGFloat CSCRefreshFastAnimationDuration;
UIKIT_EXTERN const CGFloat CSCRefreshSlowAnimationDuration;

UIKIT_EXTERN NSString *const CSCRefreshKeyPathContentOffset;
UIKIT_EXTERN NSString *const CSCRefreshKeyPathContentSize;
UIKIT_EXTERN NSString *const CSCRefreshKeyPathContentInset;
UIKIT_EXTERN NSString *const CSCRefreshKeyPathPanState;

UIKIT_EXTERN NSString *const CSCRefreshHeaderLastUpdatedTimeKey;

UIKIT_EXTERN NSString *const CSCRefreshHeaderIdleText;
UIKIT_EXTERN NSString *const CSCRefreshHeaderPullingText;
UIKIT_EXTERN NSString *const CSCRefreshHeaderRefreshingText;

UIKIT_EXTERN NSString *const CSCRefreshAutoFooterIdleText;
UIKIT_EXTERN NSString *const CSCRefreshAutoFooterRefreshingText;
UIKIT_EXTERN NSString *const CSCRefreshAutoFooterNoMoreDataText;

UIKIT_EXTERN NSString *const CSCRefreshBackFooterIdleText;
UIKIT_EXTERN NSString *const CSCRefreshBackFooterPullingText;
UIKIT_EXTERN NSString *const CSCRefreshBackFooterRefreshingText;
UIKIT_EXTERN NSString *const CSCRefreshBackFooterNoMoreDataText;

UIKIT_EXTERN NSString *const CSCRefreshHeaderLastTimeText;
UIKIT_EXTERN NSString *const CSCRefreshHeaderDateTodayText;
UIKIT_EXTERN NSString *const CSCRefreshHeaderNoneLastDateText;

// 状态检查
#define CSCRefreshCheckState \
CSCRefreshState oldState = self.state; \
if (state == oldState) return; \
[super setState:state];

// 异步主线程执行，不强持有Self
#define CSCRefreshDispatchAsyncOnMainQueue(x) \
__weak typeof(self) weakSelf = self; \
dispatch_async(dispatch_get_main_queue(), ^{ \
typeof(weakSelf) self = weakSelf; \
{x} \
});


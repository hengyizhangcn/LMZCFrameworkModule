//  代码地址: https://github.com/CoderCSCLee/CSCRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
#import <UIKit/UIKit.h>

const CGFloat CSCRefreshLabelLeftInset = 25;
const CGFloat CSCRefreshHeaderHeight = 54.0;
const CGFloat CSCRefreshFooterHeight = 44.0;
const CGFloat CSCRefreshFastAnimationDuration = 0.25;
const CGFloat CSCRefreshSlowAnimationDuration = 0.4;

NSString *const CSCRefreshKeyPathContentOffset = @"contentOffset";
NSString *const CSCRefreshKeyPathContentInset = @"contentInset";
NSString *const CSCRefreshKeyPathContentSize = @"contentSize";
NSString *const CSCRefreshKeyPathPanState = @"state";

NSString *const CSCRefreshHeaderLastUpdatedTimeKey = @"CSCRefreshHeaderLastUpdatedTimeKey";

NSString *const CSCRefreshHeaderIdleText = @"CSCRefreshHeaderIdleText";
NSString *const CSCRefreshHeaderPullingText = @"CSCRefreshHeaderPullingText";
NSString *const CSCRefreshHeaderRefreshingText = @"CSCRefreshHeaderRefreshingText";

NSString *const CSCRefreshAutoFooterIdleText = @"CSCRefreshAutoFooterIdleText";
NSString *const CSCRefreshAutoFooterRefreshingText = @"CSCRefreshAutoFooterRefreshingText";
NSString *const CSCRefreshAutoFooterNoMoreDataText = @"CSCRefreshAutoFooterNoMoreDataText";

NSString *const CSCRefreshBackFooterIdleText = @"CSCRefreshBackFooterIdleText";
NSString *const CSCRefreshBackFooterPullingText = @"CSCRefreshBackFooterPullingText";
NSString *const CSCRefreshBackFooterRefreshingText = @"CSCRefreshBackFooterRefreshingText";
NSString *const CSCRefreshBackFooterNoMoreDataText = @"CSCRefreshBackFooterNoMoreDataText";

NSString *const CSCRefreshHeaderLastTimeText = @"CSCRefreshHeaderLastTimeText";
NSString *const CSCRefreshHeaderDateTodayText = @"CSCRefreshHeaderDateTodayText";
NSString *const CSCRefreshHeaderNoneLastDateText = @"CSCRefreshHeaderNoneLastDateText";

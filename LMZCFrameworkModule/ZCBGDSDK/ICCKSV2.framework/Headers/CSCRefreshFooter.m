//  代码地址: https://github.com/CoderCSCLee/CSCRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  CSCRefreshFooter.m
//  CSCRefreshExample
//
//  Created by CSC Lee on 15/3/5.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CSCRefreshFooter.h"
#include "UIScrollView+CSCRefresh.h"
#import "UIView+CSCRefreshExtension.h"

@interface CSCRefreshFooter()

@end

@implementation CSCRefreshFooter
#pragma mark - 构造方法
+ (instancetype)footerWithRefreshingBlock:(CSCRefreshComponentRefreshingBlock)refreshingBlock
{
    CSCRefreshFooter *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}
+ (instancetype)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    CSCRefreshFooter *cmp = [[self alloc] init];
    [cmp setRefreshingTarget:target refreshingAction:action];
    return cmp;
}

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    
    // 设置自己的高度
    self.mj_h = CSCRefreshFooterHeight;
    
    // 默认不会自动隐藏
//    self.automaticallyHidden = NO;
}

//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//
//    if (newSuperview) {
//        // 监听scrollView数据的变化
//        if ([self.scrollView isKindOfClass:[UITableView class]] || [self.scrollView isKindOfClass:[UICollectionView class]]) {
//            [self.scrollView setMj_reloadDataBlock:^(NSInteger totalDataCount) {
//                if (self.isAutomaticallyHidden) {
//                    self.hidden = (totalDataCount == 0);
//                }
//            }];
//        }
//    }
//}

#pragma mark - 公共方法
- (void)endRefreshingWithNoMoreData
{
    CSCRefreshDispatchAsyncOnMainQueue(self.state = CSCRefreshStateNoMoreData;)
}

- (void)noticeNoMoreData
{
    [self endRefreshingWithNoMoreData];
}

- (void)resetNoMoreData
{
    CSCRefreshDispatchAsyncOnMainQueue(self.state = CSCRefreshStateIdle;)
}

- (void)setAutomaticallyHidden:(BOOL)automaticallyHidden
{
    _automaticallyHidden = automaticallyHidden;
}
@end

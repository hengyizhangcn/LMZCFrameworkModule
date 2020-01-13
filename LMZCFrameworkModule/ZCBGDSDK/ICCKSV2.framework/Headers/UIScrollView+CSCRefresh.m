//  代码地址: https://github.com/CoderCSCLee/CSCRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  UIScrollView+CSCRefresh.m
//  CSCRefreshExample
//
//  Created by CSC Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "UIScrollView+CSCRefresh.h"
#import "CSCRefreshHeader.h"
#import "CSCRefreshFooter.h"
#import <objc/runtime.h>

@implementation UIScrollView (CSCRefresh)

#pragma mark - header
static const char CSCRefreshHeaderKey = '\0';
- (void)setMj_header:(CSCRefreshHeader *)mj_header
{
    if (mj_header != self.mj_header) {
        // 删除旧的，添加新的
        [self.mj_header removeFromSuperview];
        [self insertSubview:mj_header atIndex:0];
        
        // 存储新的
        objc_setAssociatedObject(self, &CSCRefreshHeaderKey,
                                 mj_header, OBJC_ASSOCIATION_RETAIN);
    }
}

- (CSCRefreshHeader *)mj_header
{
    return objc_getAssociatedObject(self, &CSCRefreshHeaderKey);
}

#pragma mark - footer
static const char CSCRefreshFooterKey = '\0';
- (void)setMj_footer:(CSCRefreshFooter *)mj_footer
{
    if (mj_footer != self.mj_footer) {
        // 删除旧的，添加新的
        [self.mj_footer removeFromSuperview];
        [self insertSubview:mj_footer atIndex:0];
        
        // 存储新的
        objc_setAssociatedObject(self, &CSCRefreshFooterKey,
                                 mj_footer, OBJC_ASSOCIATION_RETAIN);
    }
}

- (CSCRefreshFooter *)mj_footer
{
    return objc_getAssociatedObject(self, &CSCRefreshFooterKey);
}

#pragma mark - 过期
- (void)setFooter:(CSCRefreshFooter *)footer
{
    self.mj_footer = footer;
}

- (CSCRefreshFooter *)footer
{
    return self.mj_footer;
}

- (void)setHeader:(CSCRefreshHeader *)header
{
    self.mj_header = header;
}

- (CSCRefreshHeader *)header
{
    return self.mj_header;
}

#pragma mark - other
- (NSInteger)mj_totalDataCount
{
    NSInteger totalCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;

        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;

        for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}

@end

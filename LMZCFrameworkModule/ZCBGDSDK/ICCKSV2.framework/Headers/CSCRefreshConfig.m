//
//  CSCRefreshConfig.m
//
//  Created by Frank on 2018/11/27.
//  Copyright © 2018 小码哥. All rights reserved.
//

#import "CSCRefreshConfig.h"

@implementation CSCRefreshConfig

static CSCRefreshConfig *mj_RefreshConfig = nil;

+ (instancetype)defaultConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mj_RefreshConfig = [[self alloc] init];
    });
    return mj_RefreshConfig;
}



@end

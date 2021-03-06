//
//  NSBundle+CSCRefresh.h
//  CSCRefreshExample
//
//  Created by CSC Lee on 16/6/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (CSCRefresh)
+ (instancetype)mj_refreshBundle;
+ (UIImage *)mj_arrowImage;
+ (NSString *)mj_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)mj_localizedStringForKey:(NSString *)key;
@end

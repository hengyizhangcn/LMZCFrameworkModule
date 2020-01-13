//
//  CSCUserTemp.h
//  CSCFramework
//
//  Created by zcsmart on 2018/7/11.
//  Copyright © 2018年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSCUserTemp : NSObject

+ (instancetype)sharedInstance;

- (SEObject *)getUserSE;

@end

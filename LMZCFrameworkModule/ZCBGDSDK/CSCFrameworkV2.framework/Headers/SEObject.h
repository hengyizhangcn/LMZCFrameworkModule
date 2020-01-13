//
//  SEObject.h
//  CSCFramework
//
//  Created by zcsmart on 2018/8/14.
//  Copyright © 2018年 zcsmart. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Cks2Controller;

@interface SEObject : NSObject
@property (nonatomic, assign) void *ctx;
@property (nonatomic, strong) Cks2Controller *control;
@property (nonatomic, copy) NSString *domainName;
@property (nonatomic, copy) NSString *ccksId;
@property (nonatomic, strong) NSError *error;
@end


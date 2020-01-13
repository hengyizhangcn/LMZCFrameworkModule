//
//  NSArray+CSCMASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+CSCMASAdditions.h"

#ifdef CSCMAS_SHORTHAND

/**
 *	Shorthand array additions without the 'mas_' prefixes,
 *  only enabled if CSCMAS_SHORTHAND is defined
 */
@interface NSArray (CSCMASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(CSCMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(CSCMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(CSCMASConstraintMaker *make))block;

@end

@implementation NSArray (CSCMASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(CSCMASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(CSCMASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(CSCMASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif

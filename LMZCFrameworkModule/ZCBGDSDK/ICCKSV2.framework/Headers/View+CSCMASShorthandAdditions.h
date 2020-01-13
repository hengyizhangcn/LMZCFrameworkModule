//
//  UIView+CSCMASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+CSCMASAdditions.h"

#ifdef CSCMAS_SHORTHAND

/**
 *	Shorthand view additions without the 'mas_' prefixes,
 *  only enabled if CSCMAS_SHORTHAND is defined
 */
@interface CSCMAS_VIEW (CSCMASShorthandAdditions)

@property (nonatomic, strong, readonly) CSCMASViewAttribute *left;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *top;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *right;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *bottom;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *leading;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *trailing;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *width;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *height;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *centerX;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *centerY;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *baseline;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) CSCMASViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) CSCMASViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *topMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) CSCMASViewAttribute *safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CSCMASViewAttribute *safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CSCMASViewAttribute *safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CSCMASViewAttribute *safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

- (NSArray *)makeConstraints:(void(^)(CSCMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(CSCMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(CSCMASConstraintMaker *make))block;

@end

#define CSCMAS_ATTR_FORWARD(attr)  \
- (CSCMASViewAttribute *)attr {    \
    return [self mas_##attr];   \
}

@implementation CSCMAS_VIEW (CSCMASShorthandAdditions)

CSCMAS_ATTR_FORWARD(top);
CSCMAS_ATTR_FORWARD(left);
CSCMAS_ATTR_FORWARD(bottom);
CSCMAS_ATTR_FORWARD(right);
CSCMAS_ATTR_FORWARD(leading);
CSCMAS_ATTR_FORWARD(trailing);
CSCMAS_ATTR_FORWARD(width);
CSCMAS_ATTR_FORWARD(height);
CSCMAS_ATTR_FORWARD(centerX);
CSCMAS_ATTR_FORWARD(centerY);
CSCMAS_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

CSCMAS_ATTR_FORWARD(firstBaseline);
CSCMAS_ATTR_FORWARD(lastBaseline);

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

CSCMAS_ATTR_FORWARD(leftMargin);
CSCMAS_ATTR_FORWARD(rightMargin);
CSCMAS_ATTR_FORWARD(topMargin);
CSCMAS_ATTR_FORWARD(bottomMargin);
CSCMAS_ATTR_FORWARD(leadingMargin);
CSCMAS_ATTR_FORWARD(trailingMargin);
CSCMAS_ATTR_FORWARD(centerXWithinMargins);
CSCMAS_ATTR_FORWARD(centerYWithinMargins);

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

CSCMAS_ATTR_FORWARD(safeAreaLayoutGuideTop);
CSCMAS_ATTR_FORWARD(safeAreaLayoutGuideBottom);
CSCMAS_ATTR_FORWARD(safeAreaLayoutGuideLeft);
CSCMAS_ATTR_FORWARD(safeAreaLayoutGuideRight);

#endif

- (CSCMASViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self mas_attribute];
}

- (NSArray *)makeConstraints:(void(NS_NOESCAPE ^)(CSCMASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(NS_NOESCAPE ^)(CSCMASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(NS_NOESCAPE ^)(CSCMASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif

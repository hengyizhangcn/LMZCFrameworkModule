//
//  UIView+CSCMASAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+CSCMASAdditions.h"
#import <objc/runtime.h>

@implementation CSCMAS_VIEW (CSCMASAdditions)

- (NSArray *)mas_makeConstraints:(void(^)(CSCMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CSCMASConstraintMaker *constraintMaker = [[CSCMASConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_updateConstraints:(void(^)(CSCMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CSCMASConstraintMaker *constraintMaker = [[CSCMASConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_remakeConstraints:(void(^)(CSCMASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CSCMASConstraintMaker *constraintMaker = [[CSCMASConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (CSCMASViewAttribute *)mas_left {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (CSCMASViewAttribute *)mas_top {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (CSCMASViewAttribute *)mas_right {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (CSCMASViewAttribute *)mas_bottom {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (CSCMASViewAttribute *)mas_leading {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (CSCMASViewAttribute *)mas_trailing {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (CSCMASViewAttribute *)mas_width {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (CSCMASViewAttribute *)mas_height {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (CSCMASViewAttribute *)mas_centerX {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (CSCMASViewAttribute *)mas_centerY {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (CSCMASViewAttribute *)mas_baseline {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (CSCMASViewAttribute *(^)(NSLayoutAttribute))mas_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (CSCMASViewAttribute *)mas_firstBaseline {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (CSCMASViewAttribute *)mas_lastBaseline {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (CSCMASViewAttribute *)mas_leftMargin {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (CSCMASViewAttribute *)mas_rightMargin {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (CSCMASViewAttribute *)mas_topMargin {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (CSCMASViewAttribute *)mas_bottomMargin {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (CSCMASViewAttribute *)mas_leadingMargin {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (CSCMASViewAttribute *)mas_trailingMargin {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (CSCMASViewAttribute *)mas_centerXWithinMargins {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (CSCMASViewAttribute *)mas_centerYWithinMargins {
    return [[CSCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

- (CSCMASViewAttribute *)mas_safeAreaLayoutGuide {
    return [[CSCMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (CSCMASViewAttribute *)mas_safeAreaLayoutGuideTop {
    return [[CSCMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (CSCMASViewAttribute *)mas_safeAreaLayoutGuideBottom {
    return [[CSCMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (CSCMASViewAttribute *)mas_safeAreaLayoutGuideLeft {
    return [[CSCMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
}
- (CSCMASViewAttribute *)mas_safeAreaLayoutGuideRight {
    return [[CSCMASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
}

#endif

#pragma mark - associated properties

- (id)mas_key {
    return objc_getAssociatedObject(self, @selector(mas_key));
}

- (void)setMas_key:(id)key {
    objc_setAssociatedObject(self, @selector(mas_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)mas_closestCommonSuperview:(CSCMAS_VIEW *)view {
    CSCMAS_VIEW *closestCommonSuperview = nil;

    CSCMAS_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        CSCMAS_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end

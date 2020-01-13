//
//  CSCMASConstraintMaker.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CSCMASConstraintMaker.h"
#import "CSCMASViewConstraint.h"
#import "CSCMASCompositeConstraint.h"
#import "CSCMASConstraint+Private.h"
#import "CSCMASViewAttribute.h"
#import "View+CSCMASAdditions.h"

@interface CSCMASConstraintMaker () <CSCMASConstraintDelegate>

@property (nonatomic, weak) CSCMAS_VIEW *view;
@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation CSCMASConstraintMaker

- (id)initWithView:(CSCMAS_VIEW *)view {
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    self.constraints = NSMutableArray.new;
    
    return self;
}

- (NSArray *)install {
    if (self.removeExisting) {
        NSArray *installedConstraints = [CSCMASViewConstraint installedConstraintsForView:self.view];
        for (CSCMASConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (CSCMASConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}

#pragma mark - CSCMASConstraintDelegate

- (void)constraint:(CSCMASConstraint *)constraint shouldBeReplacedWithConstraint:(CSCMASConstraint *)replacementConstraint {
    NSUInteger index = [self.constraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.constraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (CSCMASConstraint *)constraint:(CSCMASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    CSCMASViewAttribute *viewAttribute = [[CSCMASViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    CSCMASViewConstraint *newConstraint = [[CSCMASViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    if ([constraint isKindOfClass:CSCMASViewConstraint.class]) {
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        CSCMASCompositeConstraint *compositeConstraint = [[CSCMASCompositeConstraint alloc] initWithChildren:children];
        compositeConstraint.delegate = self;
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        return compositeConstraint;
    }
    if (!constraint) {
        newConstraint.delegate = self;
        [self.constraints addObject:newConstraint];
    }
    return newConstraint;
}

- (CSCMASConstraint *)addConstraintWithAttributes:(CSCMASAttribute)attrs {
    __unused CSCMASAttribute anyAttribute = (CSCMASAttributeLeft | CSCMASAttributeRight | CSCMASAttributeTop | CSCMASAttributeBottom | CSCMASAttributeLeading
                                          | CSCMASAttributeTrailing | CSCMASAttributeWidth | CSCMASAttributeHeight | CSCMASAttributeCenterX
                                          | CSCMASAttributeCenterY | CSCMASAttributeBaseline
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
                                          | CSCMASAttributeFirstBaseline | CSCMASAttributeLastBaseline
#endif
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
                                          | CSCMASAttributeLeftMargin | CSCMASAttributeRightMargin | CSCMASAttributeTopMargin | CSCMASAttributeBottomMargin
                                          | CSCMASAttributeLeadingMargin | CSCMASAttributeTrailingMargin | CSCMASAttributeCenterXWithinMargins
                                          | CSCMASAttributeCenterYWithinMargins
#endif
                                          );
    
    NSAssert((attrs & anyAttribute) != 0, @"You didn't pass any attribute to make.attributes(...)");
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    if (attrs & CSCMASAttributeLeft) [attributes addObject:self.view.mas_left];
    if (attrs & CSCMASAttributeRight) [attributes addObject:self.view.mas_right];
    if (attrs & CSCMASAttributeTop) [attributes addObject:self.view.mas_top];
    if (attrs & CSCMASAttributeBottom) [attributes addObject:self.view.mas_bottom];
    if (attrs & CSCMASAttributeLeading) [attributes addObject:self.view.mas_leading];
    if (attrs & CSCMASAttributeTrailing) [attributes addObject:self.view.mas_trailing];
    if (attrs & CSCMASAttributeWidth) [attributes addObject:self.view.mas_width];
    if (attrs & CSCMASAttributeHeight) [attributes addObject:self.view.mas_height];
    if (attrs & CSCMASAttributeCenterX) [attributes addObject:self.view.mas_centerX];
    if (attrs & CSCMASAttributeCenterY) [attributes addObject:self.view.mas_centerY];
    if (attrs & CSCMASAttributeBaseline) [attributes addObject:self.view.mas_baseline];
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    if (attrs & CSCMASAttributeFirstBaseline) [attributes addObject:self.view.mas_firstBaseline];
    if (attrs & CSCMASAttributeLastBaseline) [attributes addObject:self.view.mas_lastBaseline];
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    if (attrs & CSCMASAttributeLeftMargin) [attributes addObject:self.view.mas_leftMargin];
    if (attrs & CSCMASAttributeRightMargin) [attributes addObject:self.view.mas_rightMargin];
    if (attrs & CSCMASAttributeTopMargin) [attributes addObject:self.view.mas_topMargin];
    if (attrs & CSCMASAttributeBottomMargin) [attributes addObject:self.view.mas_bottomMargin];
    if (attrs & CSCMASAttributeLeadingMargin) [attributes addObject:self.view.mas_leadingMargin];
    if (attrs & CSCMASAttributeTrailingMargin) [attributes addObject:self.view.mas_trailingMargin];
    if (attrs & CSCMASAttributeCenterXWithinMargins) [attributes addObject:self.view.mas_centerXWithinMargins];
    if (attrs & CSCMASAttributeCenterYWithinMargins) [attributes addObject:self.view.mas_centerYWithinMargins];
    
#endif
    
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (CSCMASViewAttribute *a in attributes) {
        [children addObject:[[CSCMASViewConstraint alloc] initWithFirstViewAttribute:a]];
    }
    
    CSCMASCompositeConstraint *constraint = [[CSCMASCompositeConstraint alloc] initWithChildren:children];
    constraint.delegate = self;
    [self.constraints addObject:constraint];
    return constraint;
}

#pragma mark - standard Attributes

- (CSCMASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
}

- (CSCMASConstraint *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (CSCMASConstraint *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (CSCMASConstraint *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (CSCMASConstraint *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (CSCMASConstraint *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (CSCMASConstraint *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (CSCMASConstraint *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (CSCMASConstraint *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (CSCMASConstraint *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (CSCMASConstraint *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (CSCMASConstraint *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

- (CSCMASConstraint *(^)(CSCMASAttribute))attributes {
    return ^(CSCMASAttribute attrs){
        return [self addConstraintWithAttributes:attrs];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (CSCMASConstraint *)firstBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeFirstBaseline];
}

- (CSCMASConstraint *)lastBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif


#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (CSCMASConstraint *)leftMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeftMargin];
}

- (CSCMASConstraint *)rightMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRightMargin];
}

- (CSCMASConstraint *)topMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTopMargin];
}

- (CSCMASConstraint *)bottomMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottomMargin];
}

- (CSCMASConstraint *)leadingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (CSCMASConstraint *)trailingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (CSCMASConstraint *)centerXWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (CSCMASConstraint *)centerYWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif


#pragma mark - composite Attributes

- (CSCMASConstraint *)edges {
    return [self addConstraintWithAttributes:CSCMASAttributeTop | CSCMASAttributeLeft | CSCMASAttributeRight | CSCMASAttributeBottom];
}

- (CSCMASConstraint *)size {
    return [self addConstraintWithAttributes:CSCMASAttributeWidth | CSCMASAttributeHeight];
}

- (CSCMASConstraint *)center {
    return [self addConstraintWithAttributes:CSCMASAttributeCenterX | CSCMASAttributeCenterY];
}

#pragma mark - grouping

- (CSCMASConstraint *(^)(dispatch_block_t group))group {
    return ^id(dispatch_block_t group) {
        NSInteger previousCount = self.constraints.count;
        group();

        NSArray *children = [self.constraints subarrayWithRange:NSMakeRange(previousCount, self.constraints.count - previousCount)];
        CSCMASCompositeConstraint *constraint = [[CSCMASCompositeConstraint alloc] initWithChildren:children];
        constraint.delegate = self;
        return constraint;
    };
}

@end

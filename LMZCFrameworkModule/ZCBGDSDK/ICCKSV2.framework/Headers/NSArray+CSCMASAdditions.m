//
//  NSArray+CSCMASAdditions.m
//  
//
//  Created by Daniel Hammond on 11/26/13.
//
//

#import "NSArray+CSCMASAdditions.h"
#import "View+CSCMASAdditions.h"

@implementation NSArray (CSCMASAdditions)

- (NSArray *)mas_makeConstraints:(void(^)(CSCMASConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (CSCMAS_VIEW *view in self) {
        NSAssert([view isKindOfClass:[CSCMAS_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view mas_makeConstraints:block]];
    }
    return constraints;
}

- (NSArray *)mas_updateConstraints:(void(^)(CSCMASConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (CSCMAS_VIEW *view in self) {
        NSAssert([view isKindOfClass:[CSCMAS_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view mas_updateConstraints:block]];
    }
    return constraints;
}

- (NSArray *)mas_remakeConstraints:(void(^)(CSCMASConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (CSCMAS_VIEW *view in self) {
        NSAssert([view isKindOfClass:[CSCMAS_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view mas_remakeConstraints:block]];
    }
    return constraints;
}

- (void)mas_distributeViewsAlongAxis:(CSCMASAxisType)axisType withFixedSpacing:(CGFloat)fixedSpacing leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    
    CSCMAS_VIEW *tempSuperView = [self mas_commonSuperviewOfViews];
    if (axisType == CSCMASAxisTypeHorizontal) {
        CSCMAS_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            CSCMAS_VIEW *v = self[i];
            [v mas_makeConstraints:^(CSCMASConstraintMaker *make) {
                if (prev) {
                    make.width.equalTo(prev);
                    make.left.equalTo(prev.mas_right).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                }
                else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
    else {
        CSCMAS_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            CSCMAS_VIEW *v = self[i];
            [v mas_makeConstraints:^(CSCMASConstraintMaker *make) {
                if (prev) {
                    make.height.equalTo(prev);
                    make.top.equalTo(prev.mas_bottom).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }                    
                }
                else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
}

- (void)mas_distributeViewsAlongAxis:(CSCMASAxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    
    CSCMAS_VIEW *tempSuperView = [self mas_commonSuperviewOfViews];
    if (axisType == CSCMASAxisTypeHorizontal) {
        CSCMAS_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            CSCMAS_VIEW *v = self[i];
            [v mas_makeConstraints:^(CSCMASConstraintMaker *make) {
                make.width.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        make.right.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
    else {
        CSCMAS_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            CSCMAS_VIEW *v = self[i];
            [v mas_makeConstraints:^(CSCMASConstraintMaker *make) {
                make.height.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        make.bottom.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
}

- (CSCMAS_VIEW *)mas_commonSuperviewOfViews
{
    CSCMAS_VIEW *commonSuperview = nil;
    CSCMAS_VIEW *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[CSCMAS_VIEW class]]) {
            CSCMAS_VIEW *view = (CSCMAS_VIEW *)object;
            if (previousView) {
                commonSuperview = [view mas_closestCommonSuperview:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}

@end

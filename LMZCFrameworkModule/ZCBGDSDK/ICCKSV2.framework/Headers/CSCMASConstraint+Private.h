//
//  CSCMASConstraint+Private.h
//  Masonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "CSCMASConstraint.h"

@protocol CSCMASConstraintDelegate;


@interface CSCMASConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually CSCMASConstraintMaker but could be a parent CSCMASConstraint
 */
@property (nonatomic, weak) id<CSCMASConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with CSCMASEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end


@interface CSCMASConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    CSCMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (CSCMASConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (CSCMASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end


@protocol CSCMASConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A CSCMASViewConstraint may turn into a CSCMASCompositeConstraint when an array is passed to one of the equality blocks
 */
- (void)constraint:(CSCMASConstraint *)constraint shouldBeReplacedWithConstraint:(CSCMASConstraint *)replacementConstraint;

- (CSCMASConstraint *)constraint:(CSCMASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end

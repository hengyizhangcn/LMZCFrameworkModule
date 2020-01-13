//
//  CSCMASViewConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CSCMASViewAttribute.h"
#import "CSCMASConstraint.h"
#import "CSCMASLayoutConstraint.h"
#import "CSCMASUtilities.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface CSCMASViewConstraint : CSCMASConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) CSCMASViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) CSCMASViewAttribute *secondViewAttribute;

/**
 *	initialises the CSCMASViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.mas_left, view.mas_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(CSCMASViewAttribute *)firstViewAttribute;

/**
 *  Returns all CSCMASViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of CSCMASViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(CSCMAS_VIEW *)view;

@end

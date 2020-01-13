//
//  CSCMASCompositeConstraint.h
//  CSCMASonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CSCMASConstraint.h"
#import "CSCMASUtilities.h"

/**
 *	A group of CSCMASConstraint objects
 */
@interface CSCMASCompositeConstraint : CSCMASConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@param	children	child CSCMASConstraints
 *
 *	@return	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end

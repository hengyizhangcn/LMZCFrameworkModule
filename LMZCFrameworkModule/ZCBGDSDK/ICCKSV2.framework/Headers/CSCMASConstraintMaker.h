//
//  CSCMASConstraintMaker.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CSCMASConstraint.h"
#import "CSCMASUtilities.h"

typedef NS_OPTIONS(NSInteger, CSCMASAttribute) {
    CSCMASAttributeLeft = 1 << NSLayoutAttributeLeft,
    CSCMASAttributeRight = 1 << NSLayoutAttributeRight,
    CSCMASAttributeTop = 1 << NSLayoutAttributeTop,
    CSCMASAttributeBottom = 1 << NSLayoutAttributeBottom,
    CSCMASAttributeLeading = 1 << NSLayoutAttributeLeading,
    CSCMASAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    CSCMASAttributeWidth = 1 << NSLayoutAttributeWidth,
    CSCMASAttributeHeight = 1 << NSLayoutAttributeHeight,
    CSCMASAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    CSCMASAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    CSCMASAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    CSCMASAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    CSCMASAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    CSCMASAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    CSCMASAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    CSCMASAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    CSCMASAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    CSCMASAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    CSCMASAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    CSCMASAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    CSCMASAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating CSCMASConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface CSCMASConstraintMaker : NSObject

/**
 *	The following properties return a new CSCMASViewConstraint
 *  with the first item set to the makers associated view and the appropriate CSCMASViewAttribute
 */
@property (nonatomic, strong, readonly) CSCMASConstraint *left;
@property (nonatomic, strong, readonly) CSCMASConstraint *top;
@property (nonatomic, strong, readonly) CSCMASConstraint *right;
@property (nonatomic, strong, readonly) CSCMASConstraint *bottom;
@property (nonatomic, strong, readonly) CSCMASConstraint *leading;
@property (nonatomic, strong, readonly) CSCMASConstraint *trailing;
@property (nonatomic, strong, readonly) CSCMASConstraint *width;
@property (nonatomic, strong, readonly) CSCMASConstraint *height;
@property (nonatomic, strong, readonly) CSCMASConstraint *centerX;
@property (nonatomic, strong, readonly) CSCMASConstraint *centerY;
@property (nonatomic, strong, readonly) CSCMASConstraint *baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) CSCMASConstraint *firstBaseline;
@property (nonatomic, strong, readonly) CSCMASConstraint *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) CSCMASConstraint *leftMargin;
@property (nonatomic, strong, readonly) CSCMASConstraint *rightMargin;
@property (nonatomic, strong, readonly) CSCMASConstraint *topMargin;
@property (nonatomic, strong, readonly) CSCMASConstraint *bottomMargin;
@property (nonatomic, strong, readonly) CSCMASConstraint *leadingMargin;
@property (nonatomic, strong, readonly) CSCMASConstraint *trailingMargin;
@property (nonatomic, strong, readonly) CSCMASConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) CSCMASConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new CSCMASCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  CSCMASAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) CSCMASConstraint *(^attributes)(CSCMASAttribute attrs);

/**
 *	Creates a CSCMASCompositeConstraint with type CSCMASCompositeConstraintTypeEdges
 *  which generates the appropriate CSCMASViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) CSCMASConstraint *edges;

/**
 *	Creates a CSCMASCompositeConstraint with type CSCMASCompositeConstraintTypeSize
 *  which generates the appropriate CSCMASViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) CSCMASConstraint *size;

/**
 *	Creates a CSCMASCompositeConstraint with type CSCMASCompositeConstraintTypeCenter
 *  which generates the appropriate CSCMASViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) CSCMASConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any CSCMASConstraint are created with this view as the first item
 *
 *	@return	a new CSCMASConstraintMaker
 */
- (id)initWithView:(CSCMAS_VIEW *)view;

/**
 *	Calls install method on any CSCMASConstraints which have been created by this maker
 *
 *	@return	an array of all the installed CSCMASConstraints
 */
- (NSArray *)install;

- (CSCMASConstraint * (^)(dispatch_block_t))group;

@end

//
//  UIView+CSCMASAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CSCMASUtilities.h"
#import "CSCMASConstraintMaker.h"
#import "CSCMASViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating CSCMASViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface CSCMAS_VIEW (CSCMASAdditions)

/**
 *	following properties return a new CSCMASViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_left;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_top;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_right;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_bottom;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_leading;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_trailing;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_width;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_height;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_centerX;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_centerY;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_baseline;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *(^mas_attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_firstBaseline;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_leftMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_rightMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_topMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_bottomMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_leadingMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_trailingMargin;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_centerXWithinMargins;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id mas_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)mas_closestCommonSuperview:(CSCMAS_VIEW *)view;

/**
 *  Creates a CSCMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created CSCMASConstraints
 */
- (NSArray *)mas_makeConstraints:(void(NS_NOESCAPE ^)(CSCMASConstraintMaker *make))block;

/**
 *  Creates a CSCMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated CSCMASConstraints
 */
- (NSArray *)mas_updateConstraints:(void(NS_NOESCAPE ^)(CSCMASConstraintMaker *make))block;

/**
 *  Creates a CSCMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated CSCMASConstraints
 */
- (NSArray *)mas_remakeConstraints:(void(NS_NOESCAPE ^)(CSCMASConstraintMaker *make))block;

@end

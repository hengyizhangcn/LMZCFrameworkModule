//
//  UIViewController+CSCMASAdditions.h
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "CSCMASUtilities.h"
#import "CSCMASConstraintMaker.h"
#import "CSCMASViewAttribute.h"

#ifdef CSCMAS_VIEW_CONTROLLER

@interface CSCMAS_VIEW_CONTROLLER (CSCMASAdditions)

/**
 *	following properties return a new CSCMASViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_topLayoutGuide;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_bottomLayoutGuide;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_topLayoutGuideTop;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) CSCMASViewAttribute *mas_bottomLayoutGuideBottom;


@end

#endif

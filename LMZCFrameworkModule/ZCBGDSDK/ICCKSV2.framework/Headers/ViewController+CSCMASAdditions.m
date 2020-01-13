//
//  UIViewController+CSCMASAdditions.m
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ViewController+CSCMASAdditions.h"

#ifdef CSCMAS_VIEW_CONTROLLER

@implementation CSCMAS_VIEW_CONTROLLER (CSCMASAdditions)

- (CSCMASViewAttribute *)mas_topLayoutGuide {
    return [[CSCMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (CSCMASViewAttribute *)mas_topLayoutGuideTop {
    return [[CSCMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (CSCMASViewAttribute *)mas_topLayoutGuideBottom {
    return [[CSCMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (CSCMASViewAttribute *)mas_bottomLayoutGuide {
    return [[CSCMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (CSCMASViewAttribute *)mas_bottomLayoutGuideTop {
    return [[CSCMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (CSCMASViewAttribute *)mas_bottomLayoutGuideBottom {
    return [[CSCMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif

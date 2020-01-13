/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageTransition.h"

#if CSC_UIKIT || CSC_MAC

#if CSC_MAC
#import <QuartzCore/QuartzCore.h>
#endif

@implementation CSCWebImageTransition

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 0.5;
    }
    return self;
}

@end

@implementation CSCWebImageTransition (Conveniences)

+ (CSCWebImageTransition *)fadeTransition {
    CSCWebImageTransition *transition = [CSCWebImageTransition new];
#if CSC_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionFade;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (CSCWebImageTransition *)flipFromLeftTransition {
    CSCWebImageTransition *transition = [CSCWebImageTransition new];
#if CSC_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromLeft;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (CSCWebImageTransition *)flipFromRightTransition {
    CSCWebImageTransition *transition = [CSCWebImageTransition new];
#if CSC_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromRight;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (CSCWebImageTransition *)flipFromTopTransition {
    CSCWebImageTransition *transition = [CSCWebImageTransition new];
#if CSC_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromTop | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromTop;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (CSCWebImageTransition *)flipFromBottomTransition {
    CSCWebImageTransition *transition = [CSCWebImageTransition new];
#if CSC_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromBottom | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromBottom;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (CSCWebImageTransition *)curlUpTransition {
    CSCWebImageTransition *transition = [CSCWebImageTransition new];
#if CSC_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlUp | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromTop;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (CSCWebImageTransition *)curlDownTransition {
    CSCWebImageTransition *transition = [CSCWebImageTransition new];
#if CSC_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlDown | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromBottom;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

@end

#endif

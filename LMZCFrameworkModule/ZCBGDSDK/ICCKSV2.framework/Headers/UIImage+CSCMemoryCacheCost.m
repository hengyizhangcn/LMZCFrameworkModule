/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+CSCMemoryCacheCost.h"
#import "objc/runtime.h"
#import "CSCImage+Compatibility.h"

FOUNDATION_STATIC_INLINE NSUInteger CSCMemoryCacheCostForImage(UIImage *image) {
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        return 0;
    }
    NSUInteger bytesPerFrame = CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef);
    NSUInteger frameCount;
#if CSC_MAC
    frameCount = 1;
#elif CSC_UIKIT || CSC_WATCH
    frameCount = image.images.count > 0 ? image.images.count : 1;
#endif
    NSUInteger cost = bytesPerFrame * frameCount;
    return cost;
}

@implementation UIImage (MemoryCacheCost)

- (NSUInteger)sd_memoryCost {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sd_memoryCost));
    NSUInteger memoryCost;
    if (value != nil) {
        memoryCost = [value unsignedIntegerValue];
    } else {
        memoryCost = CSCMemoryCacheCostForImage(self);
    }
    return memoryCost;
}

- (void)setSd_memoryCost:(NSUInteger)sd_memoryCost {
    objc_setAssociatedObject(self, @selector(sd_memoryCost), @(sd_memoryCost), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

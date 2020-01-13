/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageCacheDefine.h"
#import "CSCImageCodersManager.h"
#import "CSCImageCoderHelper.h"
#import "CSCAnimatedImage.h"
#import "UIImage+CSCMetadata.h"
#import "CSCInternalMacros.h"

UIImage * _Nullable CSCImageCacheDecodeImageData(NSData * _Nonnull imageData, NSString * _Nonnull cacheKey, CSCWebImageOptions options, CSCWebImageContext * _Nullable context) {
    UIImage *image;
    BOOL decodeFirstFrame = CSC_OPTIONS_CONTAINS(options, CSCWebImageDecodeFirstFrameOnly);
    NSNumber *scaleValue = context[CSCWebImageContextImageScaleFactor];
    CGFloat scale = scaleValue.doubleValue >= 1 ? scaleValue.doubleValue : CSCImageScaleFactorForKey(cacheKey);
    CSCImageCoderOptions *coderOptions = @{CSCImageCoderDecodeFirstFrameOnly : @(decodeFirstFrame), CSCImageCoderDecodeScaleFactor : @(scale)};
    if (context) {
        CSCImageCoderMutableOptions *mutableCoderOptions = [coderOptions mutableCopy];
        [mutableCoderOptions setValue:context forKey:CSCImageCoderWebImageContext];
        coderOptions = [mutableCoderOptions copy];
    }
    
    if (!decodeFirstFrame) {
        Class animatedImageClass = context[CSCWebImageContextAnimatedImageClass];
        // check whether we should use `CSCAnimatedImage`
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(CSCAnimatedImage)]) {
            image = [[animatedImageClass alloc] initWithData:imageData scale:scale options:coderOptions];
            if (image) {
                // Preload frames if supported
                if (options & CSCWebImagePreloadAllFrames && [image respondsToSelector:@selector(preloadAllFrames)]) {
                    [((id<CSCAnimatedImage>)image) preloadAllFrames];
                }
            } else {
                // Check image class matching
                if (options & CSCWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        image = [[CSCImageCodersManager sharedManager] decodedImageWithData:imageData options:coderOptions];
    }
    if (image) {
        BOOL shouldDecode = !CSC_OPTIONS_CONTAINS(options, CSCWebImageAvoidDecodeImage);
        if ([image.class conformsToProtocol:@protocol(CSCAnimatedImage)]) {
            // `CSCAnimatedImage` do not decode
            shouldDecode = NO;
        } else if (image.sd_isAnimated) {
            // animated image do not decode
            shouldDecode = NO;
        }
        if (shouldDecode) {
            BOOL shouldScaleDown = CSC_OPTIONS_CONTAINS(options, CSCWebImageScaleDownLargeImages);
            if (shouldScaleDown) {
                image = [CSCImageCoderHelper decodedAndScaledDownImageWithImage:image limitBytes:0];
            } else {
                image = [CSCImageCoderHelper decodedImageWithImage:image];
            }
        }
    }
    
    return image;
}

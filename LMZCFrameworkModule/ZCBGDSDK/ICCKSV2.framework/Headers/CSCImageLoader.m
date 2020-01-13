/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageLoader.h"
#import "CSCWebImageCacheKeyFilter.h"
#import "CSCImageCodersManager.h"
#import "CSCImageCoderHelper.h"
#import "CSCAnimatedImage.h"
#import "UIImage+CSCMetadata.h"
#import "CSCInternalMacros.h"
#import "objc/runtime.h"

static void * CSCImageLoaderProgressiveCoderKey = &CSCImageLoaderProgressiveCoderKey;

UIImage * _Nullable CSCImageLoaderDecodeImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, CSCWebImageOptions options, CSCWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    
    UIImage *image;
    id<CSCWebImageCacheKeyFilter> cacheKeyFilter = context[CSCWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
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
        // check whether we should use `CSCAnimatedImage`
        Class animatedImageClass = context[CSCWebImageContextAnimatedImageClass];
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

UIImage * _Nullable CSCImageLoaderDecodeProgressiveImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, BOOL finished,  id<CSCWebImageOperation> _Nonnull operation, CSCWebImageOptions options, CSCWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    NSCParameterAssert(operation);
    
    UIImage *image;
    id<CSCWebImageCacheKeyFilter> cacheKeyFilter = context[CSCWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
    BOOL decodeFirstFrame = CSC_OPTIONS_CONTAINS(options, CSCWebImageDecodeFirstFrameOnly);
    NSNumber *scaleValue = context[CSCWebImageContextImageScaleFactor];
    CGFloat scale = scaleValue.doubleValue >= 1 ? scaleValue.doubleValue : CSCImageScaleFactorForKey(cacheKey);
    CSCImageCoderOptions *coderOptions = @{CSCImageCoderDecodeFirstFrameOnly : @(decodeFirstFrame), CSCImageCoderDecodeScaleFactor : @(scale)};
    if (context) {
        CSCImageCoderMutableOptions *mutableCoderOptions = [coderOptions mutableCopy];
        [mutableCoderOptions setValue:context forKey:CSCImageCoderWebImageContext];
        coderOptions = [mutableCoderOptions copy];
    }
    
    id<CSCProgressiveImageCoder> progressiveCoder = objc_getAssociatedObject(operation, CSCImageLoaderProgressiveCoderKey);
    if (!progressiveCoder) {
        // We need to create a new instance for progressive decoding to avoid conflicts
        for (id<CSCImageCoder>coder in [CSCImageCodersManager sharedManager].coders.reverseObjectEnumerator) {
            if ([coder conformsToProtocol:@protocol(CSCProgressiveImageCoder)] &&
                [((id<CSCProgressiveImageCoder>)coder) canIncrementalDecodeFromData:imageData]) {
                progressiveCoder = [[[coder class] alloc] initIncrementalWithOptions:coderOptions];
                break;
            }
        }
        objc_setAssociatedObject(operation, CSCImageLoaderProgressiveCoderKey, progressiveCoder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // If we can't find any progressive coder, disable progressive download
    if (!progressiveCoder) {
        return nil;
    }
    
    [progressiveCoder updateIncrementalData:imageData finished:finished];
    if (!decodeFirstFrame) {
        // check whether we should use `CSCAnimatedImage`
        Class animatedImageClass = context[CSCWebImageContextAnimatedImageClass];
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(CSCAnimatedImage)] && [progressiveCoder conformsToProtocol:@protocol(CSCAnimatedImageCoder)]) {
            image = [[animatedImageClass alloc] initWithAnimatedCoder:(id<CSCAnimatedImageCoder>)progressiveCoder scale:scale];
            if (image) {
                // Progressive decoding does not preload frames
            } else {
                // Check image class matching
                if (options & CSCWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        image = [progressiveCoder incrementalDecodedImageWithOptions:coderOptions];
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
            image = [CSCImageCoderHelper decodedImageWithImage:image];
        }
        // mark the image as progressive (completionBlock one are not mark as progressive)
        image.sd_isIncremental = YES;
    }
    
    return image;
}

CSCWebImageContextOption const CSCWebImageContextLoaderCachedImage = @"loaderCachedImage";

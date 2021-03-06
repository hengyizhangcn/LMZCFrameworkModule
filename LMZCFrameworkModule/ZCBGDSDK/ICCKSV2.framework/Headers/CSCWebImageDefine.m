/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageDefine.h"
#import "UIImage+CSCMetadata.h"
#import "CSCImage+Compatibility.h"

#pragma mark - Image scale

static inline NSArray<NSNumber *> * _Nonnull CSCImageScaleFactors() {
    return @[@2, @3];
}

inline CGFloat CSCImageScaleFactorForKey(NSString * _Nullable key) {
    CGFloat scale = 1;
    if (!key) {
        return scale;
    }
    // Check if target OS support scale
#if CSC_WATCH
    if ([[WKInterfaceDevice currentDevice] respondsToSelector:@selector(screenScale)])
#elif CSC_UIKIT
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
#elif CSC_MAC
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)])
#endif
    {
        // a@2x.png -> 8
        if (key.length >= 8) {
            // Fast check
            BOOL isURL = [key hasPrefix:@"http://"] || [key hasPrefix:@"https://"];
            for (NSNumber *scaleFactor in CSCImageScaleFactors()) {
                // @2x. for file name and normal url
                NSString *fileScale = [NSString stringWithFormat:@"@%@x.", scaleFactor];
                if ([key containsString:fileScale]) {
                    scale = scaleFactor.doubleValue;
                    return scale;
                }
                if (isURL) {
                    // %402x. for url encode
                    NSString *urlScale = [NSString stringWithFormat:@"%%40%@x.", scaleFactor];
                    if ([key containsString:urlScale]) {
                        scale = scaleFactor.doubleValue;
                        return scale;
                    }
                }
            }
        }
    }
    return scale;
}

inline UIImage * _Nullable CSCScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    CGFloat scale = CSCImageScaleFactorForKey(key);
    return CSCScaledImageForScaleFactor(scale, image);
}

inline UIImage * _Nullable CSCScaledImageForScaleFactor(CGFloat scale, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    if (scale <= 1) {
        return image;
    }
    if (scale == image.scale) {
        return image;
    }
    UIImage *scaledImage;
    if (image.sd_isAnimated) {
        UIImage *animatedImage;
#if CSC_UIKIT || CSC_WATCH
        // `UIAnimatedImage` images share the same size and scale.
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            UIImage *tempScaledImage = [[UIImage alloc] initWithCGImage:tempImage.CGImage scale:scale orientation:tempImage.imageOrientation];
            [scaledImages addObject:tempScaledImage];
        }
        
        animatedImage = [UIImage animatedImageWithImages:scaledImages duration:image.duration];
        animatedImage.sd_imageLoopCount = image.sd_imageLoopCount;
#else
        // Animated GIF for `NSImage` need to grab `NSBitmapImageRep`;
        NSRect imageRect = NSMakeRect(0, 0, image.size.width, image.size.height);
        NSImageRep *imageRep = [image bestRepresentationForRect:imageRect context:nil hints:nil];
        NSBitmapImageRep *bitmapImageRep;
        if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
            bitmapImageRep = (NSBitmapImageRep *)imageRep;
        }
        if (bitmapImageRep) {
            NSSize size = NSMakeSize(image.size.width / scale, image.size.height / scale);
            animatedImage = [[NSImage alloc] initWithSize:size];
            bitmapImageRep.size = size;
            [animatedImage addRepresentation:bitmapImageRep];
        }
#endif
        scaledImage = animatedImage;
    } else {
#if CSC_UIKIT || CSC_WATCH
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
#else
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:kCGImagePropertyOrientationUp];
#endif
    }
    scaledImage.sd_isIncremental = image.sd_isIncremental;
    scaledImage.sd_imageFormat = image.sd_imageFormat;
    
    return scaledImage;
}

#pragma mark - Context option

CSCWebImageContextOption const CSCWebImageContextSetImageOperationKey = @"setImageOperationKey";
CSCWebImageContextOption const CSCWebImageContextCustomManager = @"customManager";
CSCWebImageContextOption const CSCWebImageContextImageTransformer = @"imageTransformer";
CSCWebImageContextOption const CSCWebImageContextImageScaleFactor = @"imageScaleFactor";
CSCWebImageContextOption const CSCWebImageContextStoreCacheType = @"storeCacheType";
CSCWebImageContextOption const CSCWebImageContextOriginalStoreCacheType = @"originalStoreCacheType";
CSCWebImageContextOption const CSCWebImageContextAnimatedImageClass = @"animatedImageClass";
CSCWebImageContextOption const CSCWebImageContextDownloadRequestModifier = @"downloadRequestModifier";
CSCWebImageContextOption const CSCWebImageContextCacheKeyFilter = @"cacheKeyFilter";
CSCWebImageContextOption const CSCWebImageContextCacheSerializer = @"cacheSerializer";

/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageGraphics.h"
#import "CSCImage+Compatibility.h"
#import "objc/runtime.h"

#if CSC_MAC
static void *kNSGraphicsContextScaleFactorKey;

static CGContextRef CSCCGContextCreateBitmapContext(CGSize size, BOOL opaque, CGFloat scale) {
    if (scale == 0) {
        // Match `UIGraphicsBeginImageContextWithOptions`, reset to the scale factor of the device’s main screen if scale is 0.
        scale = [NSScreen mainScreen].backingScaleFactor;
    }
    size_t width = ceil(size.width * scale);
    size_t height = ceil(size.height * scale);
    if (width < 1 || height < 1) return NULL;
    
    //pre-multiplied BGRA for non-opaque, BGRX for opaque, 8-bits per component, as Apple's doc
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGImageAlphaInfo alphaInfo = kCGBitmapByteOrder32Host | (opaque ? kCGImageAlphaNoneSkipFirst : kCGImageAlphaPremultipliedFirst);
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, kCGBitmapByteOrderDefault | alphaInfo);
    CGColorSpaceRelease(space);
    if (!context) {
        return NULL;
    }
    CGContextScaleCTM(context, scale, scale);
    
    return context;
}
#endif

CGContextRef CSCGraphicsGetCurrentContext(void) {
#if CSC_UIKIT || CSC_WATCH
    return UIGraphicsGetCurrentContext();
#else
    return NSGraphicsContext.currentContext.CGContext;
#endif
}

void CSCGraphicsBeginImageContext(CGSize size) {
#if CSC_UIKIT || CSC_WATCH
    UIGraphicsBeginImageContext(size);
#else
    CSCGraphicsBeginImageContextWithOptions(size, NO, 1.0);
#endif
}

void CSCGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale) {
#if CSC_UIKIT || CSC_WATCH
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
#else
    CGContextRef context = CSCCGContextCreateBitmapContext(size, opaque, scale);
    if (!context) {
        return;
    }
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
    objc_setAssociatedObject(graphicsContext, &kNSGraphicsContextScaleFactorKey, @(scale), OBJC_ASSOCIATION_RETAIN);
    CGContextRelease(context);
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext.currentContext = graphicsContext;
#endif
}

void CSCGraphicsEndImageContext(void) {
#if CSC_UIKIT || CSC_WATCH
    UIGraphicsEndImageContext();
#else
    [NSGraphicsContext restoreGraphicsState];
#endif
}

UIImage * CSCGraphicsGetImageFromCurrentImageContext(void) {
#if CSC_UIKIT || CSC_WATCH
    return UIGraphicsGetImageFromCurrentImageContext();
#else
    NSGraphicsContext *context = NSGraphicsContext.currentContext;
    CGContextRef contextRef = context.CGContext;
    if (!contextRef) {
        return nil;
    }
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    if (!imageRef) {
        return nil;
    }
    CGFloat scale = 0;
    NSNumber *scaleFactor = objc_getAssociatedObject(context, &kNSGraphicsContextScaleFactorKey);
    if ([scaleFactor isKindOfClass:[NSNumber class]]) {
        scale = scaleFactor.doubleValue;
    }
    if (!scale) {
        // reset to the scale factor of the device’s main screen if scale is 0.
        scale = [NSScreen mainScreen].backingScaleFactor;
    }
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef scale:scale orientation:kCGImagePropertyOrientationUp];
    CGImageRelease(imageRef);
    return image;
#endif
}

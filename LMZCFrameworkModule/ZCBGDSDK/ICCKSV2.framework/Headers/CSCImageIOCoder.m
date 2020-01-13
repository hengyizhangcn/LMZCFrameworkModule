/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageIOCoder.h"
#import "CSCImageCoderHelper.h"
#import "CSCImage+Compatibility.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+CSCMetadata.h"
#import "CSCImageHEICCoderInternal.h"

@implementation CSCImageIOCoder {
    size_t _width, _height;
    CGImagePropertyOrientation _orientation;
    CGImageSourceRef _imageSource;
    CGFloat _scale;
    BOOL _finished;
}

- (void)dealloc {
    if (_imageSource) {
        CFRelease(_imageSource);
        _imageSource = NULL;
    }
#if CSC_UIKIT
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    if (_imageSource) {
        CGImageSourceRemoveCacheAtIndex(_imageSource, 0);
    }
}

+ (instancetype)sharedCoder {
    static CSCImageIOCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[CSCImageIOCoder alloc] init];
    });
    return coder;
}

#pragma mark - Decode
- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData sd_imageFormatForImageData:data]) {
        case CSCImageFormatWebP:
            // Do not support WebP decoding
            return NO;
        case CSCImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [CSCImageHEICCoder canDecodeFromHEICFormat];
        case CSCImageFormatHEIF:
            // Check HEIF decoding compatibility
            return [CSCImageHEICCoder canDecodeFromHEIFFormat];
        default:
            return YES;
    }
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(nullable CSCImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    CGFloat scale = 1;
    NSNumber *scaleFactor = options[CSCImageCoderDecodeScaleFactor];
    if (scaleFactor != nil) {
        scale = MAX([scaleFactor doubleValue], 1) ;
    }
    
    UIImage *image = [[UIImage alloc] initWithData:data scale:scale];
    image.sd_imageFormat = [NSData sd_imageFormatForImageData:data];
    return image;
}

#pragma mark - Progressive Decode

- (BOOL)canIncrementalDecodeFromData:(NSData *)data {
    return [self canDecodeFromData:data];
}

- (instancetype)initIncrementalWithOptions:(nullable CSCImageCoderOptions *)options {
    self = [super init];
    if (self) {
        _imageSource = CGImageSourceCreateIncremental(NULL);
        CGFloat scale = 1;
        NSNumber *scaleFactor = options[CSCImageCoderDecodeScaleFactor];
        if (scaleFactor != nil) {
            scale = MAX([scaleFactor doubleValue], 1);
        }
        _scale = scale;
#if CSC_UIKIT
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    }
    return self;
}

- (void)updateIncrementalData:(NSData *)data finished:(BOOL)finished {
    if (_finished) {
        return;
    }
    _finished = finished;
    
    // The following code is from http://www.cocoaintheshell.com/2011/05/progressive-images-download-imageio/
    // Thanks to the author @Nyx0uf
    
    // Update the data source, we must pass ALL the data, not just the new bytes
    CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef)data, finished);
    
    if (_width + _height == 0) {
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL);
        if (properties) {
            NSInteger orientationValue = 1;
            CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_height);
            val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_width);
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (val) CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
            CFRelease(properties);
            
            // When we draw to Core Graphics, we lose orientation information,
            // which means the image below born of initWithCGIImage will be
            // oriented incorrectly sometimes. (Unlike the image born of initWithData
            // in didCompleteWithError.) So save it here and pass it on later.
            _orientation = (CGImagePropertyOrientation)orientationValue;
        }
    }
}

- (UIImage *)incrementalDecodedImageWithOptions:(CSCImageCoderOptions *)options {
    UIImage *image;
    
    if (_width + _height > 0) {
        // Create the image
        CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
        
        if (partialImageRef) {
            CGFloat scale = _scale;
            NSNumber *scaleFactor = options[CSCImageCoderDecodeScaleFactor];
            if (scaleFactor != nil) {
                scale = MAX([scaleFactor doubleValue], 1);
            }
#if CSC_UIKIT || CSC_WATCH
            UIImageOrientation imageOrientation = [CSCImageCoderHelper imageOrientationFromEXIFOrientation:_orientation];
            image = [[UIImage alloc] initWithCGImage:partialImageRef scale:scale orientation:imageOrientation];
#else
            image = [[UIImage alloc] initWithCGImage:partialImageRef scale:scale orientation:_orientation];
#endif
            CGImageRelease(partialImageRef);
            CFStringRef uttype = CGImageSourceGetType(_imageSource);
            image.sd_imageFormat = [NSData sd_imageFormatFromUTType:uttype];
        }
    }
    
    return image;
}

#pragma mark - Encode
- (BOOL)canEncodeToFormat:(CSCImageFormat)format {
    switch (format) {
        case CSCImageFormatWebP:
            // Do not support WebP encoding
            return NO;
        case CSCImageFormatHEIC:
            // Check HEIC encoding compatibility
            return [CSCImageHEICCoder canEncodeToHEICFormat];
        case CSCImageFormatHEIF:
            // Check HEIF encoding compatibility
            return [CSCImageHEICCoder canEncodeToHEIFFormat];
        default:
            return YES;
    }
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(CSCImageFormat)format options:(nullable CSCImageCoderOptions *)options {
    if (!image) {
        return nil;
    }
    
    if (format == CSCImageFormatUndefined) {
        BOOL hasAlpha = [CSCImageCoderHelper CGImageContainsAlpha:image.CGImage];
        if (hasAlpha) {
            format = CSCImageFormatPNG;
        } else {
            format = CSCImageFormatJPEG;
        }
    }
    
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef imageUTType = [NSData sd_UTTypeFromImageFormat:format];
    
    // Create an image destination.
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
    if (!imageDestination) {
        // Handle failure.
        return nil;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
#if CSC_UIKIT || CSC_WATCH
    CGImagePropertyOrientation exifOrientation = [CSCImageCoderHelper exifOrientationFromImageOrientation:image.imageOrientation];
#else
    CGImagePropertyOrientation exifOrientation = kCGImagePropertyOrientationUp;
#endif
    properties[(__bridge NSString *)kCGImagePropertyOrientation] = @(exifOrientation);
    double compressionQuality = 1;
    if (options[CSCImageCoderEncodeCompressionQuality]) {
        compressionQuality = [options[CSCImageCoderEncodeCompressionQuality] doubleValue];
    }
    properties[(__bridge NSString *)kCGImageDestinationLossyCompressionQuality] = @(compressionQuality);
    
    // Add your image to the destination.
    CGImageDestinationAddImage(imageDestination, image.CGImage, (__bridge CFDictionaryRef)properties);
    
    // Finalize the destination.
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        // Handle failure.
        imageData = nil;
    }
    
    CFRelease(imageDestination);
    
    return [imageData copy];
}

@end

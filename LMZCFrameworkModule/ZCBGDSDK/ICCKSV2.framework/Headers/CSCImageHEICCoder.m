/*
* This file is part of the CSCWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "CSCImageHEICCoder.h"
#import "CSCImageHEICCoderInternal.h"

// These constantce are available from iOS 13+ and Xcode 11. This raw value is used for toolchain and firmware compatiblitiy
static NSString * kCSCCGImagePropertyHEICCSCictionary = @"{HEICS}";
static NSString * kCSCCGImagePropertyHEICSLoopCount = @"LoopCount";
static NSString * kCSCCGImagePropertyHEICCSCelayTime = @"DelayTime";
static NSString * kCSCCGImagePropertyHEICSUnclampedDelayTime = @"UnclampedDelayTime";

@implementation CSCImageHEICCoder

+ (void)initialize {
#if __IPHONE_13_0 || __TVOS_13_0 || __MAC_10_15 || __WATCHOS_6_0
    // Xcode 11
    if (@available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *)) {
        // Use CSCK instead of raw value
        kCSCCGImagePropertyHEICCSCictionary = (__bridge NSString *)kCGImagePropertyHEICSDictionary;
        kCSCCGImagePropertyHEICSLoopCount = (__bridge NSString *)kCGImagePropertyHEICSLoopCount;
        kCSCCGImagePropertyHEICCSCelayTime = (__bridge NSString *)kCGImagePropertyHEICSDelayTime;
        kCSCCGImagePropertyHEICSUnclampedDelayTime = (__bridge NSString *)kCGImagePropertyHEICSUnclampedDelayTime;
    }
#endif
}

+ (instancetype)sharedCoder {
    static CSCImageHEICCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[CSCImageHEICCoder alloc] init];
    });
    return coder;
}

#pragma mark - CSCImageCoder

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData sd_imageFormatForImageData:data]) {
        case CSCImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [self.class canDecodeFromHEICFormat];
        case CSCImageFormatHEIF:
            // Check HEIF decoding compatibility
            return [self.class canDecodeFromHEIFFormat];
        default:
            return NO;
    }
}

- (BOOL)canIncrementalDecodeFromData:(NSData *)data {
    return [self canDecodeFromData:data];
}

- (BOOL)canEncodeToFormat:(CSCImageFormat)format {
    switch (format) {
        case CSCImageFormatHEIC:
            // Check HEIC encoding compatibility
            return [self.class canEncodeToHEICFormat];
        case CSCImageFormatHEIF:
            // Check HEIF encoding compatibility
            return [self.class canEncodeToHEIFFormat];
        default:
            return NO;
    }
}

#pragma mark - HEIF Format

+ (BOOL)canDecodeFromFormat:(CSCImageFormat)format {
    CFStringRef imageUTType = [NSData sd_UTTypeFromImageFormat:format];
    NSArray *imageUTTypes = (__bridge_transfer NSArray *)CGImageSourceCopyTypeIdentifiers();
    if ([imageUTTypes containsObject:(__bridge NSString *)(imageUTType)]) {
        return YES;
    }
    return NO;
}

+ (BOOL)canDecodeFromHEICFormat {
    static BOOL canDecode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        canDecode = [self canDecodeFromFormat:CSCImageFormatHEIC];
    });
    return canDecode;
}

+ (BOOL)canDecodeFromHEIFFormat {
    static BOOL canDecode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        canDecode = [self canDecodeFromFormat:CSCImageFormatHEIF];
    });
    return canDecode;
}

+ (BOOL)canEncodeToFormat:(CSCImageFormat)format {
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef imageUTType = [NSData sd_UTTypeFromImageFormat:format];
    
    // Create an image destination.
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
    if (!imageDestination) {
        // Can't encode to HEIC
        return NO;
    } else {
        // Can encode to HEIC
        CFRelease(imageDestination);
        return YES;
    }
}

+ (BOOL)canEncodeToHEICFormat {
    static BOOL canEncode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        canEncode = [self canEncodeToFormat:CSCImageFormatHEIC];
    });
    return canEncode;
}

+ (BOOL)canEncodeToHEIFFormat {
    static BOOL canEncode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        canEncode = [self canEncodeToFormat:CSCImageFormatHEIF];
    });
    return canEncode;
}

#pragma mark - Subclass Override

+ (CSCImageFormat)imageFormat {
    return CSCImageFormatHEIC;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kCSCUTTypeHEIC;
}

+ (NSString *)dictionaryProperty {
    return kCSCCGImagePropertyHEICCSCictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return kCSCCGImagePropertyHEICSUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return kCSCCGImagePropertyHEICCSCelayTime;
}

+ (NSString *)loopCountProperty {
    return kCSCCGImagePropertyHEICSLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 0;
}

@end

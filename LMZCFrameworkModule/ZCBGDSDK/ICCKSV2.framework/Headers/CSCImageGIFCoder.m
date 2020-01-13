/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageGIFCoder.h"
#if CSC_MAC
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif

@implementation CSCImageGIFCoder

+ (instancetype)sharedCoder {
    static CSCImageGIFCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[CSCImageGIFCoder alloc] init];
    });
    return coder;
}

#pragma mark - Subclass Override

+ (CSCImageFormat)imageFormat {
    return CSCImageFormatGIF;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kUTTypeGIF;
}

+ (NSString *)dictionaryProperty {
    return (__bridge NSString *)kCGImagePropertyGIFDictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return (__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return (__bridge NSString *)kCGImagePropertyGIFDelayTime;
}

+ (NSString *)loopCountProperty {
    return (__bridge NSString *)kCGImagePropertyGIFLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 1;
}

@end

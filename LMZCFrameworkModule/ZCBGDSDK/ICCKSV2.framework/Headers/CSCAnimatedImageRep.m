/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCAnimatedImageRep.h"

#if CSC_MAC

#import "CSCImageIOAnimatedCoderInternal.h"
#import "CSCImageGIFCoder.h"
#import "CSCImageAPNGCoder.h"
#import "CSCImageHEICCoder.h"
#import "CSCImageHEICCoderInternal.h"

@implementation CSCAnimatedImageRep {
    CGImageSourceRef _imageSource;
}

- (void)dealloc {
    if (_imageSource) {
        CFRelease(_imageSource);
        _imageSource = NULL;
    }
}

// `NSBitmapImageRep`'s `imageRepWithData:` is not designed initlizer
+ (instancetype)imageRepWithData:(NSData *)data {
    CSCAnimatedImageRep *imageRep = [[CSCAnimatedImageRep alloc] initWithData:data];
    return imageRep;
}

// We should override init method for `NSBitmapImageRep` to do initlize about animated image format
- (instancetype)initWithData:(NSData *)data {
    self = [super initWithData:data];
    if (self) {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
        if (!imageSource) {
            return self;
        }
        _imageSource = imageSource;
        NSUInteger frameCount = CGImageSourceGetCount(imageSource);
        if (frameCount <= 1) {
            return self;
        }
        CFStringRef type = CGImageSourceGetType(imageSource);
        if (!type) {
            return self;
        }
        if (CFStringCompare(type, kUTTypeGIF, 0) == kCFCompareEqualTo) {
            // GIF
            // Fix the `NSBitmapImageRep` GIF loop count calculation issue
            // Which will use 0 when there are no loop count information metadata in GIF data
            NSUInteger loopCount = [CSCImageGIFCoder imageLoopCountWithSource:imageSource];
            [self setProperty:NSImageLoopCount withValue:@(loopCount)];
        } else if (CFStringCompare(type, kUTTypePNG, 0) == kCFCompareEqualTo) {
            // APNG
            // Do initilize about frame count, current frame/duration and loop count
            [self setProperty:NSImageFrameCount withValue:@(frameCount)];
            [self setProperty:NSImageCurrentFrame withValue:@(0)];
            NSUInteger loopCount = [CSCImageAPNGCoder imageLoopCountWithSource:imageSource];
            [self setProperty:NSImageLoopCount withValue:@(loopCount)];
        } else if (CFStringCompare(type, kCSCUTTypeHEICS, 0) == kCFCompareEqualTo) {
            // HEIC
            // Do initilize about frame count, current frame/duration and loop count
            [self setProperty:NSImageFrameCount withValue:@(frameCount)];
            [self setProperty:NSImageCurrentFrame withValue:@(0)];
            NSUInteger loopCount = [CSCImageHEICCoder imageLoopCountWithSource:imageSource];
            [self setProperty:NSImageLoopCount withValue:@(loopCount)];
        }
    }
    return self;
}

// `NSBitmapImageRep` will use `kCGImagePropertyGIFDelayTime` whenever you call `setProperty:withValue:` with `NSImageCurrentFrame` to change the current frame. We override it and use the actual `kCGImagePropertyGIFUnclampedDelayTime` if need.
- (void)setProperty:(NSBitmapImageRepPropertyKey)property withValue:(id)value {
    [super setProperty:property withValue:value];
    if ([property isEqualToString:NSImageCurrentFrame]) {
        // Access the image source
        CGImageSourceRef imageSource = _imageSource;
        if (!imageSource) {
            return;
        }
        // Check format type
        CFStringRef type = CGImageSourceGetType(imageSource);
        if (!type) {
            return;
        }
        NSUInteger index = [value unsignedIntegerValue];
        NSTimeInterval frameDuration = 0;
        if (CFStringCompare(type, kUTTypeGIF, 0) == kCFCompareEqualTo) {
            // GIF
            frameDuration = [CSCImageGIFCoder frameDurationAtIndex:index source:imageSource];
        } else if (CFStringCompare(type, kUTTypePNG, 0) == kCFCompareEqualTo) {
            // APNG
            frameDuration = [CSCImageAPNGCoder frameDurationAtIndex:index source:imageSource];
        } else if (CFStringCompare(type, kCSCUTTypeHEICS, 0) == kCFCompareEqualTo) {
            // HEIC
            frameDuration = [CSCImageHEICCoder frameDurationAtIndex:index source:imageSource];
        }
        if (!frameDuration) {
            return;
        }
        // Reset super frame duration with the actual frame duration
        [super setProperty:NSImageCurrentFrameDuration withValue:@(frameDuration)];
    }
}

@end

#endif

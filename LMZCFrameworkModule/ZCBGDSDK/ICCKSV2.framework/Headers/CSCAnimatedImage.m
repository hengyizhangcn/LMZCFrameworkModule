/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCAnimatedImage.h"
#import "CSCImage+Compatibility.h"
#import "CSCImageCoder.h"
#import "CSCImageCodersManager.h"
#import "CSCImageFrame.h"
#import "UIImage+CSCMemoryCacheCost.h"
#import "CSCImageAssetManager.h"
#import "objc/runtime.h"

static CGFloat CSCImageScaleFromPath(NSString *string) {
    if (string.length == 0 || [string hasSuffix:@"/"]) return 1;
    NSString *name = string.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    [pattern enumerateMatchesInString:name options:kNilOptions range:NSMakeRange(0, name.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location >= 3) {
            scale = [string substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)].doubleValue;
        }
    }];
    
    return scale;
}

@interface CSCAnimatedImage ()

@property (nonatomic, strong) id<CSCAnimatedImageCoder> coder;
@property (nonatomic, assign, readwrite) CSCImageFormat animatedImageFormat;
@property (atomic, copy) NSArray<CSCImageFrame *> *loadedAnimatedImageFrames; // Mark as atomic to keep thread-safe
@property (nonatomic, assign, getter=isAllFramesLoaded) BOOL allFramesLoaded;

@end

@implementation CSCAnimatedImage
@dynamic scale; // call super

#pragma mark - UIImage override method
+ (instancetype)imageNamed:(NSString *)name {
#if __has_include(<UIKit/UITraitCollection.h>)
    return [self imageNamed:name inBundle:nil compatibleWithTraitCollection:nil];
#else
    return [self imageNamed:name inBundle:nil];
#endif
}

#if __has_include(<UIKit/UITraitCollection.h>)
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle compatibleWithTraitCollection:(UITraitCollection *)traitCollection {
    if (!traitCollection) {
        traitCollection = UIScreen.mainScreen.traitCollection;
    }
    CGFloat scale = traitCollection.displayScale;
    return [self imageNamed:name inBundle:bundle scale:scale];
}
#else
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    return [self imageNamed:name inBundle:bundle scale:0];
}
#endif

// 0 scale means automatically check
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle scale:(CGFloat)scale {
    if (!name) {
        return nil;
    }
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    CSCImageAssetManager *assetManager = [CSCImageAssetManager sharedAssetManager];
    CSCAnimatedImage *image = (CSCAnimatedImage *)[assetManager imageForName:name];
    if ([image isKindOfClass:[CSCAnimatedImage class]]) {
        return image;
    }
    NSString *path = [assetManager getPathForName:name bundle:bundle preferredScale:&scale];
    if (!path) {
        return image;
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return image;
    }
    image = [[self alloc] initWithData:data scale:scale];
    if (image) {
        [assetManager storeImage:image forName:name];
    }
    
    return image;
}

+ (instancetype)imageWithContentsOfFile:(NSString *)path {
    return [[self alloc] initWithContentsOfFile:path];
}

+ (instancetype)imageWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

+ (instancetype)imageWithData:(NSData *)data scale:(CGFloat)scale {
    return [[self alloc] initWithData:data scale:scale];
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self initWithData:data scale:CSCImageScaleFromPath(path)];
}

- (instancetype)initWithData:(NSData *)data {
    return [self initWithData:data scale:1];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale {
    return [self initWithData:data scale:scale options:nil];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale options:(CSCImageCoderOptions *)options {
    if (!data || data.length == 0) {
        return nil;
    }
    data = [data copy]; // avoid mutable data
    id<CSCAnimatedImageCoder> animatedCoder = nil;
    for (id<CSCImageCoder>coder in [CSCImageCodersManager sharedManager].coders) {
        if ([coder conformsToProtocol:@protocol(CSCAnimatedImageCoder)]) {
            if ([coder canDecodeFromData:data]) {
                if (!options) {
                    options = @{CSCImageCoderDecodeScaleFactor : @(scale)};
                }
                animatedCoder = [[[coder class] alloc] initWithAnimatedImageData:data options:options];
                break;
            }
        }
    }
    if (!animatedCoder) {
        return nil;
    }
    return [self initWithAnimatedCoder:animatedCoder scale:scale];
}

- (instancetype)initWithAnimatedCoder:(id<CSCAnimatedImageCoder>)animatedCoder scale:(CGFloat)scale {
    if (!animatedCoder) {
        return nil;
    }
    UIImage *image = [animatedCoder animatedImageFrameAtIndex:0];
    if (!image) {
        return nil;
    }
#if CSC_MAC
    self = [super initWithCGImage:image.CGImage scale:MAX(scale, 1) orientation:kCGImagePropertyOrientationUp];
#else
    self = [super initWithCGImage:image.CGImage scale:MAX(scale, 1) orientation:image.imageOrientation];
#endif
    if (self) {
        _coder = animatedCoder;
        NSData *data = [animatedCoder animatedImageData];
        CSCImageFormat format = [NSData sd_imageFormatForImageData:data];
        _animatedImageFormat = format;
    }
    return self;
}

#pragma mark - Preload
- (void)preloadAllFrames {
    if (!self.isAllFramesLoaded) {
        NSMutableArray<CSCImageFrame *> *frames = [NSMutableArray arrayWithCapacity:self.animatedImageFrameCount];
        for (size_t i = 0; i < self.animatedImageFrameCount; i++) {
            UIImage *image = [self animatedImageFrameAtIndex:i];
            NSTimeInterval duration = [self animatedImageDurationAtIndex:i];
            CSCImageFrame *frame = [CSCImageFrame frameWithImage:image duration:duration]; // through the image should be nonnull, used as nullable for `animatedImageFrameAtIndex:`
            [frames addObject:frame];
        }
        self.loadedAnimatedImageFrames = frames;
        self.allFramesLoaded = YES;
    }
}

- (void)unloadAllFrames {
    if (self.isAllFramesLoaded) {
        self.loadedAnimatedImageFrames = nil;
        self.allFramesLoaded = NO;
    }
}

#pragma mark - NSSecureCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSData *animatedImageData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(animatedImageData))];
        CGFloat scale = self.scale;
        if (!animatedImageData) {
            return self;
        }
        id<CSCAnimatedImageCoder> animatedCoder = nil;
        for (id<CSCImageCoder>coder in [CSCImageCodersManager sharedManager].coders) {
            if ([coder conformsToProtocol:@protocol(CSCAnimatedImageCoder)]) {
                if ([coder canDecodeFromData:animatedImageData]) {
                    animatedCoder = [[[coder class] alloc] initWithAnimatedImageData:animatedImageData options:@{CSCImageCoderDecodeScaleFactor : @(scale)}];
                    break;
                }
            }
        }
        if (!animatedCoder) {
            return self;
        }
        _coder = animatedCoder;
        CSCImageFormat format = [NSData sd_imageFormatForImageData:animatedImageData];
        _animatedImageFormat = format;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    NSData *animatedImageData = self.animatedImageData;
    if (animatedImageData) {
        [aCoder encodeObject:animatedImageData forKey:NSStringFromSelector(@selector(animatedImageData))];
    }
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - CSCAnimatedImage

- (NSData *)animatedImageData {
    return [self.coder animatedImageData];
}

- (NSUInteger)animatedImageLoopCount {
    return [self.coder animatedImageLoopCount];
}

- (NSUInteger)animatedImageFrameCount {
    return [self.coder animatedImageFrameCount];
}

- (UIImage *)animatedImageFrameAtIndex:(NSUInteger)index {
    if (index >= self.animatedImageFrameCount) {
        return nil;
    }
    if (self.isAllFramesLoaded) {
        CSCImageFrame *frame = [self.loadedAnimatedImageFrames objectAtIndex:index];
        return frame.image;
    }
    return [self.coder animatedImageFrameAtIndex:index];
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index {
    if (index >= self.animatedImageFrameCount) {
        return 0;
    }
    if (self.isAllFramesLoaded) {
        CSCImageFrame *frame = [self.loadedAnimatedImageFrames objectAtIndex:index];
        return frame.duration;
    }
    return [self.coder animatedImageDurationAtIndex:index];
}

@end

@implementation CSCAnimatedImage (MemoryCacheCost)

- (NSUInteger)sd_memoryCost {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sd_memoryCost));
    if (value != nil) {
        return value.unsignedIntegerValue;
    }
    
    CGImageRef imageRef = self.CGImage;
    if (!imageRef) {
        return 0;
    }
    NSUInteger bytesPerFrame = CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef);
    NSUInteger frameCount = 1;
    if (self.isAllFramesLoaded) {
        frameCount = self.animatedImageFrameCount;
    }
    frameCount = frameCount > 0 ? frameCount : 1;
    NSUInteger cost = bytesPerFrame * frameCount;
    return cost;
}

@end

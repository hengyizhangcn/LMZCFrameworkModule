/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageCodersManager.h"
#import "CSCImageIOCoder.h"
#import "CSCImageGIFCoder.h"
#import "CSCImageAPNGCoder.h"
#import "CSCImageHEICCoder.h"
#import "CSCInternalMacros.h"

@interface CSCImageCodersManager ()

@property (nonatomic, strong, nonnull) dispatch_semaphore_t codersLock;

@end

@implementation CSCImageCodersManager
{
    NSMutableArray<id<CSCImageCoder>> *_imageCoders;
}

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // initialize with default coders
        _imageCoders = [NSMutableArray arrayWithArray:@[[CSCImageIOCoder sharedCoder], [CSCImageGIFCoder sharedCoder], [CSCImageAPNGCoder sharedCoder]]];
        _codersLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSArray<id<CSCImageCoder>> *)coders
{
    CSC_LOCK(self.codersLock);
    NSArray<id<CSCImageCoder>> *coders = [_imageCoders copy];
    CSC_UNLOCK(self.codersLock);
    return coders;
}

- (void)setCoders:(NSArray<id<CSCImageCoder>> *)coders
{
    CSC_LOCK(self.codersLock);
    [_imageCoders removeAllObjects];
    if (coders.count) {
        [_imageCoders addObjectsFromArray:coders];
    }
    CSC_UNLOCK(self.codersLock);
}

#pragma mark - Coder IO operations

- (void)addCoder:(nonnull id<CSCImageCoder>)coder {
    if (![coder conformsToProtocol:@protocol(CSCImageCoder)]) {
        return;
    }
    CSC_LOCK(self.codersLock);
    [_imageCoders addObject:coder];
    CSC_UNLOCK(self.codersLock);
}

- (void)removeCoder:(nonnull id<CSCImageCoder>)coder {
    if (![coder conformsToProtocol:@protocol(CSCImageCoder)]) {
        return;
    }
    CSC_LOCK(self.codersLock);
    [_imageCoders removeObject:coder];
    CSC_UNLOCK(self.codersLock);
}

#pragma mark - CSCImageCoder
- (BOOL)canDecodeFromData:(NSData *)data {
    NSArray<id<CSCImageCoder>> *coders = self.coders;
    for (id<CSCImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canEncodeToFormat:(CSCImageFormat)format {
    NSArray<id<CSCImageCoder>> *coders = self.coders;
    for (id<CSCImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(nullable CSCImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    UIImage *image;
    NSArray<id<CSCImageCoder>> *coders = self.coders;
    for (id<CSCImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            image = [coder decodedImageWithData:data options:options];
            break;
        }
    }
    
    return image;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(CSCImageFormat)format options:(nullable CSCImageCoderOptions *)options {
    if (!image) {
        return nil;
    }
    NSArray<id<CSCImageCoder>> *coders = self.coders;
    for (id<CSCImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return [coder encodedDataWithImage:image format:format options:options];
        }
    }
    return nil;
}

@end

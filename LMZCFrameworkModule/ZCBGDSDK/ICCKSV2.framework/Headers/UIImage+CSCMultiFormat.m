/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+CSCMultiFormat.h"
#import "CSCImageCodersManager.h"

@implementation UIImage (MultiFormat)

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data {
    return [self sd_imageWithData:data scale:1];
}

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale {
    return [self sd_imageWithData:data scale:scale firstFrameOnly:NO];
}

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale firstFrameOnly:(BOOL)firstFrameOnly {
    if (!data) {
        return nil;
    }
    CSCImageCoderOptions *options = @{CSCImageCoderDecodeScaleFactor : @(MAX(scale, 1)), CSCImageCoderDecodeFirstFrameOnly : @(firstFrameOnly)};
    return [[CSCImageCodersManager sharedManager] decodedImageWithData:data options:options];
}

- (nullable NSData *)sd_imageData {
    return [self sd_imageDataAsFormat:CSCImageFormatUndefined];
}

- (nullable NSData *)sd_imageDataAsFormat:(CSCImageFormat)imageFormat {
    return [self sd_imageDataAsFormat:imageFormat compressionQuality:1];
}

- (nullable NSData *)sd_imageDataAsFormat:(CSCImageFormat)imageFormat compressionQuality:(double)compressionQuality {
    return [self sd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:NO];
}

- (nullable NSData *)sd_imageDataAsFormat:(CSCImageFormat)imageFormat compressionQuality:(double)compressionQuality firstFrameOnly:(BOOL)firstFrameOnly {
    CSCImageCoderOptions *options = @{CSCImageCoderEncodeCompressionQuality : @(compressionQuality), CSCImageCoderEncodeFirstFrameOnly : @(firstFrameOnly)};
    return [[CSCImageCodersManager sharedManager] encodedDataWithImage:self format:imageFormat options:options];
}

@end

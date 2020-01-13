/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "CSCImageIOAnimatedCoder.h"

/**
 Built in coder using ImageIO that supports animated GIF encoding/decoding
 @note `CSCImageIOCoder` supports GIF but only as static (will use the 1st frame).
 @note Use `CSCImageGIFCoder` for fully animated GIFs. For `UIImageView`, it will produce animated `UIImage`(`NSImage` on macOS) for rendering. For `CSCAnimatedImageView`, it will use `CSCAnimatedImage` for rendering.
 @note The recommended approach for animated GIFs is using `CSCAnimatedImage` with `CSCAnimatedImageView`. It's more performant than `UIImageView` for GIF displaying(especially on memory usage)
 */
@interface CSCImageGIFCoder : CSCImageIOAnimatedCoder <CSCProgressiveImageCoder, CSCAnimatedImageCoder>

@property (nonatomic, class, readonly, nonnull) CSCImageGIFCoder *sharedCoder;

@end

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
 Built in coder using ImageIO that supports APNG encoding/decoding
 */
@interface CSCImageAPNGCoder : CSCImageIOAnimatedCoder <CSCProgressiveImageCoder, CSCAnimatedImageCoder>

@property (nonatomic, class, readonly, nonnull) CSCImageAPNGCoder *sharedCoder;

@end

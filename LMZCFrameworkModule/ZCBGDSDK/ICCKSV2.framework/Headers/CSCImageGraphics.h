/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageCompat.h"
#import <CoreGraphics/CoreGraphics.h>

/**
 These following graphics context method are provided to easily write cross-platform(AppKit/UIKit) code.
 For UIKit, these methods just call the same method in `UIGraphics.h`. See the documentation for usage.
 For AppKit, these methods use `NSGraphicsContext` to create image context and match the behavior like UIKit.
 */

/// Returns the current graphics context.
FOUNDATION_EXPORT CGContextRef __nullable CSCGraphicsGetCurrentContext(void) CF_RETURNS_NOT_RETAINED;
/// Creates a bitmap-based graphics context and makes it the current context.
FOUNDATION_EXPORT void CSCGraphicsBeginImageContext(CGSize size);
/// Creates a bitmap-based graphics context with the specified options.
FOUNDATION_EXPORT void CSCGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale);
/// Removes the current bitmap-based graphics context from the top of the stack.
FOUNDATION_EXPORT void CSCGraphicsEndImageContext(void);
/// Returns an image based on the contents of the current bitmap-based graphics context.
FOUNDATION_EXPORT UIImage * __nullable CSCGraphicsGetImageFromCurrentImageContext(void);
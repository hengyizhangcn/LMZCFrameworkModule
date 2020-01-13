/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageCompat.h"

#if CSC_MAC

#import "UIImage+CSCTransform.h"

@interface NSBezierPath (RoundedCorners)

/**
 Convenience way to create a bezier path with the specify rounding corners on macOS. Same as the one on `UIBezierPath`.
 */
+ (nonnull instancetype)sd_bezierPathWithRoundedRect:(NSRect)rect byRoundingCorners:(CSCRectCorner)corners cornerRadius:(CGFloat)cornerRadius;

@end

#endif

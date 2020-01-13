/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "CSCWebImageCompat.h"

/**
 You can use switch case like normal enum. It's also recommended to add a default case. You should not assume anything about the raw value.
 For custom coder plugin, it can also extern the enum for supported format. See `CSCImageCoder` for more detailed information.
 */
typedef NSInteger CSCImageFormat NS_TYPED_EXTENSIBLE_ENUM;
static const CSCImageFormat CSCImageFormatUndefined = -1;
static const CSCImageFormat CSCImageFormatJPEG      = 0;
static const CSCImageFormat CSCImageFormatPNG       = 1;
static const CSCImageFormat CSCImageFormatGIF       = 2;
static const CSCImageFormat CSCImageFormatTIFF      = 3;
static const CSCImageFormat CSCImageFormatWebP      = 4;
static const CSCImageFormat CSCImageFormatHEIC      = 5;
static const CSCImageFormat CSCImageFormatHEIF      = 6;

/**
 NSData category about the image content type and UTI.
 */
@interface NSData (ImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `CSCImageFormat` (enum)
 */
+ (CSCImageFormat)sd_imageFormatForImageData:(nullable NSData *)data;

/**
 *  Convert CSCImageFormat to UTType
 *
 *  @param format Format as CSCImageFormat
 *  @return The UTType as CFStringRef
 */
+ (nonnull CFStringRef)sd_UTTypeFromImageFormat:(CSCImageFormat)format CF_RETURNS_NOT_RETAINED NS_SWIFT_NAME(sd_UTType(from:));

/**
 *  Convert UTTyppe to CSCImageFormat
 *
 *  @param uttype The UTType as CFStringRef
 *  @return The Format as CSCImageFormat
 */
+ (CSCImageFormat)sd_imageFormatFromUTType:(nonnull CFStringRef)uttype;

@end

/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSData+CSCImageContentType.h"
#if CSC_MAC
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif
#import "CSCImageHEICCoderInternal.h"

// Currently Image/IO does not support WebP
#define kCSCUTTypeWebP ((__bridge CFStringRef)@"public.webp")

@implementation NSData (ImageContentType)

+ (CSCImageFormat)sd_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return CSCImageFormatUndefined;
    }
    
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return CSCImageFormatJPEG;
        case 0x89:
            return CSCImageFormatPNG;
        case 0x47:
            return CSCImageFormatGIF;
        case 0x49:
        case 0x4D:
            return CSCImageFormatTIFF;
        case 0x52: {
            if (data.length >= 12) {
                //RIFF....WEBP
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return CSCImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return CSCImageFormatHEIC;
                }
                //....ftypmif1 ....ftypmsf1
                if ([testString isEqualToString:@"ftypmif1"] || [testString isEqualToString:@"ftypmsf1"]) {
                    return CSCImageFormatHEIF;
                }
            }
            break;
        }
    }
    return CSCImageFormatUndefined;
}

+ (nonnull CFStringRef)sd_UTTypeFromImageFormat:(CSCImageFormat)format {
    CFStringRef UTType;
    switch (format) {
        case CSCImageFormatJPEG:
            UTType = kUTTypeJPEG;
            break;
        case CSCImageFormatPNG:
            UTType = kUTTypePNG;
            break;
        case CSCImageFormatGIF:
            UTType = kUTTypeGIF;
            break;
        case CSCImageFormatTIFF:
            UTType = kUTTypeTIFF;
            break;
        case CSCImageFormatWebP:
            UTType = kCSCUTTypeWebP;
            break;
        case CSCImageFormatHEIC:
            UTType = kCSCUTTypeHEIC;
            break;
        case CSCImageFormatHEIF:
            UTType = kCSCUTTypeHEIF;
            break;
        default:
            // default is kUTTypePNG
            UTType = kUTTypePNG;
            break;
    }
    return UTType;
}

+ (CSCImageFormat)sd_imageFormatFromUTType:(CFStringRef)uttype {
    if (!uttype) {
        return CSCImageFormatUndefined;
    }
    CSCImageFormat imageFormat;
    if (CFStringCompare(uttype, kUTTypeJPEG, 0) == kCFCompareEqualTo) {
        imageFormat = CSCImageFormatJPEG;
    } else if (CFStringCompare(uttype, kUTTypePNG, 0) == kCFCompareEqualTo) {
        imageFormat = CSCImageFormatPNG;
    } else if (CFStringCompare(uttype, kUTTypeGIF, 0) == kCFCompareEqualTo) {
        imageFormat = CSCImageFormatGIF;
    } else if (CFStringCompare(uttype, kUTTypeTIFF, 0) == kCFCompareEqualTo) {
        imageFormat = CSCImageFormatTIFF;
    } else if (CFStringCompare(uttype, kCSCUTTypeWebP, 0) == kCFCompareEqualTo) {
        imageFormat = CSCImageFormatWebP;
    } else if (CFStringCompare(uttype, kCSCUTTypeHEIC, 0) == kCFCompareEqualTo) {
        imageFormat = CSCImageFormatHEIC;
    } else if (CFStringCompare(uttype, kCSCUTTypeHEIF, 0) == kCFCompareEqualTo) {
        imageFormat = CSCImageFormatHEIF;
    } else {
        imageFormat = CSCImageFormatUndefined;
    }
    return imageFormat;
}

@end

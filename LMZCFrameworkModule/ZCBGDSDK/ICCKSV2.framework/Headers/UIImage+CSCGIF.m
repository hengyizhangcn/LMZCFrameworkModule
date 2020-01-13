/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Laurin Brandner
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+CSCGIF.h"
#import "CSCImageGIFCoder.h"

@implementation UIImage (GIF)

+ (nullable UIImage *)sd_imageWithGIFData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    return [[CSCImageGIFCoder sharedCoder] decodedImageWithData:data options:0];
}

@end

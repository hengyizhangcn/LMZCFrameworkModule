/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Florent Vilmart
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <ICCKSV2/CSCWebImageCompat.h>

#if CSC_UIKIT
#import <UIKit/UIKit.h>
#endif

//! Project version number for WebImage.
FOUNDATION_EXPORT double WebImageVersionNumber;

//! Project version string for WebImage.
FOUNDATION_EXPORT const unsigned char WebImageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WebImage/PublicHeader.h>

#import <ICCKSV2/CSCWebImageManager.h>
#import <ICCKSV2/CSCWebImageCacheKeyFilter.h>
#import <ICCKSV2/CSCWebImageCacheSerializer.h>
#import <ICCKSV2/CSCImageCacheConfig.h>
#import <ICCKSV2/CSCImageCache.h>
#import <ICCKSV2/CSCMemoryCache.h>
#import <ICCKSV2/CSCDiskCache.h>
#import <ICCKSV2/CSCImageCacheDefine.h>
#import <ICCKSV2/CSCImageCachesManager.h>
#import <ICCKSV2/UIView+CSCWebCache.h>
#import <ICCKSV2/UIImageView+CSCWebCache.h>
#import <ICCKSV2/UIImageView+CSCHighlightedWebCache.h>
#import <ICCKSV2/CSCWebImageDownloaderConfig.h>
#import <ICCKSV2/CSCWebImageDownloaderOperation.h>
#import <ICCKSV2/CSCWebImageDownloaderRequestModifier.h>
#import <ICCKSV2/CSCImageLoader.h>
#import <ICCKSV2/CSCImageLoadersManager.h>
#import <ICCKSV2/UIButton+CSCWebCache.h>
#import <ICCKSV2/CSCWebImagePrefetcher.h>
#import <ICCKSV2/UIView+CSCWebCacheOperation.h>
#import <ICCKSV2/UIImage+CSCMetadata.h>
#import <ICCKSV2/UIImage+CSCMultiFormat.h>
#import <ICCKSV2/UIImage+CSCMemoryCacheCost.h>
#import <ICCKSV2/CSCWebImageOperation.h>
#import <ICCKSV2/CSCWebImageDownloader.h>
#import <ICCKSV2/CSCWebImageTransition.h>
#import <ICCKSV2/CSCWebImageIndicator.h>
#import <ICCKSV2/CSCImageTransformer.h>
#import <ICCKSV2/UIImage+CSCTransform.h>
#import <ICCKSV2/CSCAnimatedImage.h>
#import <ICCKSV2/CSCAnimatedImageView.h>
#import <ICCKSV2/CSCAnimatedImageView+WebCache.h>
#import <ICCKSV2/CSCImageCodersManager.h>
#import <ICCKSV2/CSCImageCoder.h>
#import <ICCKSV2/CSCImageAPNGCoder.h>
#import <ICCKSV2/CSCImageGIFCoder.h>
#import <ICCKSV2/CSCImageIOCoder.h>
#import <ICCKSV2/CSCImageFrame.h>
#import <ICCKSV2/CSCImageCoderHelper.h>
#import <ICCKSV2/CSCImageGraphics.h>
#import <ICCKSV2/UIImage+CSCGIF.h>
#import <ICCKSV2/UIImage+CSCForceDecode.h>
#import <ICCKSV2/NSData+CSCImageContentType.h>
#import <ICCKSV2/CSCWebImageDefine.h>
#import <ICCKSV2/CSCWebImageError.h>
#import <ICCKSV2/CSCWebImageOptionsProcessor.h>
#import <ICCKSV2/CSCImageIOAnimatedCoder.h>
#import <ICCKSV2/CSCImageHEICCoder.h>

// Mac
#if __has_include(<ICCKSV2/CSCImage+Compatibility.h>)
#import <ICCKSV2/CSCImage+Compatibility.h>
#endif
#if __has_include(<ICCKSV2/CSCButton+WebCache.h>)
#import <ICCKSV2/CSCButton+WebCache.h>
#endif
#if __has_include(<ICCKSV2/CSCAnimatedImageRep.h>)
#import <ICCKSV2/CSCAnimatedImageRep.h>
#endif

// MapKit
#if __has_include(<ICCKSV2/MKAnnotationView+WebCache.h>)
#import <ICCKSV2/MKAnnotationView+WebCache.h>
#endif

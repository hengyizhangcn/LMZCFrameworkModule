/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+CSCHighlightedWebCache.h"

#if CSC_UIKIT

#import "UIView+CSCWebCacheOperation.h"
#import "UIView+CSCWebCache.h"
#import "CSCInternalMacros.h"

static NSString * const CSCHighlightedImageOperationKey = @"UIImageViewImageOperationHighlighted";

@implementation UIImageView (HighlightedWebCache)

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url {
    [self sd_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url options:(CSCWebImageOptions)options {
    [self sd_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url options:(CSCWebImageOptions)options context:(nullable CSCWebImageContext *)context {
    [self sd_setHighlightedImageWithURL:url options:options context:context progress:nil completed:nil];
}

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url completed:(nullable CSCExternalCompletionBlock)completedBlock {
    [self sd_setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url options:(CSCWebImageOptions)options completed:(nullable CSCExternalCompletionBlock)completedBlock {
    [self sd_setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)sd_setHighlightedImageWithURL:(NSURL *)url options:(CSCWebImageOptions)options progress:(nullable CSCImageLoaderProgressBlock)progressBlock completed:(nullable CSCExternalCompletionBlock)completedBlock {
    [self sd_setHighlightedImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url
                              options:(CSCWebImageOptions)options
                              context:(nullable CSCWebImageContext *)context
                             progress:(nullable CSCImageLoaderProgressBlock)progressBlock
                            completed:(nullable CSCExternalCompletionBlock)completedBlock {
    @weakify(self);
    CSCWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[CSCWebImageContextSetImageOperationKey] = CSCHighlightedImageOperationKey;
    [self sd_internalSetImageWithURL:url
                    placeholderImage:nil
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, CSCImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @strongify(self);
                           self.highlightedImage = image;
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, CSCImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

@end

#endif

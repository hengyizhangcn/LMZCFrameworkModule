/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageManager.h"
#import "CSCImageCache.h"
#import "CSCWebImageDownloader.h"
#import "UIImage+CSCMetadata.h"
#import "CSCWebImageError.h"
#import "CSCInternalMacros.h"

static id<CSCImageCache> _defaultImageCache;
static id<CSCImageLoader> _defaultImageLoader;

@interface CSCWebImageCombinedOperation ()

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (strong, nonatomic, readwrite, nullable) id<CSCWebImageOperation> loaderOperation;
@property (strong, nonatomic, readwrite, nullable) id<CSCWebImageOperation> cacheOperation;
@property (weak, nonatomic, nullable) CSCWebImageManager *manager;

@end

@interface CSCWebImageManager ()

@property (strong, nonatomic, readwrite, nonnull) CSCImageCache *imageCache;
@property (strong, nonatomic, readwrite, nonnull) id<CSCImageLoader> imageLoader;
@property (strong, nonatomic, nonnull) NSMutableSet<NSURL *> *failedURLs;
@property (strong, nonatomic, nonnull) dispatch_semaphore_t failedURLsLock; // a lock to keep the access to `failedURLs` thread-safe
@property (strong, nonatomic, nonnull) NSMutableSet<CSCWebImageCombinedOperation *> *runningOperations;
@property (strong, nonatomic, nonnull) dispatch_semaphore_t runningOperationsLock; // a lock to keep the access to `runningOperations` thread-safe

@end

@implementation CSCWebImageManager

+ (id<CSCImageCache>)defaultImageCache {
    return _defaultImageCache;
}

+ (void)setDefaultImageCache:(id<CSCImageCache>)defaultImageCache {
    if (defaultImageCache && ![defaultImageCache conformsToProtocol:@protocol(CSCImageCache)]) {
        return;
    }
    _defaultImageCache = defaultImageCache;
}

+ (id<CSCImageLoader>)defaultImageLoader {
    return _defaultImageLoader;
}

+ (void)setDefaultImageLoader:(id<CSCImageLoader>)defaultImageLoader {
    if (defaultImageLoader && ![defaultImageLoader conformsToProtocol:@protocol(CSCImageLoader)]) {
        return;
    }
    _defaultImageLoader = defaultImageLoader;
}

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    id<CSCImageCache> cache = [[self class] defaultImageCache];
    if (!cache) {
        cache = [CSCImageCache sharedImageCache];
    }
    id<CSCImageLoader> loader = [[self class] defaultImageLoader];
    if (!loader) {
        loader = [CSCWebImageDownloader sharedDownloader];
    }
    return [self initWithCache:cache loader:loader];
}

- (nonnull instancetype)initWithCache:(nonnull id<CSCImageCache>)cache loader:(nonnull id<CSCImageLoader>)loader {
    if ((self = [super init])) {
        _imageCache = cache;
        _imageLoader = loader;
        _failedURLs = [NSMutableSet new];
        _failedURLsLock = dispatch_semaphore_create(1);
        _runningOperations = [NSMutableSet new];
        _runningOperationsLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    return [self cacheKeyForURL:url cacheKeyFilter:self.cacheKeyFilter];
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url cacheKeyFilter:(id<CSCWebImageCacheKeyFilter>)cacheKeyFilter {
    if (!url) {
        return @"";
    }

    if (cacheKeyFilter) {
        return [cacheKeyFilter cacheKeyForURL:url];
    } else {
        return url.absoluteString;
    }
}

- (CSCWebImageCombinedOperation *)loadImageWithURL:(NSURL *)url options:(CSCWebImageOptions)options progress:(CSCImageLoaderProgressBlock)progressBlock completed:(CSCInternalCompletionBlock)completedBlock {
    return [self loadImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

- (CSCWebImageCombinedOperation *)loadImageWithURL:(nullable NSURL *)url
                                          options:(CSCWebImageOptions)options
                                          context:(nullable CSCWebImageContext *)context
                                         progress:(nullable CSCImageLoaderProgressBlock)progressBlock
                                        completed:(nonnull CSCInternalCompletionBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[CSCWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, Xcode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    CSCWebImageCombinedOperation *operation = [CSCWebImageCombinedOperation new];
    operation.manager = self;

    BOOL isFailedUrl = NO;
    if (url) {
        CSC_LOCK(self.failedURLsLock);
        isFailedUrl = [self.failedURLs containsObject:url];
        CSC_UNLOCK(self.failedURLsLock);
    }

    if (url.absoluteString.length == 0 || (!(options & CSCWebImageRetryFailed) && isFailedUrl)) {
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}] url:url];
        return operation;
    }

    CSC_LOCK(self.runningOperationsLock);
    [self.runningOperations addObject:operation];
    CSC_UNLOCK(self.runningOperationsLock);
    
    // Preprocess the options and context arg to decide the final the result for manager
    CSCWebImageOptionsResult *result = [self processedResultForURL:url options:options context:context];
    
    // Start the entry to load image from cache
    [self callCacheProcessForOperation:operation url:url options:result.options context:result.context progress:progressBlock completed:completedBlock];

    return operation;
}

- (void)cancelAll {
    CSC_LOCK(self.runningOperationsLock);
    NSSet<CSCWebImageCombinedOperation *> *copiedOperations = [self.runningOperations copy];
    CSC_UNLOCK(self.runningOperationsLock);
    [copiedOperations makeObjectsPerformSelector:@selector(cancel)]; // This will call `safelyRemoveOperationFromRunning:` and remove from the array
}

- (BOOL)isRunning {
    BOOL isRunning = NO;
    CSC_LOCK(self.runningOperationsLock);
    isRunning = (self.runningOperations.count > 0);
    CSC_UNLOCK(self.runningOperationsLock);
    return isRunning;
}

#pragma mark - Private

// Query cache process
- (void)callCacheProcessForOperation:(nonnull CSCWebImageCombinedOperation *)operation
                                 url:(nonnull NSURL *)url
                             options:(CSCWebImageOptions)options
                             context:(nullable CSCWebImageContext *)context
                            progress:(nullable CSCImageLoaderProgressBlock)progressBlock
                           completed:(nullable CSCInternalCompletionBlock)completedBlock {
    // Check whether we should query cache
    BOOL shouldQueryCache = !CSC_OPTIONS_CONTAINS(options, CSCWebImageFromLoaderOnly);
    if (shouldQueryCache) {
        id<CSCWebImageCacheKeyFilter> cacheKeyFilter = context[CSCWebImageContextCacheKeyFilter];
        NSString *key = [self cacheKeyForURL:url cacheKeyFilter:cacheKeyFilter];
        @weakify(operation);
        operation.cacheOperation = [self.imageCache queryImageForKey:key options:options context:context completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, CSCImageCacheType cacheType) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorCancelled userInfo:nil] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            }
            // Continue download process
            [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:cachedImage cachedData:cachedData cacheType:cacheType progress:progressBlock completed:completedBlock];
        }];
    } else {
        // Continue download process
        [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:nil cachedData:nil cacheType:CSCImageCacheTypeNone progress:progressBlock completed:completedBlock];
    }
}

// Download process
- (void)callDownloadProcessForOperation:(nonnull CSCWebImageCombinedOperation *)operation
                                    url:(nonnull NSURL *)url
                                options:(CSCWebImageOptions)options
                                context:(CSCWebImageContext *)context
                            cachedImage:(nullable UIImage *)cachedImage
                             cachedData:(nullable NSData *)cachedData
                              cacheType:(CSCImageCacheType)cacheType
                               progress:(nullable CSCImageLoaderProgressBlock)progressBlock
                              completed:(nullable CSCInternalCompletionBlock)completedBlock {
    // Check whether we should download image from network
    BOOL shouldDownload = !CSC_OPTIONS_CONTAINS(options, CSCWebImageFromCacheOnly);
    shouldDownload &= (!cachedImage || options & CSCWebImageRefreshCached);
    shouldDownload &= (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url]);
    shouldDownload &= [self.imageLoader canRequestImageForURL:url];
    if (shouldDownload) {
        if (cachedImage && options & CSCWebImageRefreshCached) {
            // If image was found in the cache but CSCWebImageRefreshCached is provided, notify about the cached image
            // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
            [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            // Pass the cached image to the image loader. The image loader should check whether the remote image is equal to the cached image.
            CSCWebImageMutableContext *mutableContext;
            if (context) {
                mutableContext = [context mutableCopy];
            } else {
                mutableContext = [NSMutableDictionary dictionary];
            }
            mutableContext[CSCWebImageContextLoaderCachedImage] = cachedImage;
            context = [mutableContext copy];
        }
        
        @weakify(operation);
        operation.loaderOperation = [self.imageLoader requestImageWithURL:url options:options context:context progress:progressBlock completed:^(UIImage *downloadedImage, NSData *downloadedData, NSError *error, BOOL finished) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorCancelled userInfo:nil] url:url];
            } else if (cachedImage && options & CSCWebImageRefreshCached && [error.domain isEqualToString:CSCWebImageErrorDomain] && error.code == CSCWebImageErrorCacheNotModified) {
                // Image refresh hit the NSURLCache cache, do not call the completion block
            } else if ([error.domain isEqualToString:CSCWebImageErrorDomain] && error.code == CSCWebImageErrorCancelled) {
                // Download operation cancelled by user before sending the request, don't block failed URL
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error url:url];
            } else if (error) {
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error url:url];
                BOOL shouldBlockFailedURL = [self shouldBlockFailedURLWithURL:url error:error];
                
                if (shouldBlockFailedURL) {
                    CSC_LOCK(self.failedURLsLock);
                    [self.failedURLs addObject:url];
                    CSC_UNLOCK(self.failedURLsLock);
                }
            } else {
                if ((options & CSCWebImageRetryFailed)) {
                    CSC_LOCK(self.failedURLsLock);
                    [self.failedURLs removeObject:url];
                    CSC_UNLOCK(self.failedURLsLock);
                }
                
                [self callStoreCacheProcessForOperation:operation url:url options:options context:context downloadedImage:downloadedImage downloadedData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
            }
            
            if (finished) {
                [self safelyRemoveOperationFromRunning:operation];
            }
        }];
    } else if (cachedImage) {
        [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
        [self safelyRemoveOperationFromRunning:operation];
    } else {
        // Image not in cache and download disallowed by delegate
        [self callCompletionBlockForOperation:operation completion:completedBlock image:nil data:nil error:nil cacheType:CSCImageCacheTypeNone finished:YES url:url];
        [self safelyRemoveOperationFromRunning:operation];
    }
}

// Store cache process
- (void)callStoreCacheProcessForOperation:(nonnull CSCWebImageCombinedOperation *)operation
                                      url:(nonnull NSURL *)url
                                  options:(CSCWebImageOptions)options
                                  context:(CSCWebImageContext *)context
                          downloadedImage:(nullable UIImage *)downloadedImage
                           downloadedData:(nullable NSData *)downloadedData
                                 finished:(BOOL)finished
                                 progress:(nullable CSCImageLoaderProgressBlock)progressBlock
                                completed:(nullable CSCInternalCompletionBlock)completedBlock {
    // the target image store cache type
    CSCImageCacheType storeCacheType = CSCImageCacheTypeAll;
    if (context[CSCWebImageContextStoreCacheType]) {
        storeCacheType = [context[CSCWebImageContextStoreCacheType] integerValue];
    }
    // the original store image cache type
    CSCImageCacheType originalStoreCacheType = CSCImageCacheTypeNone;
    if (context[CSCWebImageContextOriginalStoreCacheType]) {
        originalStoreCacheType = [context[CSCWebImageContextOriginalStoreCacheType] integerValue];
    }
    id<CSCWebImageCacheKeyFilter> cacheKeyFilter = context[CSCWebImageContextCacheKeyFilter];
    NSString *key = [self cacheKeyForURL:url cacheKeyFilter:cacheKeyFilter];
    id<CSCImageTransformer> transformer = context[CSCWebImageContextImageTransformer];
    id<CSCWebImageCacheSerializer> cacheSerializer = context[CSCWebImageContextCacheSerializer];
    
    BOOL shouldTransformImage = downloadedImage && (!downloadedImage.sd_isAnimated || (options & CSCWebImageTransformAnimatedImage)) && transformer;
    BOOL shouldCacheOriginal = downloadedImage && finished;
    
    // if available, store original image to cache
    if (shouldCacheOriginal) {
        // normally use the store cache type, but if target image is transformed, use original store cache type instead
        CSCImageCacheType targetStoreCacheType = shouldTransformImage ? originalStoreCacheType : storeCacheType;
        if (cacheSerializer && (targetStoreCacheType == CSCImageCacheTypeDisk || targetStoreCacheType == CSCImageCacheTypeAll)) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                @autoreleasepool {
                    NSData *cacheData = [cacheSerializer cacheDataWithImage:downloadedImage originalData:downloadedData imageURL:url];
                    [self.imageCache storeImage:downloadedImage imageData:cacheData forKey:key cacheType:targetStoreCacheType completion:nil];
                }
            });
        } else {
            [self.imageCache storeImage:downloadedImage imageData:downloadedData forKey:key cacheType:targetStoreCacheType completion:nil];
        }
    }
    // if available, store transformed image to cache
    if (shouldTransformImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            @autoreleasepool {
                UIImage *transformedImage = [transformer transformedImageWithImage:downloadedImage forKey:key];
                if (transformedImage && finished) {
                    NSString *transformerKey = [transformer transformerKey];
                    NSString *cacheKey = CSCTransformedKeyForKey(key, transformerKey);
                    BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                    NSData *cacheData;
                    // pass nil if the image was transformed, so we can recalculate the data from the image
                    if (cacheSerializer && (storeCacheType == CSCImageCacheTypeDisk || storeCacheType == CSCImageCacheTypeAll)) {
                        cacheData = [cacheSerializer cacheDataWithImage:transformedImage  originalData:(imageWasTransformed ? nil : downloadedData) imageURL:url];
                    } else {
                        cacheData = (imageWasTransformed ? nil : downloadedData);
                    }
                    [self.imageCache storeImage:transformedImage imageData:cacheData forKey:cacheKey cacheType:storeCacheType completion:nil];
                }
                
                [self callCompletionBlockForOperation:operation completion:completedBlock image:transformedImage data:downloadedData error:nil cacheType:CSCImageCacheTypeNone finished:finished url:url];
            }
        });
    } else {
        [self callCompletionBlockForOperation:operation completion:completedBlock image:downloadedImage data:downloadedData error:nil cacheType:CSCImageCacheTypeNone finished:finished url:url];
    }
}

#pragma mark - Helper

- (void)safelyRemoveOperationFromRunning:(nullable CSCWebImageCombinedOperation*)operation {
    if (!operation) {
        return;
    }
    CSC_LOCK(self.runningOperationsLock);
    [self.runningOperations removeObject:operation];
    CSC_UNLOCK(self.runningOperationsLock);
}

- (void)callCompletionBlockForOperation:(nullable CSCWebImageCombinedOperation*)operation
                             completion:(nullable CSCInternalCompletionBlock)completionBlock
                                  error:(nullable NSError *)error
                                    url:(nullable NSURL *)url {
    [self callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:CSCImageCacheTypeNone finished:YES url:url];
}

- (void)callCompletionBlockForOperation:(nullable CSCWebImageCombinedOperation*)operation
                             completion:(nullable CSCInternalCompletionBlock)completionBlock
                                  image:(nullable UIImage *)image
                                   data:(nullable NSData *)data
                                  error:(nullable NSError *)error
                              cacheType:(CSCImageCacheType)cacheType
                               finished:(BOOL)finished
                                    url:(nullable NSURL *)url {
    dispatch_main_async_safe(^{
        if (completionBlock) {
            completionBlock(image, data, error, cacheType, finished, url);
        }
    });
}

- (BOOL)shouldBlockFailedURLWithURL:(nonnull NSURL *)url
                              error:(nonnull NSError *)error {
    // Check whether we should block failed url
    BOOL shouldBlockFailedURL;
    if ([self.delegate respondsToSelector:@selector(imageManager:shouldBlockFailedURL:withError:)]) {
        shouldBlockFailedURL = [self.delegate imageManager:self shouldBlockFailedURL:url withError:error];
    } else {
        shouldBlockFailedURL = [self.imageLoader shouldBlockFailedURLWithURL:url error:error];
    }
    
    return shouldBlockFailedURL;
}

- (CSCWebImageOptionsResult *)processedResultForURL:(NSURL *)url options:(CSCWebImageOptions)options context:(CSCWebImageContext *)context {
    CSCWebImageOptionsResult *result;
    CSCWebImageMutableContext *mutableContext = [CSCWebImageMutableContext dictionary];
    
    // Image Transformer from manager
    if (!context[CSCWebImageContextImageTransformer]) {
        id<CSCImageTransformer> transformer = self.transformer;
        [mutableContext setValue:transformer forKey:CSCWebImageContextImageTransformer];
    }
    // Cache key filter from manager
    if (!context[CSCWebImageContextCacheKeyFilter]) {
        id<CSCWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
        [mutableContext setValue:cacheKeyFilter forKey:CSCWebImageContextCacheKeyFilter];
    }
    // Cache serializer from manager
    if (!context[CSCWebImageContextCacheSerializer]) {
        id<CSCWebImageCacheSerializer> cacheSerializer = self.cacheSerializer;
        [mutableContext setValue:cacheSerializer forKey:CSCWebImageContextCacheSerializer];
    }
    
    if (mutableContext.count > 0) {
        if (context) {
            [mutableContext addEntriesFromDictionary:context];
        }
        context = [mutableContext copy];
    }
    
    // Apply options processor
    if (self.optionsProcessor) {
        result = [self.optionsProcessor processedResultForURL:url options:options context:context];
    }
    if (!result) {
        // Use default options result
        result = [[CSCWebImageOptionsResult alloc] initWithOptions:options context:context];
    }
    
    return result;
}

@end


@implementation CSCWebImageCombinedOperation

- (void)cancel {
    @synchronized(self) {
        if (self.isCancelled) {
            return;
        }
        self.cancelled = YES;
        if (self.cacheOperation) {
            [self.cacheOperation cancel];
            self.cacheOperation = nil;
        }
        if (self.loaderOperation) {
            [self.loaderOperation cancel];
            self.loaderOperation = nil;
        }
        [self.manager safelyRemoveOperationFromRunning:self];
    }
}

@end

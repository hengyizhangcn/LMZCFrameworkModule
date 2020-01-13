/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageCache.h"
#import "CSCImage+Compatibility.h"
#import "CSCImageCodersManager.h"
#import "CSCImageTransformer.h"
#import "CSCImageCoderHelper.h"
#import "CSCAnimatedImage.h"
#import "UIImage+CSCMemoryCacheCost.h"
#import "UIImage+CSCMetadata.h"

@interface CSCImageCache ()

#pragma mark - Properties
@property (nonatomic, strong, readwrite, nonnull) id<CSCMemoryCache> memoryCache;
@property (nonatomic, strong, readwrite, nonnull) id<CSCDiskCache> diskCache;
@property (nonatomic, copy, readwrite, nonnull) CSCImageCacheConfig *config;
@property (nonatomic, copy, readwrite, nonnull) NSString *diskCachePath;
@property (nonatomic, strong, nullable) dispatch_queue_t ioQueue;

@end


@implementation CSCImageCache

#pragma mark - Singleton, init, dealloc

+ (nonnull instancetype)sharedImageCache {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    return [self initWithNamespace:@"default"];
}

- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns {
    return [self initWithNamespace:ns diskCacheDirectory:nil];
}

- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nullable NSString *)directory {
    return [self initWithNamespace:ns diskCacheDirectory:directory config:CSCImageCacheConfig.defaultCacheConfig];
}

- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nullable NSString *)directory
                                   config:(nullable CSCImageCacheConfig *)config {
    if ((self = [super init])) {
        NSAssert(ns, @"Cache namespace should not be nil");
        
        // Create IO serial queue
        _ioQueue = dispatch_queue_create("com.hackemist.CSCImageCache", DISPATCH_QUEUE_SERIAL);
        
        if (!config) {
            config = CSCImageCacheConfig.defaultCacheConfig;
        }
        _config = [config copy];
        
        // Init the memory cache
        NSAssert([config.memoryCacheClass conformsToProtocol:@protocol(CSCMemoryCache)], @"Custom memory cache class must conform to `CSCMemoryCache` protocol");
        _memoryCache = [[config.memoryCacheClass alloc] initWithConfig:_config];
        
        // Init the disk cache
        if (directory != nil) {
            _diskCachePath = [directory stringByAppendingPathComponent:ns];
        } else {
            NSString *path = [[[self userCacheDirectory] stringByAppendingPathComponent:@"com.hackemist.CSCImageCache"] stringByAppendingPathComponent:ns];
            _diskCachePath = path;
        }
        
        NSAssert([config.diskCacheClass conformsToProtocol:@protocol(CSCDiskCache)], @"Custom disk cache class must conform to `CSCDiskCache` protocol");
        _diskCache = [[config.diskCacheClass alloc] initWithCachePath:_diskCachePath config:_config];
        
        // Check and migrate disk cache directory if need
        [self migrateDiskCacheDirectory];

#if CSC_UIKIT
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
#endif
#if CSC_MAC
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];
#endif
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Cache paths

- (nullable NSString *)cachePathForKey:(nullable NSString *)key {
    if (!key) {
        return nil;
    }
    return [self.diskCache cachePathForKey:key];
}

- (nullable NSString *)userCacheDirectory {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

- (void)migrateDiskCacheDirectory {
    if ([self.diskCache isKindOfClass:[CSCDiskCache class]]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // ~/Library/Caches/com.hackemist.CSCImageCache/default/
            NSString *newDefaultPath = [[[self userCacheDirectory] stringByAppendingPathComponent:@"com.hackemist.CSCImageCache"] stringByAppendingPathComponent:@"default"];
            // ~/Library/Caches/default/com.hackemist.CSCWebImageCache.default/
            NSString *oldDefaultPath = [[[self userCacheDirectory] stringByAppendingPathComponent:@"default"] stringByAppendingPathComponent:@"com.hackemist.CSCWebImageCache.default"];
            dispatch_async(self.ioQueue, ^{
                [((CSCDiskCache *)self.diskCache) moveCacheDirectoryFromPath:oldDefaultPath toPath:newDefaultPath];
            });
        });
    }
}

#pragma mark - Store Ops

- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
        completion:(nullable CSCWebImageNoParamsBlock)completionBlock {
    [self storeImage:image imageData:nil forKey:key toDisk:YES completion:completionBlock];
}

- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable CSCWebImageNoParamsBlock)completionBlock {
    [self storeImage:image imageData:nil forKey:key toDisk:toDisk completion:completionBlock];
}

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable CSCWebImageNoParamsBlock)completionBlock {
    return [self storeImage:image imageData:imageData forKey:key toMemory:YES toDisk:toDisk completion:completionBlock];
}

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
          toMemory:(BOOL)toMemory
            toDisk:(BOOL)toDisk
        completion:(nullable CSCWebImageNoParamsBlock)completionBlock {
    if (!image || !key) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    // if memory cache is enabled
    if (toMemory && self.config.shouldCacheImagesInMemory) {
        NSUInteger cost = image.sd_memoryCost;
        [self.memoryCache setObject:image forKey:key cost:cost];
    }
    
    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            @autoreleasepool {
                NSData *data = imageData;
                if (!data && image) {
                    // If we do not have any data to detect image format, check whether it contains alpha channel to use PNG or JPEG format
                    CSCImageFormat format;
                    if ([CSCImageCoderHelper CGImageContainsAlpha:image.CGImage]) {
                        format = CSCImageFormatPNG;
                    } else {
                        format = CSCImageFormatJPEG;
                    }
                    data = [[CSCImageCodersManager sharedManager] encodedDataWithImage:image format:format options:nil];
                }
                [self _storeImageDataToDisk:data forKey:key];
            }
            
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
            }
        });
    } else {
        if (completionBlock) {
            completionBlock();
        }
    }
}

- (void)storeImageToMemory:(UIImage *)image forKey:(NSString *)key {
    if (!image || !key) {
        return;
    }
    NSUInteger cost = image.sd_memoryCost;
    [self.memoryCache setObject:image forKey:key cost:cost];
}

- (void)storeImageDataToDisk:(nullable NSData *)imageData
                      forKey:(nullable NSString *)key {
    if (!imageData || !key) {
        return;
    }
    
    dispatch_sync(self.ioQueue, ^{
        [self _storeImageDataToDisk:imageData forKey:key];
    });
}

// Make sure to call form io queue by caller
- (void)_storeImageDataToDisk:(nullable NSData *)imageData forKey:(nullable NSString *)key {
    if (!imageData || !key) {
        return;
    }
    
    [self.diskCache setData:imageData forKey:key];
}

#pragma mark - Query and Retrieve Ops

- (void)diskImageExistsWithKey:(nullable NSString *)key completion:(nullable CSCImageCacheCheckCompletionBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        BOOL exists = [self _diskImageDataExistsWithKey:key];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exists);
            });
        }
    });
}

- (BOOL)diskImageDataExistsWithKey:(nullable NSString *)key {
    if (!key) {
        return NO;
    }
    
    __block BOOL exists = NO;
    dispatch_sync(self.ioQueue, ^{
        exists = [self _diskImageDataExistsWithKey:key];
    });
    
    return exists;
}

// Make sure to call form io queue by caller
- (BOOL)_diskImageDataExistsWithKey:(nullable NSString *)key {
    if (!key) {
        return NO;
    }
    
    return [self.diskCache containsDataForKey:key];
}

- (nullable NSData *)diskImageDataForKey:(nullable NSString *)key {
    if (!key) {
        return nil;
    }
    __block NSData *imageData = nil;
    dispatch_sync(self.ioQueue, ^{
        imageData = [self diskImageDataBySearchingAllPathsForKey:key];
    });
    
    return imageData;
}

- (nullable UIImage *)imageFromMemoryCacheForKey:(nullable NSString *)key {
    return [self.memoryCache objectForKey:key];
}

- (nullable UIImage *)imageFromDiskCacheForKey:(nullable NSString *)key {
    UIImage *diskImage = [self diskImageForKey:key];
    if (diskImage && self.config.shouldCacheImagesInMemory) {
        NSUInteger cost = diskImage.sd_memoryCost;
        [self.memoryCache setObject:diskImage forKey:key cost:cost];
    }

    return diskImage;
}

- (nullable UIImage *)imageFromCacheForKey:(nullable NSString *)key {
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        return image;
    }
    
    // Second check the disk cache...
    image = [self imageFromDiskCacheForKey:key];
    return image;
}

- (nullable NSData *)diskImageDataBySearchingAllPathsForKey:(nullable NSString *)key {
    if (!key) {
        return nil;
    }
    
    NSData *data = [self.diskCache dataForKey:key];
    if (data) {
        return data;
    }
    
    // Addtional cache path for custom pre-load cache
    if (self.additionalCachePathBlock) {
        NSString *filePath = self.additionalCachePathBlock(key);
        if (filePath) {
            data = [NSData dataWithContentsOfFile:filePath options:self.config.diskCacheReadingOptions error:nil];
        }
    }

    return data;
}

- (nullable UIImage *)diskImageForKey:(nullable NSString *)key {
    NSData *data = [self diskImageDataForKey:key];
    return [self diskImageForKey:key data:data];
}

- (nullable UIImage *)diskImageForKey:(nullable NSString *)key data:(nullable NSData *)data {
    return [self diskImageForKey:key data:data options:0 context:nil];
}

- (nullable UIImage *)diskImageForKey:(nullable NSString *)key data:(nullable NSData *)data options:(CSCImageCacheOptions)options context:(CSCWebImageContext *)context {
    if (data) {
        UIImage *image = CSCImageCacheDecodeImageData(data, key, [[self class] imageOptionsFromCacheOptions:options], context);
        return image;
    } else {
        return nil;
    }
}

- (nullable NSOperation *)queryCacheOperationForKey:(NSString *)key done:(CSCImageCacheQueryCompletionBlock)doneBlock {
    return [self queryCacheOperationForKey:key options:0 done:doneBlock];
}

- (nullable NSOperation *)queryCacheOperationForKey:(NSString *)key options:(CSCImageCacheOptions)options done:(CSCImageCacheQueryCompletionBlock)doneBlock {
    return [self queryCacheOperationForKey:key options:options context:nil done:doneBlock];
}

- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key options:(CSCImageCacheOptions)options context:(nullable CSCWebImageContext *)context done:(nullable CSCImageCacheQueryCompletionBlock)doneBlock {
    if (!key) {
        if (doneBlock) {
            doneBlock(nil, nil, CSCImageCacheTypeNone);
        }
        return nil;
    }
    
    id<CSCImageTransformer> transformer = context[CSCWebImageContextImageTransformer];
    if (transformer) {
        // grab the transformed disk image if transformer provided
        NSString *transformerKey = [transformer transformerKey];
        key = CSCTransformedKeyForKey(key, transformerKey);
    }
    
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    
    if (image) {
        if (options & CSCImageCacheDecodeFirstFrameOnly) {
            // Ensure static image
            Class animatedImageClass = image.class;
            if (image.sd_isAnimated || ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(CSCAnimatedImage)])) {
#if CSC_MAC
                image = [[NSImage alloc] initWithCGImage:image.CGImage scale:image.scale orientation:kCGImagePropertyOrientationUp];
#else
                image = [[UIImage alloc] initWithCGImage:image.CGImage scale:image.scale orientation:image.imageOrientation];
#endif
            }
        } else if (options & CSCImageCacheMatchAnimatedImageClass) {
            // Check image class matching
            Class animatedImageClass = image.class;
            Class desiredImageClass = context[CSCWebImageContextAnimatedImageClass];
            if (desiredImageClass && ![animatedImageClass isSubclassOfClass:desiredImageClass]) {
                image = nil;
            }
        }
    }

    BOOL shouldQueryMemoryOnly = (image && !(options & CSCImageCacheQueryMemoryData));
    if (shouldQueryMemoryOnly) {
        if (doneBlock) {
            doneBlock(image, nil, CSCImageCacheTypeMemory);
        }
        return nil;
    }
    
    // Second check the disk cache...
    NSOperation *operation = [NSOperation new];
    // Check whether we need to synchronously query disk
    // 1. in-memory cache hit & memoryDataSync
    // 2. in-memory cache miss & diskDataSync
    BOOL shouldQueryDiskSync = ((image && options & CSCImageCacheQueryMemoryDataSync) ||
                                (!image && options & CSCImageCacheQueryDiskDataSync));
    void(^queryDiskBlock)(void) =  ^{
        if (operation.isCancelled) {
            if (doneBlock) {
                doneBlock(nil, nil, CSCImageCacheTypeNone);
            }
            return;
        }
        
        @autoreleasepool {
            NSData *diskData = [self diskImageDataBySearchingAllPathsForKey:key];
            UIImage *diskImage;
            CSCImageCacheType cacheType = CSCImageCacheTypeNone;
            if (image) {
                // the image is from in-memory cache, but need image data
                diskImage = image;
                cacheType = CSCImageCacheTypeMemory;
            } else if (diskData) {
                cacheType = CSCImageCacheTypeDisk;
                // decode image data only if in-memory cache missed
                diskImage = [self diskImageForKey:key data:diskData options:options context:context];
                if (diskImage && self.config.shouldCacheImagesInMemory) {
                    NSUInteger cost = diskImage.sd_memoryCost;
                    [self.memoryCache setObject:diskImage forKey:key cost:cost];
                }
            }
            
            if (doneBlock) {
                if (shouldQueryDiskSync) {
                    doneBlock(diskImage, diskData, cacheType);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        doneBlock(diskImage, diskData, cacheType);
                    });
                }
            }
        }
    };
    
    // Query in ioQueue to keep IO-safe
    if (shouldQueryDiskSync) {
        dispatch_sync(self.ioQueue, queryDiskBlock);
    } else {
        dispatch_async(self.ioQueue, queryDiskBlock);
    }
    
    return operation;
}

#pragma mark - Remove Ops

- (void)removeImageForKey:(nullable NSString *)key withCompletion:(nullable CSCWebImageNoParamsBlock)completion {
    [self removeImageForKey:key fromDisk:YES withCompletion:completion];
}

- (void)removeImageForKey:(nullable NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(nullable CSCWebImageNoParamsBlock)completion {
    [self removeImageForKey:key fromMemory:YES fromDisk:fromDisk withCompletion:completion];
}

- (void)removeImageForKey:(nullable NSString *)key fromMemory:(BOOL)fromMemory fromDisk:(BOOL)fromDisk withCompletion:(nullable CSCWebImageNoParamsBlock)completion {
    if (key == nil) {
        return;
    }

    if (fromMemory && self.config.shouldCacheImagesInMemory) {
        [self.memoryCache removeObjectForKey:key];
    }

    if (fromDisk) {
        dispatch_async(self.ioQueue, ^{
            [self.diskCache removeDataForKey:key];
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    } else if (completion) {
        completion();
    }
}

- (void)removeImageFromMemoryForKey:(NSString *)key {
    if (!key) {
        return;
    }
    
    [self.memoryCache removeObjectForKey:key];
}

- (void)removeImageFromDiskForKey:(NSString *)key {
    if (!key) {
        return;
    }
    dispatch_sync(self.ioQueue, ^{
        [self _removeImageFromDiskForKey:key];
    });
}

// Make sure to call form io queue by caller
- (void)_removeImageFromDiskForKey:(NSString *)key {
    if (!key) {
        return;
    }
    
    [self.diskCache removeDataForKey:key];
}

#pragma mark - Cache clean Ops

- (void)clearMemory {
    [self.memoryCache removeAllObjects];
}

- (void)clearDiskOnCompletion:(nullable CSCWebImageNoParamsBlock)completion {
    dispatch_async(self.ioQueue, ^{
        [self.diskCache removeAllData];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)deleteOldFilesWithCompletionBlock:(nullable CSCWebImageNoParamsBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        [self.diskCache removeExpiredData];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}

#pragma mark - UIApplicationWillTerminateNotification

#if CSC_UIKIT || CSC_MAC
- (void)applicationWillTerminate:(NSNotification *)notification {
    [self deleteOldFilesWithCompletionBlock:nil];
}
#endif

#pragma mark - UIApplicationDidEnterBackgroundNotification

#if CSC_UIKIT
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (!self.config.shouldRemoveExpiredDataWhenEnterBackground) {
        return;
    }
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

    // Start the long-running task and return immediately.
    [self deleteOldFilesWithCompletionBlock:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}
#endif

#pragma mark - Cache Info

- (NSUInteger)totalDiskSize {
    __block NSUInteger size = 0;
    dispatch_sync(self.ioQueue, ^{
        size = [self.diskCache totalSize];
    });
    return size;
}

- (NSUInteger)totalDiskCount {
    __block NSUInteger count = 0;
    dispatch_sync(self.ioQueue, ^{
        count = [self.diskCache totalCount];
    });
    return count;
}

- (void)calculateSizeWithCompletionBlock:(nullable CSCImageCacheCalculateSizeBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        NSUInteger fileCount = [self.diskCache totalCount];
        NSUInteger totalSize = [self.diskCache totalSize];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize);
            });
        }
    });
}

#pragma mark - Helper
+ (CSCWebImageOptions)imageOptionsFromCacheOptions:(CSCImageCacheOptions)cacheOptions {
    CSCWebImageOptions options = 0;
    if (cacheOptions & CSCImageCacheScaleDownLargeImages) options |= CSCWebImageScaleDownLargeImages;
    if (cacheOptions & CSCImageCacheDecodeFirstFrameOnly) options |= CSCWebImageDecodeFirstFrameOnly;
    if (cacheOptions & CSCImageCachePreloadAllFrames) options |= CSCWebImagePreloadAllFrames;
    if (cacheOptions & CSCImageCacheAvoidDecodeImage) options |= CSCWebImageAvoidDecodeImage;
    if (cacheOptions & CSCImageCacheMatchAnimatedImageClass) options |= CSCWebImageMatchAnimatedImageClass;
    
    return options;
}

@end

@implementation CSCImageCache (CSCImageCache)

#pragma mark - CSCImageCache

- (id<CSCWebImageOperation>)queryImageForKey:(NSString *)key options:(CSCWebImageOptions)options context:(nullable CSCWebImageContext *)context completion:(nullable CSCImageCacheQueryCompletionBlock)completionBlock {
    CSCImageCacheOptions cacheOptions = 0;
    if (options & CSCWebImageQueryMemoryData) cacheOptions |= CSCImageCacheQueryMemoryData;
    if (options & CSCWebImageQueryMemoryDataSync) cacheOptions |= CSCImageCacheQueryMemoryDataSync;
    if (options & CSCWebImageQueryDiskDataSync) cacheOptions |= CSCImageCacheQueryDiskDataSync;
    if (options & CSCWebImageScaleDownLargeImages) cacheOptions |= CSCImageCacheScaleDownLargeImages;
    if (options & CSCWebImageAvoidDecodeImage) cacheOptions |= CSCImageCacheAvoidDecodeImage;
    if (options & CSCWebImageDecodeFirstFrameOnly) cacheOptions |= CSCImageCacheDecodeFirstFrameOnly;
    if (options & CSCWebImagePreloadAllFrames) cacheOptions |= CSCImageCachePreloadAllFrames;
    if (options & CSCWebImageMatchAnimatedImageClass) cacheOptions |= CSCImageCacheMatchAnimatedImageClass;
    
    return [self queryCacheOperationForKey:key options:cacheOptions context:context done:completionBlock];
}

- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(nullable NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(nullable CSCWebImageNoParamsBlock)completionBlock {
    switch (cacheType) {
        case CSCImageCacheTypeNone: {
            [self storeImage:image imageData:imageData forKey:key toMemory:NO toDisk:NO completion:completionBlock];
        }
            break;
        case CSCImageCacheTypeMemory: {
            [self storeImage:image imageData:imageData forKey:key toMemory:YES toDisk:NO completion:completionBlock];
        }
            break;
        case CSCImageCacheTypeDisk: {
            [self storeImage:image imageData:imageData forKey:key toMemory:NO toDisk:YES completion:completionBlock];
        }
            break;
        case CSCImageCacheTypeAll: {
            [self storeImage:image imageData:imageData forKey:key toMemory:YES toDisk:YES completion:completionBlock];
        }
            break;
        default: {
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
    }
}

- (void)removeImageForKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(nullable CSCWebImageNoParamsBlock)completionBlock {
    switch (cacheType) {
        case CSCImageCacheTypeNone: {
            [self removeImageForKey:key fromMemory:NO fromDisk:NO withCompletion:completionBlock];
        }
            break;
        case CSCImageCacheTypeMemory: {
            [self removeImageForKey:key fromMemory:YES fromDisk:NO withCompletion:completionBlock];
        }
            break;
        case CSCImageCacheTypeDisk: {
            [self removeImageForKey:key fromMemory:NO fromDisk:YES withCompletion:completionBlock];
        }
            break;
        case CSCImageCacheTypeAll: {
            [self removeImageForKey:key fromMemory:YES fromDisk:YES withCompletion:completionBlock];
        }
            break;
        default: {
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
    }
}

- (void)containsImageForKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(nullable CSCImageCacheContainsCompletionBlock)completionBlock {
    switch (cacheType) {
        case CSCImageCacheTypeNone: {
            if (completionBlock) {
                completionBlock(CSCImageCacheTypeNone);
            }
        }
            break;
        case CSCImageCacheTypeMemory: {
            BOOL isInMemoryCache = ([self imageFromMemoryCacheForKey:key] != nil);
            if (completionBlock) {
                completionBlock(isInMemoryCache ? CSCImageCacheTypeMemory : CSCImageCacheTypeNone);
            }
        }
            break;
        case CSCImageCacheTypeDisk: {
            [self diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
                if (completionBlock) {
                    completionBlock(isInDiskCache ? CSCImageCacheTypeDisk : CSCImageCacheTypeNone);
                }
            }];
        }
            break;
        case CSCImageCacheTypeAll: {
            BOOL isInMemoryCache = ([self imageFromMemoryCacheForKey:key] != nil);
            if (isInMemoryCache) {
                if (completionBlock) {
                    completionBlock(CSCImageCacheTypeMemory);
                }
                return;
            }
            [self diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
                if (completionBlock) {
                    completionBlock(isInDiskCache ? CSCImageCacheTypeDisk : CSCImageCacheTypeNone);
                }
            }];
        }
            break;
        default:
            if (completionBlock) {
                completionBlock(CSCImageCacheTypeNone);
            }
            break;
    }
}

- (void)clearWithCacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock {
    switch (cacheType) {
        case CSCImageCacheTypeNone: {
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
        case CSCImageCacheTypeMemory: {
            [self clearMemory];
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
        case CSCImageCacheTypeDisk: {
            [self clearDiskOnCompletion:completionBlock];
        }
            break;
        case CSCImageCacheTypeAll: {
            [self clearMemory];
            [self clearDiskOnCompletion:completionBlock];
        }
            break;
        default: {
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
    }
}

@end


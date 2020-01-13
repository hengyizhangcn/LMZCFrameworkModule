/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageCachesManager.h"
#import "CSCImageCachesManagerOperation.h"
#import "CSCImageCache.h"
#import "CSCInternalMacros.h"

@interface CSCImageCachesManager ()

@property (nonatomic, strong, nonnull) dispatch_semaphore_t cachesLock;

@end

@implementation CSCImageCachesManager
{
    NSMutableArray<id<CSCImageCache>> *_imageCaches;
}

+ (CSCImageCachesManager *)sharedManager {
    static dispatch_once_t onceToken;
    static CSCImageCachesManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[CSCImageCachesManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queryOperationPolicy = CSCImageCachesManagerOperationPolicySerial;
        self.storeOperationPolicy = CSCImageCachesManagerOperationPolicyHighestOnly;
        self.removeOperationPolicy = CSCImageCachesManagerOperationPolicyConcurrent;
        self.containsOperationPolicy = CSCImageCachesManagerOperationPolicySerial;
        self.clearOperationPolicy = CSCImageCachesManagerOperationPolicyConcurrent;
        // initialize with default image caches
        _imageCaches = [NSMutableArray arrayWithObject:[CSCImageCache sharedImageCache]];
        _cachesLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSArray<id<CSCImageCache>> *)caches {
    CSC_LOCK(self.cachesLock);
    NSArray<id<CSCImageCache>> *caches = [_imageCaches copy];
    CSC_UNLOCK(self.cachesLock);
    return caches;
}

- (void)setCaches:(NSArray<id<CSCImageCache>> *)caches {
    CSC_LOCK(self.cachesLock);
    [_imageCaches removeAllObjects];
    if (caches.count) {
        [_imageCaches addObjectsFromArray:caches];
    }
    CSC_UNLOCK(self.cachesLock);
}

#pragma mark - Cache IO operations

- (void)addCache:(id<CSCImageCache>)cache {
    if (![cache conformsToProtocol:@protocol(CSCImageCache)]) {
        return;
    }
    CSC_LOCK(self.cachesLock);
    [_imageCaches addObject:cache];
    CSC_UNLOCK(self.cachesLock);
}

- (void)removeCache:(id<CSCImageCache>)cache {
    if (![cache conformsToProtocol:@protocol(CSCImageCache)]) {
        return;
    }
    CSC_LOCK(self.cachesLock);
    [_imageCaches removeObject:cache];
    CSC_UNLOCK(self.cachesLock);
}

#pragma mark - CSCImageCache

- (id<CSCWebImageOperation>)queryImageForKey:(NSString *)key options:(CSCWebImageOptions)options context:(CSCWebImageContext *)context completion:(CSCImageCacheQueryCompletionBlock)completionBlock {
    if (!key) {
        return nil;
    }
    NSArray<id<CSCImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return nil;
    } else if (count == 1) {
        return [caches.firstObject queryImageForKey:key options:options context:context completion:completionBlock];
    }
    switch (self.queryOperationPolicy) {
        case CSCImageCachesManagerOperationPolicyHighestOnly: {
            id<CSCImageCache> cache = caches.lastObject;
            return [cache queryImageForKey:key options:options context:context completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyLowestOnly: {
            id<CSCImageCache> cache = caches.firstObject;
            return [cache queryImageForKey:key options:options context:context completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyConcurrent: {
            CSCImageCachesManagerOperation *operation = [CSCImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentQueryImageForKey:key options:options context:context completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        case CSCImageCachesManagerOperationPolicySerial: {
            CSCImageCachesManagerOperation *operation = [CSCImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self serialQueryImageForKey:key options:options context:context completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        default:
            return nil;
            break;
    }
}

- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<CSCImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.storeOperationPolicy) {
        case CSCImageCachesManagerOperationPolicyHighestOnly: {
            id<CSCImageCache> cache = caches.lastObject;
            [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyLowestOnly: {
            id<CSCImageCache> cache = caches.firstObject;
            [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyConcurrent: {
            CSCImageCachesManagerOperation *operation = [CSCImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case CSCImageCachesManagerOperationPolicySerial: {
            [self serialStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

- (void)removeImageForKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<CSCImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject removeImageForKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.removeOperationPolicy) {
        case CSCImageCachesManagerOperationPolicyHighestOnly: {
            id<CSCImageCache> cache = caches.lastObject;
            [cache removeImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyLowestOnly: {
            id<CSCImageCache> cache = caches.firstObject;
            [cache removeImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyConcurrent: {
            CSCImageCachesManagerOperation *operation = [CSCImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case CSCImageCachesManagerOperationPolicySerial: {
            [self serialRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

- (void)containsImageForKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(CSCImageCacheContainsCompletionBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<CSCImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject containsImageForKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.clearOperationPolicy) {
        case CSCImageCachesManagerOperationPolicyHighestOnly: {
            id<CSCImageCache> cache = caches.lastObject;
            [cache containsImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyLowestOnly: {
            id<CSCImageCache> cache = caches.firstObject;
            [cache containsImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyConcurrent: {
            CSCImageCachesManagerOperation *operation = [CSCImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case CSCImageCachesManagerOperationPolicySerial: {
            CSCImageCachesManagerOperation *operation = [CSCImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self serialContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        default:
            break;
    }
}

- (void)clearWithCacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock {
    NSArray<id<CSCImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject clearWithCacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.clearOperationPolicy) {
        case CSCImageCachesManagerOperationPolicyHighestOnly: {
            id<CSCImageCache> cache = caches.lastObject;
            [cache clearWithCacheType:cacheType completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyLowestOnly: {
            id<CSCImageCache> cache = caches.firstObject;
            [cache clearWithCacheType:cacheType completion:completionBlock];
        }
            break;
        case CSCImageCachesManagerOperationPolicyConcurrent: {
            CSCImageCachesManagerOperation *operation = [CSCImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentClearWithCacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case CSCImageCachesManagerOperationPolicySerial: {
            [self serialClearWithCacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Concurrent Operation

- (void)concurrentQueryImageForKey:(NSString *)key options:(CSCWebImageOptions)options context:(CSCWebImageContext *)context completion:(CSCImageCacheQueryCompletionBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator operation:(CSCImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<CSCImageCache> cache in enumerator) {
        [cache queryImageForKey:key options:options context:context completion:^(UIImage * _Nullable image, NSData * _Nullable data, CSCImageCacheType cacheType) {
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (image) {
                // Success
                [operation done];
                if (completionBlock) {
                    completionBlock(image, data, cacheType);
                }
                return;
            }
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock(nil, nil, CSCImageCacheTypeNone);
                }
            }
        }];
    }
}

- (void)concurrentStoreImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator operation:(CSCImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<CSCImageCache> cache in enumerator) {
        [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

- (void)concurrentRemoveImageForKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator operation:(CSCImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<CSCImageCache> cache in enumerator) {
        [cache removeImageForKey:key cacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

- (void)concurrentContainsImageForKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(CSCImageCacheContainsCompletionBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator operation:(CSCImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<CSCImageCache> cache in enumerator) {
        [cache containsImageForKey:key cacheType:cacheType completion:^(CSCImageCacheType containsCacheType) {
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (containsCacheType != CSCImageCacheTypeNone) {
                // Success
                [operation done];
                if (completionBlock) {
                    completionBlock(containsCacheType);
                }
                return;
            }
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock(CSCImageCacheTypeNone);
                }
            }
        }];
    }
}

- (void)concurrentClearWithCacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator operation:(CSCImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<CSCImageCache> cache in enumerator) {
        [cache clearWithCacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

#pragma mark - Serial Operation

- (void)serialQueryImageForKey:(NSString *)key options:(CSCWebImageOptions)options context:(CSCWebImageContext *)context completion:(CSCImageCacheQueryCompletionBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator operation:(CSCImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    id<CSCImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        [operation done];
        if (completionBlock) {
            completionBlock(nil, nil, CSCImageCacheTypeNone);
        }
        return;
    }
    @weakify(self);
    [cache queryImageForKey:key options:options context:context completion:^(UIImage * _Nullable image, NSData * _Nullable data, CSCImageCacheType cacheType) {
        @strongify(self);
        if (operation.isCancelled) {
            // Cancelled
            return;
        }
        if (operation.isFinished) {
            // Finished
            return;
        }
        [operation completeOne];
        if (image) {
            // Success
            [operation done];
            if (completionBlock) {
                completionBlock(image, data, cacheType);
            }
            return;
        }
        // Next
        [self serialQueryImageForKey:key options:options context:context completion:completionBlock enumerator:enumerator operation:operation];
    }];
}

- (void)serialStoreImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<CSCImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @weakify(self);
    [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:^{
        @strongify(self);
        // Next
        [self serialStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

- (void)serialRemoveImageForKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<CSCImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @weakify(self);
    [cache removeImageForKey:key cacheType:cacheType completion:^{
        @strongify(self);
        // Next
        [self serialRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

- (void)serialContainsImageForKey:(NSString *)key cacheType:(CSCImageCacheType)cacheType completion:(CSCImageCacheContainsCompletionBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator operation:(CSCImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    id<CSCImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        [operation done];
        if (completionBlock) {
            completionBlock(CSCImageCacheTypeNone);
        }
        return;
    }
    @weakify(self);
    [cache containsImageForKey:key cacheType:cacheType completion:^(CSCImageCacheType containsCacheType) {
        @strongify(self);
        if (operation.isCancelled) {
            // Cancelled
            return;
        }
        if (operation.isFinished) {
            // Finished
            return;
        }
        [operation completeOne];
        if (containsCacheType != CSCImageCacheTypeNone) {
            // Success
            [operation done];
            if (completionBlock) {
                completionBlock(containsCacheType);
            }
            return;
        }
        // Next
        [self serialContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator operation:operation];
    }];
}

- (void)serialClearWithCacheType:(CSCImageCacheType)cacheType completion:(CSCWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<CSCImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<CSCImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @weakify(self);
    [cache clearWithCacheType:cacheType completion:^{
        @strongify(self);
        // Next
        [self serialClearWithCacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

@end

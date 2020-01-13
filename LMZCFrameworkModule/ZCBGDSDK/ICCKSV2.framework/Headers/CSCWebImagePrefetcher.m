/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImagePrefetcher.h"
#import "CSCAsyncBlockOperation.h"
#import "CSCInternalMacros.h"
#import <stdatomic.h>

@interface CSCWebImagePrefetchToken () {
    @public
    // Though current implementation, `CSCWebImageManager` completion block is always on main queue. But however, there is no guarantee in docs. And we may introduce config to specify custom queue in the future.
    // These value are just used as incrementing counter, keep thread-safe using memory_order_relaxed for performance.
    atomic_ulong _skippedCount;
    atomic_ulong _finishedCount;
    atomic_flag  _isAllFinished;
    
    unsigned long _totalCount;
}

@property (nonatomic, copy, readwrite) NSArray<NSURL *> *urls;
@property (nonatomic, strong) NSPointerArray *loadOperations;
@property (nonatomic, strong) NSPointerArray *prefetchOperations;
@property (nonatomic, weak) CSCWebImagePrefetcher *prefetcher;
@property (nonatomic, copy, nullable) CSCWebImagePrefetcherCompletionBlock completionBlock;
@property (nonatomic, copy, nullable) CSCWebImagePrefetcherProgressBlock progressBlock;

@end

@interface CSCWebImagePrefetcher ()

@property (strong, nonatomic, nonnull) CSCWebImageManager *manager;
@property (strong, atomic, nonnull) NSMutableSet<CSCWebImagePrefetchToken *> *runningTokens;
@property (strong, nonatomic, nonnull) NSOperationQueue *prefetchQueue;

@end

@implementation CSCWebImagePrefetcher

+ (nonnull instancetype)sharedImagePrefetcher {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    return [self initWithImageManager:[CSCWebImageManager new]];
}

- (nonnull instancetype)initWithImageManager:(CSCWebImageManager *)manager {
    if ((self = [super init])) {
        _manager = manager;
        _runningTokens = [NSMutableSet set];
        _options = CSCWebImageLowPriority;
        _delegateQueue = dispatch_get_main_queue();
        _prefetchQueue = [NSOperationQueue new];
        self.maxConcurrentPrefetchCount = 3;
    }
    return self;
}

- (void)setMaxConcurrentPrefetchCount:(NSUInteger)maxConcurrentPrefetchCount {
    self.prefetchQueue.maxConcurrentOperationCount = maxConcurrentPrefetchCount;
}

- (NSUInteger)maxConcurrentPrefetchCount {
    return self.prefetchQueue.maxConcurrentOperationCount;
}

#pragma mark - Prefetch
- (nullable CSCWebImagePrefetchToken *)prefetchURLs:(nullable NSArray<NSURL *> *)urls {
    return [self prefetchURLs:urls progress:nil completed:nil];
}

- (nullable CSCWebImagePrefetchToken *)prefetchURLs:(nullable NSArray<NSURL *> *)urls
                                          progress:(nullable CSCWebImagePrefetcherProgressBlock)progressBlock
                                         completed:(nullable CSCWebImagePrefetcherCompletionBlock)completionBlock {
    if (!urls || urls.count == 0) {
        if (completionBlock) {
            completionBlock(0, 0);
        }
        return nil;
    }
    CSCWebImagePrefetchToken *token = [CSCWebImagePrefetchToken new];
    token.prefetcher = self;
    token.urls = urls;
    token->_skippedCount = 0;
    token->_finishedCount = 0;
    token->_totalCount = token.urls.count;
    atomic_flag_clear(&(token->_isAllFinished));
    token.loadOperations = [NSPointerArray weakObjectsPointerArray];
    token.prefetchOperations = [NSPointerArray weakObjectsPointerArray];
    token.progressBlock = progressBlock;
    token.completionBlock = completionBlock;
    [self addRunningToken:token];
    [self startPrefetchWithToken:token];
    
    return token;
}

- (void)startPrefetchWithToken:(CSCWebImagePrefetchToken * _Nonnull)token {
    NSPointerArray *operations = token.loadOperations;
    for (NSURL *url in token.urls) {
        @autoreleasepool {
            @weakify(self);
            CSCAsyncBlockOperation *prefetchOperation = [CSCAsyncBlockOperation blockOperationWithBlock:^(CSCAsyncBlockOperation * _Nonnull asyncOperation) {
                @strongify(self);
                if (!self || asyncOperation.isCancelled) {
                    return;
                }
                id<CSCWebImageOperation> operation = [self.manager loadImageWithURL:url options:self.options context:self.context progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, CSCImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    @strongify(self);
                    if (!self) {
                        return;
                    }
                    if (!finished) {
                        return;
                    }
                    atomic_fetch_add_explicit(&(token->_finishedCount), 1, memory_order_relaxed);
                    if (error) {
                        // Add last failed
                        atomic_fetch_add_explicit(&(token->_skippedCount), 1, memory_order_relaxed);
                    }
                    
                    // Current operation finished
                    [self callProgressBlockForToken:token imageURL:imageURL];
                    
                    if (atomic_load_explicit(&(token->_finishedCount), memory_order_relaxed) == token->_totalCount) {
                        // All finished
                        if (!atomic_flag_test_and_set_explicit(&(token->_isAllFinished), memory_order_relaxed)) {
                            [self callCompletionBlockForToken:token];
                            [self removeRunningToken:token];
                        }
                    }
                    [asyncOperation complete];
                }];
                NSAssert(operation != nil, @"Operation should not be nil, [CSCWebImageManager loadImageWithURL:options:context:progress:completed:] break prefetch logic");
                @synchronized (token) {
                    [operations addPointer:(__bridge void *)operation];
                }
            }];
            @synchronized (token) {
                [token.prefetchOperations addPointer:(__bridge void *)prefetchOperation];
            }
            [self.prefetchQueue addOperation:prefetchOperation];
        }
    }
}

#pragma mark - Cancel
- (void)cancelPrefetching {
    @synchronized(self.runningTokens) {
        NSSet<CSCWebImagePrefetchToken *> *copiedTokens = [self.runningTokens copy];
        [copiedTokens makeObjectsPerformSelector:@selector(cancel)];
        [self.runningTokens removeAllObjects];
    }
}

- (void)callProgressBlockForToken:(CSCWebImagePrefetchToken *)token imageURL:(NSURL *)url {
    if (!token) {
        return;
    }
    BOOL shouldCallDelegate = [self.delegate respondsToSelector:@selector(imagePrefetcher:didPrefetchURL:finishedCount:totalCount:)];
    NSUInteger tokenFinishedCount = [self tokenFinishedCount];
    NSUInteger tokenTotalCount = [self tokenTotalCount];
    NSUInteger finishedCount = atomic_load_explicit(&(token->_finishedCount), memory_order_relaxed);
    NSUInteger totalCount = token->_totalCount;
    dispatch_async(self.delegateQueue, ^{
        if (shouldCallDelegate) {
            [self.delegate imagePrefetcher:self didPrefetchURL:url finishedCount:tokenFinishedCount totalCount:tokenTotalCount];
        }
        if (token.progressBlock) {
            token.progressBlock(finishedCount, totalCount);
        }
    });
}

- (void)callCompletionBlockForToken:(CSCWebImagePrefetchToken *)token {
    if (!token) {
        return;
    }
    BOOL shoulCallDelegate = [self.delegate respondsToSelector:@selector(imagePrefetcher:didFinishWithTotalCount:skippedCount:)] && ([self countOfRunningTokens] == 1); // last one
    NSUInteger tokenTotalCount = [self tokenTotalCount];
    NSUInteger tokenSkippedCount = [self tokenSkippedCount];
    NSUInteger finishedCount = atomic_load_explicit(&(token->_finishedCount), memory_order_relaxed);
    NSUInteger skippedCount = atomic_load_explicit(&(token->_skippedCount), memory_order_relaxed);
    dispatch_async(self.delegateQueue, ^{
        if (shoulCallDelegate) {
            [self.delegate imagePrefetcher:self didFinishWithTotalCount:tokenTotalCount skippedCount:tokenSkippedCount];
        }
        if (token.completionBlock) {
            token.completionBlock(finishedCount, skippedCount);
        }
    });
}

#pragma mark - Helper
- (NSUInteger)tokenTotalCount {
    NSUInteger tokenTotalCount = 0;
    @synchronized (self.runningTokens) {
        for (CSCWebImagePrefetchToken *token in self.runningTokens) {
            tokenTotalCount += token->_totalCount;
        }
    }
    return tokenTotalCount;
}

- (NSUInteger)tokenSkippedCount {
    NSUInteger tokenSkippedCount = 0;
    @synchronized (self.runningTokens) {
        for (CSCWebImagePrefetchToken *token in self.runningTokens) {
            tokenSkippedCount += atomic_load_explicit(&(token->_skippedCount), memory_order_relaxed);
        }
    }
    return tokenSkippedCount;
}

- (NSUInteger)tokenFinishedCount {
    NSUInteger tokenFinishedCount = 0;
    @synchronized (self.runningTokens) {
        for (CSCWebImagePrefetchToken *token in self.runningTokens) {
            tokenFinishedCount += atomic_load_explicit(&(token->_finishedCount), memory_order_relaxed);
        }
    }
    return tokenFinishedCount;
}

- (void)addRunningToken:(CSCWebImagePrefetchToken *)token {
    if (!token) {
        return;
    }
    @synchronized (self.runningTokens) {
        [self.runningTokens addObject:token];
    }
}

- (void)removeRunningToken:(CSCWebImagePrefetchToken *)token {
    if (!token) {
        return;
    }
    @synchronized (self.runningTokens) {
        [self.runningTokens removeObject:token];
    }
}

- (NSUInteger)countOfRunningTokens {
    NSUInteger count = 0;
    @synchronized (self.runningTokens) {
        count = self.runningTokens.count;
    }
    return count;
}

@end

@implementation CSCWebImagePrefetchToken

- (void)cancel {
    @synchronized (self) {
        [self.prefetchOperations compact];
        for (id operation in self.prefetchOperations) {
            if ([operation conformsToProtocol:@protocol(CSCWebImageOperation)]) {
                [operation cancel];
            }
        }
        self.prefetchOperations.count = 0;
        
        [self.loadOperations compact];
        for (id operation in self.loadOperations) {
            if ([operation conformsToProtocol:@protocol(CSCWebImageOperation)]) {
                [operation cancel];
            }
        }
        self.loadOperations.count = 0;
    }
    self.completionBlock = nil;
    self.progressBlock = nil;
    [self.prefetcher removeRunningToken:self];
}

@end

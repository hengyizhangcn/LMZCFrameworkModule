/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageLoadersManager.h"
#import "CSCWebImageDownloader.h"
#import "CSCInternalMacros.h"

@interface CSCImageLoadersManager ()

@property (nonatomic, strong, nonnull) dispatch_semaphore_t loadersLock;

@end

@implementation CSCImageLoadersManager
{
    NSMutableArray<id<CSCImageLoader>>* _imageLoaders;
}

+ (CSCImageLoadersManager *)sharedManager {
    static dispatch_once_t onceToken;
    static CSCImageLoadersManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[CSCImageLoadersManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // initialize with default image loaders
        _imageLoaders = [NSMutableArray arrayWithObject:[CSCWebImageDownloader sharedDownloader]];
        _loadersLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSArray<id<CSCImageLoader>> *)loaders {
    CSC_LOCK(self.loadersLock);
    NSArray<id<CSCImageLoader>>* loaders = [_imageLoaders copy];
    CSC_UNLOCK(self.loadersLock);
    return loaders;
}

- (void)setLoaders:(NSArray<id<CSCImageLoader>> *)loaders {
    CSC_LOCK(self.loadersLock);
    [_imageLoaders removeAllObjects];
    if (loaders.count) {
        [_imageLoaders addObjectsFromArray:loaders];
    }
    CSC_UNLOCK(self.loadersLock);
}

#pragma mark - Loader Property

- (void)addLoader:(id<CSCImageLoader>)loader {
    if (![loader conformsToProtocol:@protocol(CSCImageLoader)]) {
        return;
    }
    CSC_LOCK(self.loadersLock);
    [_imageLoaders addObject:loader];
    CSC_UNLOCK(self.loadersLock);
}

- (void)removeLoader:(id<CSCImageLoader>)loader {
    if (![loader conformsToProtocol:@protocol(CSCImageLoader)]) {
        return;
    }
    CSC_LOCK(self.loadersLock);
    [_imageLoaders removeObject:loader];
    CSC_UNLOCK(self.loadersLock);
}

#pragma mark - CSCImageLoader

- (BOOL)canRequestImageForURL:(nullable NSURL *)url {
    NSArray<id<CSCImageLoader>> *loaders = self.loaders;
    for (id<CSCImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return YES;
        }
    }
    return NO;
}

- (id<CSCWebImageOperation>)requestImageWithURL:(NSURL *)url options:(CSCWebImageOptions)options context:(CSCWebImageContext *)context progress:(CSCImageLoaderProgressBlock)progressBlock completed:(CSCImageLoaderCompletedBlock)completedBlock {
    if (!url) {
        return nil;
    }
    NSArray<id<CSCImageLoader>> *loaders = self.loaders;
    for (id<CSCImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return [loader requestImageWithURL:url options:options context:context progress:progressBlock completed:completedBlock];
        }
    }
    return nil;
}

- (BOOL)shouldBlockFailedURLWithURL:(NSURL *)url error:(NSError *)error {
    NSArray<id<CSCImageLoader>> *loaders = self.loaders;
    for (id<CSCImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return [loader shouldBlockFailedURLWithURL:url error:error];
        }
    }
    return NO;
}

@end

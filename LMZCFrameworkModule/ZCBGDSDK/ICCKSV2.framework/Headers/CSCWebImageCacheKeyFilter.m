/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageCacheKeyFilter.h"

@interface CSCWebImageCacheKeyFilter ()

@property (nonatomic, copy, nonnull) CSCWebImageCacheKeyFilterBlock block;

@end

@implementation CSCWebImageCacheKeyFilter

- (instancetype)initWithBlock:(CSCWebImageCacheKeyFilterBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)cacheKeyFilterWithBlock:(CSCWebImageCacheKeyFilterBlock)block {
    CSCWebImageCacheKeyFilter *cacheKeyFilter = [[CSCWebImageCacheKeyFilter alloc] initWithBlock:block];
    return cacheKeyFilter;
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!self.block) {
        return nil;
    }
    return self.block(url);
}

@end

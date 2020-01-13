/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "CSCWebImageCompat.h"

typedef NSData * _Nullable(^CSCWebImageCacheSerializerBlock)(UIImage * _Nonnull image, NSData * _Nullable data, NSURL * _Nullable imageURL);

/**
 This is the protocol for cache serializer.
 We can use a block to specify the cache serializer. But Using protocol can make this extensible, and allow Swift user to use it easily instead of using `@convention(block)` to store a block into context options.
 */
@protocol CSCWebImageCacheSerializer <NSObject>

- (nullable NSData *)cacheDataWithImage:(nonnull UIImage *)image originalData:(nullable NSData *)data imageURL:(nullable NSURL *)imageURL;

@end

/**
 A cache serializer class with block.
 */
@interface CSCWebImageCacheSerializer : NSObject <CSCWebImageCacheSerializer>

- (nonnull instancetype)initWithBlock:(nonnull CSCWebImageCacheSerializerBlock)block;
+ (nonnull instancetype)cacheSerializerWithBlock:(nonnull CSCWebImageCacheSerializerBlock)block;

@end

/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "CSCWebImageCompat.h"

typedef NSURLRequest * _Nullable (^CSCWebImageDownloaderRequestModifierBlock)(NSURLRequest * _Nonnull request);

/**
 This is the protocol for downloader request modifier.
 We can use a block to specify the downloader request modifier. But Using protocol can make this extensible, and allow Swift user to use it easily instead of using `@convention(block)` to store a block into context options.
 */
@protocol CSCWebImageDownloaderRequestModifier <NSObject>

- (nullable NSURLRequest *)modifiedRequestWithRequest:(nonnull NSURLRequest *)request;

@end

/**
 A downloader request modifier class with block.
 */
@interface CSCWebImageDownloaderRequestModifier : NSObject <CSCWebImageDownloaderRequestModifier>

- (nonnull instancetype)initWithBlock:(nonnull CSCWebImageDownloaderRequestModifierBlock)block;
+ (nonnull instancetype)requestModifierWithBlock:(nonnull CSCWebImageDownloaderRequestModifierBlock)block;

@end

/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "CSCWebImageCompat.h"
#import "CSCWebImageDefine.h"

@class CSCWebImageOptionsResult;

typedef CSCWebImageOptionsResult * _Nullable(^CSCWebImageOptionsProcessorBlock)(NSURL * _Nullable url, CSCWebImageOptions options, CSCWebImageContext * _Nullable context);

/**
 The options result contains both options and context.
 */
@interface CSCWebImageOptionsResult : NSObject

/**
 WebCache options.
 */
@property (nonatomic, assign, readonly) CSCWebImageOptions options;

/**
 Context options.
 */
@property (nonatomic, copy, readonly, nullable) CSCWebImageContext *context;

/**
 Create a new options result.

 @param options options
 @param context context
 @return The options result contains both options and context.
 */
- (nonnull instancetype)initWithOptions:(CSCWebImageOptions)options context:(nullable CSCWebImageContext *)context;

@end

/**
 This is the protocol for options processor.
 Options processor can be used, to control the final result for individual image request's `CSCWebImageOptions` and `CSCWebImageContext`
 Implements the protocol to have a global control for each indivadual image request's option.
 */
@protocol CSCWebImageOptionsProcessor <NSObject>

/**
 Return the processed options result for specify image URL, with its options and context

 @param url The URL to the image
 @param options A mask to specify options to use for this request
 @param context A context contains different options to perform specify changes or processes, see `CSCWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 @return The processed result, contains both options and context
 */
- (nullable CSCWebImageOptionsResult *)processedResultForURL:(nullable NSURL *)url
                                                    options:(CSCWebImageOptions)options
                                                    context:(nullable CSCWebImageContext *)context;

@end

/**
 A options processor class with block.
 */
@interface CSCWebImageOptionsProcessor : NSObject<CSCWebImageOptionsProcessor>

- (nonnull instancetype)initWithBlock:(nonnull CSCWebImageOptionsProcessorBlock)block;
+ (nonnull instancetype)optionsProcessorWithBlock:(nonnull CSCWebImageOptionsProcessorBlock)block;

@end

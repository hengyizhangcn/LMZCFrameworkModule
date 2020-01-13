/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageOptionsProcessor.h"

@interface CSCWebImageOptionsResult ()

@property (nonatomic, assign) CSCWebImageOptions options;
@property (nonatomic, copy, nullable) CSCWebImageContext *context;

@end

@implementation CSCWebImageOptionsResult

- (instancetype)initWithOptions:(CSCWebImageOptions)options context:(CSCWebImageContext *)context {
    self = [super init];
    if (self) {
        self.options = options;
        self.context = context;
    }
    return self;
}

@end

@interface CSCWebImageOptionsProcessor ()

@property (nonatomic, copy, nonnull) CSCWebImageOptionsProcessorBlock block;

@end

@implementation CSCWebImageOptionsProcessor

- (instancetype)initWithBlock:(CSCWebImageOptionsProcessorBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)optionsProcessorWithBlock:(CSCWebImageOptionsProcessorBlock)block {
    CSCWebImageOptionsProcessor *optionsProcessor = [[CSCWebImageOptionsProcessor alloc] initWithBlock:block];
    return optionsProcessor;
}

- (CSCWebImageOptionsResult *)processedResultForURL:(NSURL *)url options:(CSCWebImageOptions)options context:(CSCWebImageContext *)context {
    if (!self.block) {
        return nil;
    }
    return self.block(url, options, context);
}

@end

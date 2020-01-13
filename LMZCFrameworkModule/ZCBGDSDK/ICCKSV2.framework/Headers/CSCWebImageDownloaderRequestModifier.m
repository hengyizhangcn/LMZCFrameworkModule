/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageDownloaderRequestModifier.h"

@interface CSCWebImageDownloaderRequestModifier ()

@property (nonatomic, copy, nonnull) CSCWebImageDownloaderRequestModifierBlock block;

@end

@implementation CSCWebImageDownloaderRequestModifier

- (instancetype)initWithBlock:(CSCWebImageDownloaderRequestModifierBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)requestModifierWithBlock:(CSCWebImageDownloaderRequestModifierBlock)block {
    CSCWebImageDownloaderRequestModifier *requestModifier = [[CSCWebImageDownloaderRequestModifier alloc] initWithBlock:block];
    return requestModifier;
}

- (NSURLRequest *)modifiedRequestWithRequest:(NSURLRequest *)request {
    if (!self.block) {
        return nil;
    }
    return self.block(request);
}

@end

/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageCompat.h"

@class CSCAsyncBlockOperation;
typedef void (^CSCAsyncBlock)(CSCAsyncBlockOperation * __nonnull asyncOperation);

@interface CSCAsyncBlockOperation : NSOperation

- (nonnull instancetype)initWithBlock:(nonnull CSCAsyncBlock)block;
+ (nonnull instancetype)blockOperationWithBlock:(nonnull CSCAsyncBlock)block;
- (void)complete;

@end

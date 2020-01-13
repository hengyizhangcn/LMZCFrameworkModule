/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCAsyncBlockOperation.h"

@interface CSCAsyncBlockOperation ()

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, copy, nonnull) CSCAsyncBlock executionBlock;

@end

@implementation CSCAsyncBlockOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (nonnull instancetype)initWithBlock:(nonnull CSCAsyncBlock)block {
    self = [super init];
    if (self) {
        self.executionBlock = block;
    }
    return self;
}

+ (nonnull instancetype)blockOperationWithBlock:(nonnull CSCAsyncBlock)block {
    CSCAsyncBlockOperation *operation = [[CSCAsyncBlockOperation alloc] initWithBlock:block];
    return operation;
}

- (void)start {
    if (self.isCancelled) {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    self.executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    if (self.executionBlock) {
        self.executionBlock(self);
    } else {
        [self complete];
    }
}

- (void)cancel {
    [super cancel];
    [self complete];
}

- (void)complete {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.executing = NO;
    self.finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

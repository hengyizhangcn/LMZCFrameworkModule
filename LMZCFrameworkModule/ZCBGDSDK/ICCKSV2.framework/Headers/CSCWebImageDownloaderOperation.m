/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageDownloaderOperation.h"
#import "CSCWebImageError.h"
#import "CSCInternalMacros.h"

// iOS 8 Foundation.framework extern these symbol but the define is in CFNetwork.framework. We just fix this without import CFNetwork.framework
#if ((__IPHONE_OS_VERSION_MIN_REQUIRED && __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0) || (__MAC_OS_X_VERSION_MIN_REQUIRED && __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_11))
const float NSURLSessionTaskPriorityHigh = 0.75;
const float NSURLSessionTaskPriorityDefault = 0.5;
const float NSURLSessionTaskPriorityLow = 0.25;
#endif

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

typedef NSMutableDictionary<NSString *, id> CSCCallbacksDictionary;

@interface CSCWebImageDownloaderOperation ()

@property (strong, nonatomic, nonnull) NSMutableArray<CSCCallbacksDictionary *> *callbackBlocks;

@property (assign, nonatomic, readwrite) CSCWebImageDownloaderOptions options;
@property (copy, nonatomic, readwrite, nullable) CSCWebImageContext *context;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (strong, nonatomic, nullable) NSMutableData *imageData;
@property (copy, nonatomic, nullable) NSData *cachedData; // for `CSCWebImageDownloaderIgnoreCachedResponse`
@property (assign, nonatomic) NSUInteger expectedSize; // may be 0
@property (assign, nonatomic) NSUInteger receivedSize;
@property (strong, nonatomic, nullable, readwrite) NSURLResponse *response;
@property (strong, nonatomic, nullable) NSError *responseError;
@property (assign, nonatomic) double previousProgress; // previous progress percent

// This is weak because it is injected by whoever manages this session. If this gets nil-ed out, we won't be able to run
// the task associated with this operation
@property (weak, nonatomic, nullable) NSURLSession *unownedSession;
// This is set if we're using not using an injected NSURLSession. We're responsible of invalidating this one
@property (strong, nonatomic, nullable) NSURLSession *ownedSession;

@property (strong, nonatomic, readwrite, nullable) NSURLSessionTask *dataTask;

@property (strong, nonatomic, nonnull) dispatch_queue_t coderQueue; // the queue to do image decoding
#if CSC_UIKIT
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
#endif

@end

@implementation CSCWebImageDownloaderOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (nonnull instancetype)init {
    return [self initWithRequest:nil inSession:nil options:0];
}

- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session options:(CSCWebImageDownloaderOptions)options {
    return [self initWithRequest:request inSession:session options:options context:nil];
}

- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(CSCWebImageDownloaderOptions)options
                                context:(nullable CSCWebImageContext *)context {
    if ((self = [super init])) {
        _request = [request copy];
        _options = options;
        _context = [context copy];
        _callbackBlocks = [NSMutableArray new];
        _executing = NO;
        _finished = NO;
        _expectedSize = 0;
        _unownedSession = session;
        _coderQueue = dispatch_queue_create("com.hackemist.CSCWebImageDownloaderOperationCoderQueue", DISPATCH_QUEUE_SERIAL);
#if CSC_UIKIT
        _backgroundTaskId = UIBackgroundTaskInvalid;
#endif
    }
    return self;
}

- (nullable id)addHandlersForProgress:(nullable CSCWebImageDownloaderProgressBlock)progressBlock
                            completed:(nullable CSCWebImageDownloaderCompletedBlock)completedBlock {
    CSCCallbacksDictionary *callbacks = [NSMutableDictionary new];
    if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
    if (completedBlock) callbacks[kCompletedCallbackKey] = [completedBlock copy];
    @synchronized (self) {
        [self.callbackBlocks addObject:callbacks];
    }
    return callbacks;
}

- (nullable NSArray<id> *)callbacksForKey:(NSString *)key {
    NSMutableArray<id> *callbacks;
    @synchronized (self) {
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
    }
    // We need to remove [NSNull null] because there might not always be a progress block for each callback
    [callbacks removeObjectIdenticalTo:[NSNull null]];
    return [callbacks copy]; // strip mutability here
}

- (BOOL)cancel:(nullable id)token {
    if (!token) return NO;
    
    BOOL shouldCancel = NO;
    @synchronized (self) {
        NSMutableArray *tempCallbackBlocks = [self.callbackBlocks mutableCopy];
        [tempCallbackBlocks removeObjectIdenticalTo:token];
        if (tempCallbackBlocks.count == 0) {
            shouldCancel = YES;
        }
    }
    if (shouldCancel) {
        // Cancel operation running and callback last token's completion block
        [self cancel];
    } else {
        // Only callback this token's completion block
        @synchronized (self) {
            [self.callbackBlocks removeObjectIdenticalTo:token];
        }
        CSCWebImageDownloaderCompletedBlock completedBlock = [token valueForKey:kCompletedCallbackKey];
        dispatch_main_async_safe(^{
            if (completedBlock) {
                completedBlock(nil, nil, [NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorCancelled userInfo:nil], YES);
            }
        });
    }
    return shouldCancel;
}

- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            // Operation cancelled by user before sending the request
            [self callCompletionBlocksWithError:[NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorCancelled userInfo:nil]];
            [self reset];
            return;
        }

#if CSC_UIKIT
        Class UIApplicationClass = NSClassFromString(@"UIApplication");
        BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
        if (hasApplication && [self shouldContinueWhenAppEntersBackground]) {
            __weak typeof(self) wself = self;
            UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                [wself cancel];
            }];
        }
#endif
        NSURLSession *session = self.unownedSession;
        if (!session) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.timeoutIntervalForRequest = 15;
            
            /**
             *  Create the session for this task
             *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
             *  method calls and completion handler calls.
             */
            session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                    delegate:self
                                               delegateQueue:nil];
            self.ownedSession = session;
        }
        
        if (self.options & CSCWebImageDownloaderIgnoreCachedResponse) {
            // Grab the cached data for later check
            NSURLCache *URLCache = session.configuration.URLCache;
            if (!URLCache) {
                URLCache = [NSURLCache sharedURLCache];
            }
            NSCachedURLResponse *cachedResponse;
            // NSURLCache's `cachedResponseForRequest:` is not thread-safe, see https://developer.apple.com/documentation/foundation/nsurlcache#2317483
            @synchronized (URLCache) {
                cachedResponse = [URLCache cachedResponseForRequest:self.request];
            }
            if (cachedResponse) {
                self.cachedData = cachedResponse.data;
            }
        }
        
        self.dataTask = [session dataTaskWithRequest:self.request];
        self.executing = YES;
    }

    if (self.dataTask) {
        if (self.options & CSCWebImageDownloaderHighPriority) {
            self.dataTask.priority = NSURLSessionTaskPriorityHigh;
        } else if (self.options & CSCWebImageDownloaderLowPriority) {
            self.dataTask.priority = NSURLSessionTaskPriorityLow;
        }
        [self.dataTask resume];
        for (CSCWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(0, NSURLResponseUnknownLength, self.request.URL);
        }
        __block typeof(self) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CSCWebImageDownloadStartNotification object:strongSelf];
        });
    } else {
        [self callCompletionBlocksWithError:[NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorInvalidDownloadOperation userInfo:@{NSLocalizedDescriptionKey : @"Task can't be initialized"}]];
        [self done];
    }
}

- (void)cancel {
    @synchronized (self) {
        [self cancelInternal];
    }
}

- (void)cancelInternal {
    if (self.isFinished) return;
    [super cancel];

    if (self.dataTask) {
        [self.dataTask cancel];
        __block typeof(self) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CSCWebImageDownloadStopNotification object:strongSelf];
        });

        // As we cancelled the task, its callback won't be called and thus won't
        // maintain the isFinished and isExecuting flags.
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }
    // Operation cancelled by user before sending the request
    [self callCompletionBlocksWithError:[NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorCancelled userInfo:nil]];

    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    @synchronized (self) {
        [self.callbackBlocks removeAllObjects];
        self.dataTask = nil;
        
        if (self.ownedSession) {
            [self.ownedSession invalidateAndCancel];
            self.ownedSession = nil;
        }
        
#if CSC_UIKIT
        if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
            // If backgroundTaskId != UIBackgroundTaskInvalid, sharedApplication is always exist
            UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
            [app endBackgroundTask:self.backgroundTaskId];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }
#endif
    }
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    NSInteger expected = (NSInteger)response.expectedContentLength;
    expected = expected > 0 ? expected : 0;
    self.expectedSize = expected;
    self.response = response;
    NSInteger statusCode = [response respondsToSelector:@selector(statusCode)] ? ((NSHTTPURLResponse *)response).statusCode : 200;
    BOOL valid = statusCode >= 200 && statusCode < 400;
    if (!valid) {
        self.responseError = [NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorInvalidDownloadStatusCode userInfo:@{CSCWebImageErrorDownloadStatusCodeKey : @(statusCode)}];
    }
    //'304 Not Modified' is an exceptional one
    //URLSession current behavior will return 200 status code when the server respond 304 and URLCache hit. But this is not a standard behavior and we just add a check
    if (statusCode == 304 && !self.cachedData) {
        valid = NO;
        self.responseError = [NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorCacheNotModified userInfo:nil];
    }
    
    if (valid) {
        for (CSCWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(0, expected, self.request.URL);
        }
    } else {
        // Status code invalid and marked as cancelled. Do not call `[self.dataTask cancel]` which may mass up URLSession life cycle
        disposition = NSURLSessionResponseCancel;
    }
    __block typeof(self) strongSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CSCWebImageDownloadReceiveResponseNotification object:strongSelf];
    });
    
    if (completionHandler) {
        completionHandler(disposition);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!self.imageData) {
        self.imageData = [[NSMutableData alloc] initWithCapacity:self.expectedSize];
    }
    [self.imageData appendData:data];
    
    self.receivedSize = self.imageData.length;
    if (self.expectedSize == 0) {
        // Unknown expectedSize, immediately call progressBlock and return
        for (CSCWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(self.receivedSize, self.expectedSize, self.request.URL);
        }
        return;
    }
    
    // Get the finish status
    BOOL finished = (self.receivedSize >= self.expectedSize);
    // Get the current progress
    double currentProgress = (double)self.receivedSize / (double)self.expectedSize;
    double previousProgress = self.previousProgress;
    double progressInterval = currentProgress - previousProgress;
    // Check if we need callback progress
    if (!finished && (progressInterval < self.minimumProgressInterval)) {
        return;
    }
    self.previousProgress = currentProgress;

    if (self.options & CSCWebImageDownloaderProgressiveLoad) {
        // Get the image data
        NSData *imageData = [self.imageData copy];
        
        // progressive decode the image in coder queue
        dispatch_async(self.coderQueue, ^{
            @autoreleasepool {
                UIImage *image = CSCImageLoaderDecodeProgressiveImageData(imageData, self.request.URL, finished, self, [[self class] imageOptionsFromDownloaderOptions:self.options], self.context);
                if (image) {
                    // We do not keep the progressive decoding image even when `finished`=YES. Because they are for view rendering but not take full function from downloader options. And some coders implementation may not keep consistent between progressive decoding and normal decoding.
                    
                    [self callCompletionBlocksWithImage:image imageData:nil error:nil finished:NO];
                }
            }
        });
    }
    
    for (CSCWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
        progressBlock(self.receivedSize, self.expectedSize, self.request.URL);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    NSCachedURLResponse *cachedResponse = proposedResponse;

    if (!(self.options & CSCWebImageDownloaderUseNSURLCache)) {
        // Prevents caching of responses
        cachedResponse = nil;
    }
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // If we already cancel the operation or anything mark the operation finished, don't callback twice
    if (self.isFinished) return;
    
    @synchronized(self) {
        self.dataTask = nil;
        __block typeof(self) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CSCWebImageDownloadStopNotification object:strongSelf];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:CSCWebImageDownloadFinishNotification object:strongSelf];
            }
        });
    }
    
    // make sure to call `[self done]` to mark operation as finished
    if (error) {
        // custom error instead of URLSession error
        if (self.responseError) {
            error = self.responseError;
        }
        [self callCompletionBlocksWithError:error];
        [self done];
    } else {
        if ([self callbacksForKey:kCompletedCallbackKey].count > 0) {
            NSData *imageData = [self.imageData copy];
            self.imageData = nil;
            if (imageData) {
                /**  if you specified to only use cached data via `CSCWebImageDownloaderIgnoreCachedResponse`,
                 *  then we should check if the cached data is equal to image data
                 */
                if (self.options & CSCWebImageDownloaderIgnoreCachedResponse && [self.cachedData isEqualToData:imageData]) {
                    self.responseError = [NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorCacheNotModified userInfo:nil];
                    // call completion block with not modified error
                    [self callCompletionBlocksWithError:self.responseError];
                    [self done];
                } else {
                    // decode the image in coder queue
                    dispatch_async(self.coderQueue, ^{
                        @autoreleasepool {
                            UIImage *image = CSCImageLoaderDecodeImageData(imageData, self.request.URL, [[self class] imageOptionsFromDownloaderOptions:self.options], self.context);
                            CGSize imageSize = image.size;
                            if (imageSize.width == 0 || imageSize.height == 0) {
                                [self callCompletionBlocksWithError:[NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorBadImageData userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image has 0 pixels"}]];
                            } else {
                                [self callCompletionBlocksWithImage:image imageData:imageData error:nil finished:YES];
                            }
                            [self done];
                        }
                    });
                }
            } else {
                [self callCompletionBlocksWithError:[NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorBadImageData userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}]];
                [self done];
            }
        } else {
            [self done];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (!(self.options & CSCWebImageDownloaderAllowInvalidSSLCertificates)) {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        } else {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    } else {
        if (challenge.previousFailureCount == 0) {
            if (self.credential) {
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark Helper methods
+ (CSCWebImageOptions)imageOptionsFromDownloaderOptions:(CSCWebImageDownloaderOptions)downloadOptions {
    CSCWebImageOptions options = 0;
    if (downloadOptions & CSCWebImageDownloaderScaleDownLargeImages) options |= CSCWebImageScaleDownLargeImages;
    if (downloadOptions & CSCWebImageDownloaderDecodeFirstFrameOnly) options |= CSCWebImageDecodeFirstFrameOnly;
    if (downloadOptions & CSCWebImageDownloaderPreloadAllFrames) options |= CSCWebImagePreloadAllFrames;
    if (downloadOptions & CSCWebImageDownloaderAvoidDecodeImage) options |= CSCWebImageAvoidDecodeImage;
    if (downloadOptions & CSCWebImageDownloaderMatchAnimatedImageClass) options |= CSCWebImageMatchAnimatedImageClass;
    
    return options;
}

- (BOOL)shouldContinueWhenAppEntersBackground {
    return CSC_OPTIONS_CONTAINS(self.options, CSCWebImageDownloaderContinueInBackground);
}

- (void)callCompletionBlocksWithError:(nullable NSError *)error {
    [self callCompletionBlocksWithImage:nil imageData:nil error:error finished:YES];
}

- (void)callCompletionBlocksWithImage:(nullable UIImage *)image
                            imageData:(nullable NSData *)imageData
                                error:(nullable NSError *)error
                             finished:(BOOL)finished {
    NSArray<id> *completionBlocks = [self callbacksForKey:kCompletedCallbackKey];
    dispatch_main_async_safe(^{
        for (CSCWebImageDownloaderCompletedBlock completedBlock in completionBlocks) {
            completedBlock(image, imageData, error, finished);
        }
    });
}

@end

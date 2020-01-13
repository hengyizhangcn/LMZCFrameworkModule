/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCWebImageDownloader.h"
#import "CSCWebImageDownloaderConfig.h"
#import "CSCWebImageDownloaderOperation.h"
#import "CSCWebImageError.h"
#import "CSCInternalMacros.h"

NSNotificationName const CSCWebImageDownloadStartNotification = @"CSCWebImageDownloadStartNotification";
NSNotificationName const CSCWebImageDownloadReceiveResponseNotification = @"CSCWebImageDownloadReceiveResponseNotification";
NSNotificationName const CSCWebImageDownloadStopNotification = @"CSCWebImageDownloadStopNotification";
NSNotificationName const CSCWebImageDownloadFinishNotification = @"CSCWebImageDownloadFinishNotification";

static void * CSCWebImageDownloaderContext = &CSCWebImageDownloaderContext;

@interface CSCWebImageDownloadToken ()

@property (nonatomic, strong, nullable, readwrite) NSURL *url;
@property (nonatomic, strong, nullable, readwrite) NSURLRequest *request;
@property (nonatomic, strong, nullable, readwrite) NSURLResponse *response;
@property (nonatomic, weak, nullable, readwrite) id downloadOperationCancelToken;
@property (nonatomic, weak, nullable) NSOperation<CSCWebImageDownloaderOperation> *downloadOperation;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype)new  NS_UNAVAILABLE;
- (nonnull instancetype)initWithDownloadOperation:(nullable NSOperation<CSCWebImageDownloaderOperation> *)downloadOperation;

@end

@interface CSCWebImageDownloader () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic, nonnull) NSOperationQueue *downloadQueue;
@property (strong, nonatomic, nonnull) NSMutableDictionary<NSURL *, NSOperation<CSCWebImageDownloaderOperation> *> *URLOperations;
@property (strong, nonatomic, nullable) NSMutableDictionary<NSString *, NSString *> *HTTPHeaders;
@property (strong, nonatomic, nonnull) dispatch_semaphore_t HTTPHeadersLock; // A lock to keep the access to `HTTPHeaders` thread-safe
@property (strong, nonatomic, nonnull) dispatch_semaphore_t operationsLock; // A lock to keep the access to `URLOperations` thread-safe

// The session in which data tasks will run
@property (strong, nonatomic) NSURLSession *session;

@end

@implementation CSCWebImageDownloader

+ (void)initialize {
    // Bind CSCNetworkActivityIndicator if available (download it here: http://github.com/rs/CSCNetworkActivityIndicator )
    // To use it, just add #import "CSCNetworkActivityIndicator.h" in addition to the CSCWebImage import
    if (NSClassFromString(@"CSCNetworkActivityIndicator")) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id activityIndicator = [NSClassFromString(@"CSCNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
#pragma clang diagnostic pop

        // Remove observer in case it was previously added.
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:CSCWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:CSCWebImageDownloadStopNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"startActivity")
                                                     name:CSCWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"stopActivity")
                                                     name:CSCWebImageDownloadStopNotification object:nil];
    }
}

+ (nonnull instancetype)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    return [self initWithConfig:CSCWebImageDownloaderConfig.defaultDownloaderConfig];
}

- (instancetype)initWithConfig:(CSCWebImageDownloaderConfig *)config {
    self = [super init];
    if (self) {
        if (!config) {
            config = CSCWebImageDownloaderConfig.defaultDownloaderConfig;
        }
        _config = [config copy];
        [_config addObserver:self forKeyPath:NSStringFromSelector(@selector(maxConcurrentDownloads)) options:0 context:CSCWebImageDownloaderContext];
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = _config.maxConcurrentDownloads;
        _downloadQueue.name = @"com.hackemist.CSCWebImageDownloader";
        _URLOperations = [NSMutableDictionary new];
        NSMutableDictionary<NSString *, NSString *> *headerDictionary = [NSMutableDictionary dictionary];
        NSString *userAgent = nil;
#if CSC_UIKIT
        // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
        userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#elif CSC_WATCH
        // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
        userAgent = [NSString stringWithFormat:@"%@/%@ (%@; watchOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[WKInterfaceDevice currentDevice] model], [[WKInterfaceDevice currentDevice] systemVersion], [[WKInterfaceDevice currentDevice] screenScale]];
#elif CSC_MAC
        userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
        if (userAgent) {
            if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
                NSMutableString *mutableUserAgent = [userAgent mutableCopy];
                if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                    userAgent = mutableUserAgent;
                }
            }
            headerDictionary[@"User-Agent"] = userAgent;
        }
        headerDictionary[@"Accept"] = @"image/*,*/*;q=0.8";
        _HTTPHeaders = headerDictionary;
        _HTTPHeadersLock = dispatch_semaphore_create(1);
        _operationsLock = dispatch_semaphore_create(1);
        NSURLSessionConfiguration *sessionConfiguration = _config.sessionConfiguration;
        if (!sessionConfiguration) {
            sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        /**
         *  Create the session for this task
         *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
         *  method calls and completion handler calls.
         */
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    }
    return self;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
    
    [self.downloadQueue cancelAllOperations];
    [self.config removeObserver:self forKeyPath:NSStringFromSelector(@selector(maxConcurrentDownloads)) context:CSCWebImageDownloaderContext];
}

- (void)invalidateSessionAndCancel:(BOOL)cancelPendingOperations {
    if (self == [CSCWebImageDownloader sharedDownloader]) {
        return;
    }
    if (cancelPendingOperations) {
        [self.session invalidateAndCancel];
    } else {
        [self.session finishTasksAndInvalidate];
    }
}

- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(nullable NSString *)field {
    if (!field) {
        return;
    }
    CSC_LOCK(self.HTTPHeadersLock);
    [self.HTTPHeaders setValue:value forKey:field];
    CSC_UNLOCK(self.HTTPHeadersLock);
}

- (nullable NSString *)valueForHTTPHeaderField:(nullable NSString *)field {
    if (!field) {
        return nil;
    }
    CSC_LOCK(self.HTTPHeadersLock);
    NSString *value = [self.HTTPHeaders objectForKey:field];
    CSC_UNLOCK(self.HTTPHeadersLock);
    return value;
}

- (nullable CSCWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                                 completed:(CSCWebImageDownloaderCompletedBlock)completedBlock {
    return [self downloadImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (nullable CSCWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                                   options:(CSCWebImageDownloaderOptions)options
                                                  progress:(CSCWebImageDownloaderProgressBlock)progressBlock
                                                 completed:(CSCWebImageDownloaderCompletedBlock)completedBlock {
    return [self downloadImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

- (nullable CSCWebImageDownloadToken *)downloadImageWithURL:(nullable NSURL *)url
                                                   options:(CSCWebImageDownloaderOptions)options
                                                   context:(nullable CSCWebImageContext *)context
                                                  progress:(nullable CSCWebImageDownloaderProgressBlock)progressBlock
                                                 completed:(nullable CSCWebImageDownloaderCompletedBlock)completedBlock {
    // The URL will be used as the key to the callbacks dictionary so it cannot be nil. If it is nil immediately call the completed block with no image or data.
    if (url == nil) {
        if (completedBlock) {
            NSError *error = [NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}];
            completedBlock(nil, nil, error, YES);
        }
        return nil;
    }
    
    CSC_LOCK(self.operationsLock);
    id downloadOperationCancelToken;
    NSOperation<CSCWebImageDownloaderOperation> *operation = [self.URLOperations objectForKey:url];
    // There is a case that the operation may be marked as finished or cancelled, but not been removed from `self.URLOperations`.
    if (!operation || operation.isFinished || operation.isCancelled) {
        operation = [self createDownloaderOperationWithUrl:url options:options context:context];
        if (!operation) {
            CSC_UNLOCK(self.operationsLock);
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:CSCWebImageErrorDomain code:CSCWebImageErrorInvalidDownloadOperation userInfo:@{NSLocalizedDescriptionKey : @"Downloader operation is nil"}];
                completedBlock(nil, nil, error, YES);
            }
            return nil;
        }
        @weakify(self);
        operation.completionBlock = ^{
            @strongify(self);
            if (!self) {
                return;
            }
            CSC_LOCK(self.operationsLock);
            [self.URLOperations removeObjectForKey:url];
            CSC_UNLOCK(self.operationsLock);
        };
        self.URLOperations[url] = operation;
        // Add operation to operation queue only after all configuration done according to Apple's doc.
        // `addOperation:` does not synchronously execute the `operation.completionBlock` so this will not cause deadlock.
        [self.downloadQueue addOperation:operation];
        downloadOperationCancelToken = [operation addHandlersForProgress:progressBlock completed:completedBlock];
    } else {
        // When we reuse the download operation to attach more callbacks, there may be thread safe issue because the getter of callbacks may in another queue (decoding queue or delegate queue)
        // So we lock the operation here, and in `CSCWebImageDownloaderOperation`, we use `@synchonzied (self)`, to ensure the thread safe between these two classes.
        @synchronized (operation) {
            downloadOperationCancelToken = [operation addHandlersForProgress:progressBlock completed:completedBlock];
        }
        if (!operation.isExecuting) {
            if (options & CSCWebImageDownloaderHighPriority) {
                operation.queuePriority = NSOperationQueuePriorityHigh;
            } else if (options & CSCWebImageDownloaderLowPriority) {
                operation.queuePriority = NSOperationQueuePriorityLow;
            } else {
                operation.queuePriority = NSOperationQueuePriorityNormal;
            }
        }
    }
    CSC_UNLOCK(self.operationsLock);
    
    CSCWebImageDownloadToken *token = [[CSCWebImageDownloadToken alloc] initWithDownloadOperation:operation];
    token.url = url;
    token.request = operation.request;
    token.downloadOperationCancelToken = downloadOperationCancelToken;
    
    return token;
}

- (nullable NSOperation<CSCWebImageDownloaderOperation> *)createDownloaderOperationWithUrl:(nonnull NSURL *)url
                                                                                  options:(CSCWebImageDownloaderOptions)options
                                                                                  context:(nullable CSCWebImageContext *)context {
    NSTimeInterval timeoutInterval = self.config.downloadTimeout;
    if (timeoutInterval == 0.0) {
        timeoutInterval = 15.0;
    }
    
    // In order to prevent from potential duplicate caching (NSURLCache + CSCImageCache) we disable the cache for image requests if told otherwise
    NSURLRequestCachePolicy cachePolicy = options & CSCWebImageDownloaderUseNSURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData;
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
    mutableRequest.HTTPShouldHandleCookies = CSC_OPTIONS_CONTAINS(options, CSCWebImageDownloaderHandleCookies);
    mutableRequest.HTTPShouldUsePipelining = YES;
    CSC_LOCK(self.HTTPHeadersLock);
    mutableRequest.allHTTPHeaderFields = self.HTTPHeaders;
    CSC_UNLOCK(self.HTTPHeadersLock);
    id<CSCWebImageDownloaderRequestModifier> requestModifier;
    if ([context valueForKey:CSCWebImageContextDownloadRequestModifier]) {
        requestModifier = [context valueForKey:CSCWebImageContextDownloadRequestModifier];
    } else {
        requestModifier = self.requestModifier;
    }
    
    NSURLRequest *request;
    if (requestModifier) {
        NSURLRequest *modifiedRequest = [requestModifier modifiedRequestWithRequest:[mutableRequest copy]];
        // If modified request is nil, early return
        if (!modifiedRequest) {
            return nil;
        } else {
            request = [modifiedRequest copy];
        }
    } else {
        request = [mutableRequest copy];
    }
    Class operationClass = self.config.operationClass;
    if (operationClass && [operationClass isSubclassOfClass:[NSOperation class]] && [operationClass conformsToProtocol:@protocol(CSCWebImageDownloaderOperation)]) {
        // Custom operation class
    } else {
        operationClass = [CSCWebImageDownloaderOperation class];
    }
    NSOperation<CSCWebImageDownloaderOperation> *operation = [[operationClass alloc] initWithRequest:request inSession:self.session options:options context:context];
    
    if ([operation respondsToSelector:@selector(setCredential:)]) {
        if (self.config.urlCredential) {
            operation.credential = self.config.urlCredential;
        } else if (self.config.username && self.config.password) {
            operation.credential = [NSURLCredential credentialWithUser:self.config.username password:self.config.password persistence:NSURLCredentialPersistenceForSession];
        }
    }
        
    if ([operation respondsToSelector:@selector(setMinimumProgressInterval:)]) {
        operation.minimumProgressInterval = MIN(MAX(self.config.minimumProgressInterval, 0), 1);
    }
    
    if (options & CSCWebImageDownloaderHighPriority) {
        operation.queuePriority = NSOperationQueuePriorityHigh;
    } else if (options & CSCWebImageDownloaderLowPriority) {
        operation.queuePriority = NSOperationQueuePriorityLow;
    }
    
    if (self.config.executionOrder == CSCWebImageDownloaderLIFOExecutionOrder) {
        // Emulate LIFO execution order by systematically, each previous adding operation can dependency the new operation
        // This can gurantee the new operation to be execulated firstly, even if when some operations finished, meanwhile you appending new operations
        // Just make last added operation dependents new operation can not solve this problem. See test case #test15DownloaderLIFOExecutionOrder
        for (NSOperation *pendingOperation in self.downloadQueue.operations) {
            [pendingOperation addDependency:operation];
        }
    }
    
    return operation;
}

- (void)cancelAllDownloads {
    [self.downloadQueue cancelAllOperations];
}

#pragma mark - Properties

- (BOOL)isSuspended {
    return self.downloadQueue.isSuspended;
}

- (void)setSuspended:(BOOL)suspended {
    self.downloadQueue.suspended = suspended;
}

- (NSUInteger)currentDownloadCount {
    return self.downloadQueue.operationCount;
}

- (NSURLSessionConfiguration *)sessionConfiguration {
    return self.session.configuration;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == CSCWebImageDownloaderContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(maxConcurrentDownloads))]) {
            self.downloadQueue.maxConcurrentOperationCount = self.config.maxConcurrentDownloads;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Helper methods

- (NSOperation<CSCWebImageDownloaderOperation> *)operationWithTask:(NSURLSessionTask *)task {
    NSOperation<CSCWebImageDownloaderOperation> *returnOperation = nil;
    for (NSOperation<CSCWebImageDownloaderOperation> *operation in self.downloadQueue.operations) {
        if ([operation respondsToSelector:@selector(dataTask)]) {
            if (operation.dataTask.taskIdentifier == task.taskIdentifier) {
                returnOperation = operation;
                break;
            }
        }
    }
    return returnOperation;
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<CSCWebImageDownloaderOperation> *dataOperation = [self operationWithTask:dataTask];
    if ([dataOperation respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        [dataOperation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(NSURLSessionResponseAllow);
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<CSCWebImageDownloaderOperation> *dataOperation = [self operationWithTask:dataTask];
    if ([dataOperation respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [dataOperation URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<CSCWebImageDownloaderOperation> *dataOperation = [self operationWithTask:dataTask];
    if ([dataOperation respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
        [dataOperation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(proposedResponse);
        }
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<CSCWebImageDownloaderOperation> *dataOperation = [self operationWithTask:task];
    if ([dataOperation respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [dataOperation URLSession:session task:task didCompleteWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<CSCWebImageDownloaderOperation> *dataOperation = [self operationWithTask:task];
    if ([dataOperation respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)]) {
        [dataOperation URLSession:session task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(request);
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<CSCWebImageDownloaderOperation> *dataOperation = [self operationWithTask:task];
    if ([dataOperation respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
        [dataOperation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    }
}

@end

@implementation CSCWebImageDownloadToken

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CSCWebImageDownloadReceiveResponseNotification object:nil];
}

- (instancetype)initWithDownloadOperation:(NSOperation<CSCWebImageDownloaderOperation> *)downloadOperation {
    self = [super init];
    if (self) {
        _downloadOperation = downloadOperation;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadReceiveResponse:) name:CSCWebImageDownloadReceiveResponseNotification object:downloadOperation];
    }
    return self;
}

- (void)downloadReceiveResponse:(NSNotification *)notification {
    NSOperation<CSCWebImageDownloaderOperation> *downloadOperation = notification.object;
    if (downloadOperation && downloadOperation == self.downloadOperation) {
        self.response = downloadOperation.response;
    }
}

- (void)cancel {
    @synchronized (self) {
        if (self.isCancelled) {
            return;
        }
        self.cancelled = YES;
        [self.downloadOperation cancel:self.downloadOperationCancelToken];
        self.downloadOperationCancelToken = nil;
    }
}

@end

@implementation CSCWebImageDownloader (CSCImageLoader)

- (BOOL)canRequestImageForURL:(NSURL *)url {
    if (!url) {
        return NO;
    }
    // Always pass YES to let URLSession or custom download operation to determine
    return YES;
}

- (id<CSCWebImageOperation>)requestImageWithURL:(NSURL *)url options:(CSCWebImageOptions)options context:(CSCWebImageContext *)context progress:(CSCImageLoaderProgressBlock)progressBlock completed:(CSCImageLoaderCompletedBlock)completedBlock {
    UIImage *cachedImage = context[CSCWebImageContextLoaderCachedImage];
    
    CSCWebImageDownloaderOptions downloaderOptions = 0;
    if (options & CSCWebImageLowPriority) downloaderOptions |= CSCWebImageDownloaderLowPriority;
    if (options & CSCWebImageProgressiveLoad) downloaderOptions |= CSCWebImageDownloaderProgressiveLoad;
    if (options & CSCWebImageRefreshCached) downloaderOptions |= CSCWebImageDownloaderUseNSURLCache;
    if (options & CSCWebImageContinueInBackground) downloaderOptions |= CSCWebImageDownloaderContinueInBackground;
    if (options & CSCWebImageHandleCookies) downloaderOptions |= CSCWebImageDownloaderHandleCookies;
    if (options & CSCWebImageAllowInvalidSSLCertificates) downloaderOptions |= CSCWebImageDownloaderAllowInvalidSSLCertificates;
    if (options & CSCWebImageHighPriority) downloaderOptions |= CSCWebImageDownloaderHighPriority;
    if (options & CSCWebImageScaleDownLargeImages) downloaderOptions |= CSCWebImageDownloaderScaleDownLargeImages;
    if (options & CSCWebImageAvoidDecodeImage) downloaderOptions |= CSCWebImageDownloaderAvoidDecodeImage;
    if (options & CSCWebImageDecodeFirstFrameOnly) downloaderOptions |= CSCWebImageDownloaderDecodeFirstFrameOnly;
    if (options & CSCWebImagePreloadAllFrames) downloaderOptions |= CSCWebImageDownloaderPreloadAllFrames;
    if (options & CSCWebImageMatchAnimatedImageClass) downloaderOptions |= CSCWebImageDownloaderMatchAnimatedImageClass;
    
    if (cachedImage && options & CSCWebImageRefreshCached) {
        // force progressive off if image already cached but forced refreshing
        downloaderOptions &= ~CSCWebImageDownloaderProgressiveLoad;
        // ignore image read from NSURLCache if image if cached but force refreshing
        downloaderOptions |= CSCWebImageDownloaderIgnoreCachedResponse;
    }
    
    return [self downloadImageWithURL:url options:downloaderOptions context:context progress:progressBlock completed:completedBlock];
}

- (BOOL)shouldBlockFailedURLWithURL:(NSURL *)url error:(NSError *)error {
    BOOL shouldBlockFailedURL;
    // Filter the error domain and check error codes
    if ([error.domain isEqualToString:CSCWebImageErrorDomain]) {
        shouldBlockFailedURL = (   error.code == CSCWebImageErrorInvalidURL
                                || error.code == CSCWebImageErrorBadImageData);
    } else if ([error.domain isEqualToString:NSURLErrorDomain]) {
        shouldBlockFailedURL = (   error.code != NSURLErrorNotConnectedToInternet
                                && error.code != NSURLErrorCancelled
                                && error.code != NSURLErrorTimedOut
                                && error.code != NSURLErrorInternationalRoamingOff
                                && error.code != NSURLErrorDataNotAllowed
                                && error.code != NSURLErrorCannotFindHost
                                && error.code != NSURLErrorCannotConnectToHost
                                && error.code != NSURLErrorNetworkConnectionLost);
    } else {
        shouldBlockFailedURL = NO;
    }
    return shouldBlockFailedURL;
}

@end

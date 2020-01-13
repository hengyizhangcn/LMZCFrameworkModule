/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCImageTransformer.h"
#import "UIColor+CSCHexString.h"
#if CSC_UIKIT || CSC_MAC
#import <CoreImage/CoreImage.h>
#endif

// Separator for different transformerKey, for example, `image.png` |> flip(YES,NO) |> rotate(pi/4,YES) => 'image-CSCImageFlippingTransformer(1,0)-CSCImageRotationTransformer(0.78539816339,1).png'
static NSString * const CSCImageTransformerKeySeparator = @"-";

NSString * _Nullable CSCTransformedKeyForKey(NSString * _Nullable key, NSString * _Nonnull transformerKey) {
    if (!key || !transformerKey) {
        return nil;
    }
    // Find the file extension
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    if (ext.length > 0) {
        // For non-file URL
        if (keyURL && !keyURL.isFileURL) {
            // keep anything except path (like URL query)
            NSURLComponents *component = [NSURLComponents componentsWithURL:keyURL resolvingAgainstBaseURL:NO];
            component.path = [[[component.path.stringByDeletingPathExtension stringByAppendingString:CSCImageTransformerKeySeparator] stringByAppendingString:transformerKey] stringByAppendingPathExtension:ext];
            return component.URL.absoluteString;
        } else {
            // file URL
            return [[[key.stringByDeletingPathExtension stringByAppendingString:CSCImageTransformerKeySeparator] stringByAppendingString:transformerKey] stringByAppendingPathExtension:ext];
        }
    } else {
        return [[key stringByAppendingString:CSCImageTransformerKeySeparator] stringByAppendingString:transformerKey];
    }
}

@interface CSCImagePipelineTransformer ()

@property (nonatomic, copy, readwrite, nonnull) NSArray<id<CSCImageTransformer>> *transformers;
@property (nonatomic, copy, readwrite) NSString *transformerKey;

@end

@implementation CSCImagePipelineTransformer

+ (instancetype)transformerWithTransformers:(NSArray<id<CSCImageTransformer>> *)transformers {
    CSCImagePipelineTransformer *transformer = [CSCImagePipelineTransformer new];
    transformer.transformers = transformers;
    transformer.transformerKey = [[self class] cacheKeyForTransformers:transformers];
    
    return transformer;
}

+ (NSString *)cacheKeyForTransformers:(NSArray<id<CSCImageTransformer>> *)transformers {
    if (transformers.count == 0) {
        return @"";
    }
    NSMutableArray<NSString *> *cacheKeys = [NSMutableArray arrayWithCapacity:transformers.count];
    [transformers enumerateObjectsUsingBlock:^(id<CSCImageTransformer>  _Nonnull transformer, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *cacheKey = transformer.transformerKey;
        [cacheKeys addObject:cacheKey];
    }];
    
    return [cacheKeys componentsJoinedByString:CSCImageTransformerKeySeparator];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    UIImage *transformedImage = image;
    for (id<CSCImageTransformer> transformer in self.transformers) {
        transformedImage = [transformer transformedImageWithImage:transformedImage forKey:key];
    }
    return transformedImage;
}

@end

@interface CSCImageRoundCornerTransformer ()

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CSCRectCorner corners;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong, nullable) UIColor *borderColor;

@end

@implementation CSCImageRoundCornerTransformer

+ (instancetype)transformerWithRadius:(CGFloat)cornerRadius corners:(CSCRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    CSCImageRoundCornerTransformer *transformer = [CSCImageRoundCornerTransformer new];
    transformer.cornerRadius = cornerRadius;
    transformer.corners = corners;
    transformer.borderWidth = borderWidth;
    transformer.borderColor = borderColor;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"CSCImageRoundCornerTransformer(%f,%lu,%f,%@)", self.cornerRadius, (unsigned long)self.corners, self.borderWidth, self.borderColor.sd_hexString];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image sd_roundedCornerImageWithRadius:self.cornerRadius corners:self.corners borderWidth:self.borderWidth borderColor:self.borderColor];
}

@end

@interface CSCImageResizingTransformer ()

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CSCImageScaleMode scaleMode;

@end

@implementation CSCImageResizingTransformer

+ (instancetype)transformerWithSize:(CGSize)size scaleMode:(CSCImageScaleMode)scaleMode {
    CSCImageResizingTransformer *transformer = [CSCImageResizingTransformer new];
    transformer.size = size;
    transformer.scaleMode = scaleMode;
    
    return transformer;
}

- (NSString *)transformerKey {
    CGSize size = self.size;
    return [NSString stringWithFormat:@"CSCImageResizingTransformer({%f,%f},%lu)", size.width, size.height, (unsigned long)self.scaleMode];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image sd_resizedImageWithSize:self.size scaleMode:self.scaleMode];
}

@end

@interface CSCImageCroppingTransformer ()

@property (nonatomic, assign) CGRect rect;

@end

@implementation CSCImageCroppingTransformer

+ (instancetype)transformerWithRect:(CGRect)rect {
    CSCImageCroppingTransformer *transformer = [CSCImageCroppingTransformer new];
    transformer.rect = rect;
    
    return transformer;
}

- (NSString *)transformerKey {
    CGRect rect = self.rect;
    return [NSString stringWithFormat:@"CSCImageCroppingTransformer({%f,%f,%f,%f})", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image sd_croppedImageWithRect:self.rect];
}

@end

@interface CSCImageFlippingTransformer ()

@property (nonatomic, assign) BOOL horizontal;
@property (nonatomic, assign) BOOL vertical;

@end

@implementation CSCImageFlippingTransformer

+ (instancetype)transformerWithHorizontal:(BOOL)horizontal vertical:(BOOL)vertical {
    CSCImageFlippingTransformer *transformer = [CSCImageFlippingTransformer new];
    transformer.horizontal = horizontal;
    transformer.vertical = vertical;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"CSCImageFlippingTransformer(%d,%d)", self.horizontal, self.vertical];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image sd_flippedImageWithHorizontal:self.horizontal vertical:self.vertical];
}

@end

@interface CSCImageRotationTransformer ()

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) BOOL fitSize;

@end

@implementation CSCImageRotationTransformer

+ (instancetype)transformerWithAngle:(CGFloat)angle fitSize:(BOOL)fitSize {
    CSCImageRotationTransformer *transformer = [CSCImageRotationTransformer new];
    transformer.angle = angle;
    transformer.fitSize = fitSize;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"CSCImageRotationTransformer(%f,%d)", self.angle, self.fitSize];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image sd_rotatedImageWithAngle:self.angle fitSize:self.fitSize];
}

@end

#pragma mark - Image Blending

@interface CSCImageTintTransformer ()

@property (nonatomic, strong, nonnull) UIColor *tintColor;

@end

@implementation CSCImageTintTransformer

+ (instancetype)transformerWithColor:(UIColor *)tintColor {
    CSCImageTintTransformer *transformer = [CSCImageTintTransformer new];
    transformer.tintColor = tintColor;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"CSCImageTintTransformer(%@)", self.tintColor.sd_hexString];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image sd_tintedImageWithColor:self.tintColor];
}

@end

#pragma mark - Image Effect

@interface CSCImageBlurTransformer ()

@property (nonatomic, assign) CGFloat blurRadius;

@end

@implementation CSCImageBlurTransformer

+ (instancetype)transformerWithRadius:(CGFloat)blurRadius {
    CSCImageBlurTransformer *transformer = [CSCImageBlurTransformer new];
    transformer.blurRadius = blurRadius;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"CSCImageBlurTransformer(%f)", self.blurRadius];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image sd_blurredImageWithRadius:self.blurRadius];
}

@end

#if CSC_UIKIT || CSC_MAC
@interface CSCImageFilterTransformer ()

@property (nonatomic, strong, nonnull) CIFilter *filter;

@end

@implementation CSCImageFilterTransformer

+ (instancetype)transformerWithFilter:(CIFilter *)filter {
    CSCImageFilterTransformer *transformer = [CSCImageFilterTransformer new];
    transformer.filter = filter;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"CSCImageFilterTransformer(%@)", self.filter.name];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image sd_filteredImageWithFilter:self.filter];
}

@end
#endif

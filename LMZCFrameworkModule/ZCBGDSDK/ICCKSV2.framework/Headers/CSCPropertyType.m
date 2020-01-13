//
//  CSCPropertyType.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "CSCPropertyType.h"
#import "CSCExtension.h"
#import "CSCFoundation.h"
#import "CSCExtensionConst.h"

@implementation CSCPropertyType

+ (instancetype)cachedTypeWithCode:(NSString *)code
{
    MJExtensionAssertParamNotNil2(code, nil);
    
    static NSMutableDictionary *types;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = [NSMutableDictionary dictionary];
    });
    
    CSCPropertyType *type = types[code];
    if (type == nil) {
        type = [[self alloc] init];
        type.code = code;
        types[code] = type;
    }
    return type;
}

#pragma mark - 公共方法
- (void)setCode:(NSString *)code
{
    _code = code;
    
    MJExtensionAssertParamNotNil(code);
    
    if ([code isEqualToString:CSCPropertyTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [CSCFoundation isClassFromFoundation:_typeClass];
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
        
    } else if ([code isEqualToString:CSCPropertyTypeSEL] ||
               [code isEqualToString:CSCPropertyTypeIvar] ||
               [code isEqualToString:CSCPropertyTypeMethod]) {
        _KVCDisabled = YES;
    }
    
    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[CSCPropertyTypeInt, CSCPropertyTypeShort, CSCPropertyTypeBOOL1, CSCPropertyTypeBOOL2, CSCPropertyTypeFloat, CSCPropertyTypeDouble, CSCPropertyTypeLong, CSCPropertyTypeLongLong, CSCPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:CSCPropertyTypeBOOL1]
            || [lowerCode isEqualToString:CSCPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }
}
@end

#ifndef __CSCExtensionConst__M__
#define __CSCExtensionConst__M__

#import <Foundation/Foundation.h>

/**
 *  成员变量类型（属性类型）
 */
NSString *const CSCPropertyTypeInt = @"i";
NSString *const CSCPropertyTypeShort = @"s";
NSString *const CSCPropertyTypeFloat = @"f";
NSString *const CSCPropertyTypeDouble = @"d";
NSString *const CSCPropertyTypeLong = @"l";
NSString *const CSCPropertyTypeLongLong = @"q";
NSString *const CSCPropertyTypeChar = @"c";
NSString *const CSCPropertyTypeBOOL1 = @"c";
NSString *const CSCPropertyTypeBOOL2 = @"b";
NSString *const CSCPropertyTypePointer = @"*";

NSString *const CSCPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const CSCPropertyTypeMethod = @"^{objc_method=}";
NSString *const CSCPropertyTypeBlock = @"@?";
NSString *const CSCPropertyTypeClass = @"#";
NSString *const CSCPropertyTypeSEL = @":";
NSString *const CSCPropertyTypeId = @"@";

#endif

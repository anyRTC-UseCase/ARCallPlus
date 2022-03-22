//
//  NSObject+ARExtension.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/24.
//

#import "NSObject+ARExtension.h"
#import <objc/runtime.h>
#import "ARUILogin.h"

#define ClassStringForNSDictionary ( @"@\"NSDictionary\"" )
#define ClassStringForNSArray  ( @"@\"NSArray\"" )
#define ClassStringForNSString  ( @"@\"NSString\"" )
#define ClassStringForFloat  ( @"f" )
#define ClassStringForDouble  ( @"d" )
#define ClassStringForInt  ( @"q" )
#define ClassStringForBool  ( @"B" )

@implementation NSString (ARExtension)

- (NSString *)ar_classString {
    NSString *subString = [self substringFromIndex:2];
    subString = [subString substringToIndex:subString.length - 1];
    return subString;
}

@end

@implementation NSObject (ARExtension)

+ (instancetype)ar_objectWithDictionary:(NSDictionary *)dict
{
    id obj = [[[self class] alloc] init];

    NSArray *dictAllKeys = dict.allKeys;
    NSDictionary *objectInArrayDict = [self ar_dictionaryForObjectInArray];
    NSArray *objectInArrayAllKeys = objectInArrayDict.allKeys;
    NSDictionary *propertyNameDict = [self ar_dictionaryForPropertyNameMap];
    NSArray *propertyNameAllKeys = propertyNameDict.allKeys;
    NSDictionary *propertyNameComplexDict = [self ar_dictionaryForPropertyNameComplexMap];
    NSArray *propertyNameComplexAllKeys = propertyNameComplexDict.allKeys;
    
    
    unsigned int outCount;
    Ivar *ivars =  class_copyIvarList([self class], &outCount);
    while (*ivars != NULL) {

        NSString *ivar_name = [NSString stringWithUTF8String:ivar_getName(*ivars)];
        NSString *ivar_type = [NSString stringWithUTF8String:ivar_getTypeEncoding(*ivars)];
        if ([[ivar_name substringToIndex:1] isEqualToString:@"_"]) {
            ivar_name = [ivar_name substringFromIndex:1];
        }
        NSString *map_ivar_name = ivar_name;
        
        // 处理属性名映射 - 直接映射
        if (propertyNameAllKeys.count > 0) {
            if ([propertyNameAllKeys containsObject:ivar_name]) {
                map_ivar_name = propertyNameDict[ivar_name];
                if (map_ivar_name.length <= 0) {
                    map_ivar_name = ivar_name;
                }
            }
        }
        
        // 处理属性名映射 - 复杂映射
        if (propertyNameComplexAllKeys.count > 0) {
            if ([propertyNameComplexAllKeys containsObject:ivar_name]) {
                map_ivar_name = propertyNameComplexDict[ivar_name];
                if (map_ivar_name.length <= 0) {
                    map_ivar_name = ivar_name;
                }else {
                    id value_keyPath = [self valueWithObject:dict keyPath:map_ivar_name];
                    if (value_keyPath) {
                        [obj setValue:value_keyPath forKey:ivar_name];
                    }
                    
                     ivars++;
                    continue;
                }
            }
        }
        
        if ([dictAllKeys containsObject:map_ivar_name]) {
            
            // dict有对应Key，就把key对应value赋值给objct对应属性
            id ivar_value = dict[map_ivar_name];

            if (ivar_value) {
                
                [obj setValue:ivar_value forKeyPath:ivar_name];
                
                // 处理dictionaryObjectInArray
                if ([ivar_type isEqualToString:ClassStringForNSArray]) {
                    if (objectInArrayAllKeys.count > 0) {
                        if ([objectInArrayAllKeys containsObject:ivar_name] ) {
                            id objectInArrayValue = objectInArrayDict[ivar_name];
                            if (objectInArrayValue) {
                                ivar_value = [NSClassFromString(objectInArrayValue) ar_objectsArrayWithDictionaryArray:dict[ivar_name]];
                                if (ivar_value) {
                                    [obj setValue:ivar_value forKey:ivar_name];
                                }
                            }
                        }
                    }
                }// end if ([ivar_type isEqualToString:nsarrayClassString])
                
                // 处理自定义类型
                if ([ivar_value isKindOfClass:[NSDictionary class]]) {
                    if (![ivar_type isEqualToString:ClassStringForNSDictionary]) {
                        ivar_value = [NSClassFromString([ivar_type ar_classString]) ar_objectWithDictionary:ivar_value];
                        [obj setValue:ivar_value forKey:ivar_name];
                    }
                }

            }// end if(value)
        }// end if(allkeys....)

        ivars++;
    }// end while
    
    return obj;
}

+ (NSMutableArray *)ar_objectsArrayWithDictionaryArray:(NSArray *)dictArray
{
    NSMutableArray *objsArray = [NSMutableArray array];
    for (NSDictionary *dict in dictArray) {
        [objsArray addObject:[self ar_objectWithDictionary:dict]];
    }
    return objsArray;
}

+ (id)valueWithObject:(id)object keyPath:(NSString *)keyPath
{
    if (!object) {
        return nil;
    }
    
    if (keyPath.length > 0) {
        
        if ([[keyPath substringToIndex:1] isEqualToString:@"."]) {
            keyPath = [keyPath substringFromIndex:1];
        }
        NSString *key = [keyPath componentsSeparatedByString:@"."].firstObject;
        keyPath = [keyPath substringFromIndex:key.length];
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            return [self valueWithObject:object[key] keyPath:keyPath];
        }else if ([object isKindOfClass:[NSArray class]]){
            if (![key containsString:@"@"]) {
                return nil;
            }else {
                if ([key isEqualToString:@"@@"]) {
                    return [self valueWithObject:[object lastObject] keyPath:keyPath];
                }else {
                    int index = [[key substringToIndex:1] intValue];
                    return [self valueWithObject:object[index] keyPath:keyPath];
                }
            }
        }else {
            return nil;
        }
        
    }else {
        return object;
        
    }
    return nil;
}

+ (NSMutableDictionary *)ar_dictionaryWithObject:(id)object
{
    NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    objc_property_t *properties;
    if ([object isMemberOfClass:[ARCallUser class]]) {
        properties = class_copyPropertyList([object class], &count);
    } else {
        properties = class_copyPropertyList([[object superclass] class], &count);
    }

    for (int i = 0; i < count; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id propertyValue = [object valueForKey:propertyName];
        if (propertyValue) {
            [userDic setObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    return userDic;
}


+ (NSMutableArray *)ar_dictionaryArrayWithObjectsArray:(NSArray *)objectsArray
{
    NSMutableArray *dictArray = [NSMutableArray array];
    for (id object in objectsArray) {
        [dictArray addObject:[[object class] ar_dictionaryWithObject:object]];
    }
    return dictArray;
}

+ (id)valueForkeyPath:(NSString *)keyPath object:(id)object
{
    if (!object) {
        return nil;
    }
    
    if (keyPath.length > 0) {
        if ([[keyPath substringFromIndex:keyPath.length - 1] isEqualToString:@"."]) {
            keyPath = [keyPath substringToIndex:keyPath.length - 1];
        }
        if (![keyPath containsString:@"."]) {
            return object;
        }
        NSString *key = [keyPath componentsSeparatedByString:@"."].lastObject;
        keyPath = [keyPath substringToIndex:( keyPath.length - key.length)];
        
        if (key.length > 0) {
            if ([key containsString:@"@"]) {
                NSMutableArray *mArray = [NSMutableArray array];
                [mArray addObject:object];
                return [self valueForkeyPath:keyPath object:mArray];
            }else {
                NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
                [mDict setObject:object forKey:key];
                return [self valueForkeyPath:keyPath object:mDict];
            }
        }
        
        
    }else {
        return object;
        
    }
    
    
    
    return nil;
}

#pragma mark -
+ (NSDictionary *)ar_dictionaryForObjectInArray
{
    return nil;
}

+ (NSDictionary *)ar_dictionaryForPropertyNameMap
{
    return nil;
}

+ (NSDictionary *)ar_dictionaryForPropertyNameComplexMap
{
    return nil;
}

#pragma mark - isSystemClass
+ (BOOL)isSystemClassWithObject:(id)object
{
    NSBundle *mainB = [NSBundle bundleForClass:[object class]];
    if (mainB == [NSBundle mainBundle]) {
        return NO;
    }else {
        return YES;
    }
}

+ (BOOL)isSystemClassWithIvarType:(NSString *)ivar_type
{
    if (
        [ivar_type isEqualToString:ClassStringForNSDictionary] ||
        [ivar_type isEqualToString:ClassStringForNSArray] ||
        [ivar_type isEqualToString:ClassStringForNSString] ||
        [ivar_type isEqualToString:ClassStringForDouble] ||
        [ivar_type isEqualToString:ClassStringForFloat] ||
        [ivar_type isEqualToString:ClassStringForInt] ||
        [ivar_type isEqualToString:ClassStringForBool]
        ) {
        return YES;
    }else {
        return NO;
    }
}

+ (BOOL)isSystemClassByDescriptionWithObject:(NSObject *)object
{
    NSString *regex = @"<[a-zA-z]+: 0x([0-9]|[a-f])+>";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:object.description];
    return !isValid;
}




@end

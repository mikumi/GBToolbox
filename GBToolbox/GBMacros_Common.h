//
//  GBMacros.h
//  GBToolbox
//
//  Created by Luka Mirosevic on 11/09/2012.
//  Copyright (c) 2012 Luka Mirosevic. All rights reserved.
//

#ifndef Macros_Common_h
#define Macros_Common_h

#import <objc/runtime.h>

//Variadic macros
#define __NARGS(unused, _1, _2, _3, _4, _5, VAL, ...) VAL
#define NARGS(...) __NARGS(unused, ## __VA_ARGS__, 5, 4, 3, 2, 1, 0)

//Macro indirections
#define STRINGIFY2(string) [NSString stringWithFormat:@"%s", #string]
#define STRINGIFY(string) STRINGIFY2(string)

//Logging
#define l(...) NSLog(__VA_ARGS__)

//Localisation
#define _s(string, description) NSLocalizedString(string, description)

//Lazy instantiation
#define _lazy(Class, propertyName, ivar) -(Class *)propertyName {if (!ivar) {ivar = [[Class alloc] init];}return ivar;}

//Message forwarding
#define _forwardMessages(target) -(id)forwardingTargetForSelector:(SEL)selector { if ([target respondsToSelector:selector]) return target; return nil; }
#define _forwardUnimplementedMessages(target) -(id)forwardingTargetForSelector:(SEL)selector { if ([self respondsToSelector:selector]) { return self; } else if ([target respondsToSelector:selector]) { return target; } else return nil; }

//Abstract methods
#define _abstract { @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"The class %@ does not implement the required %s method.", NSStringFromClass(self.class), __PRETTY_FUNCTION__] userInfo:nil]; }

//Associated objects
static inline int AssociationPolicyFromStorageAndAtomicity(NSString *storage, NSString *atomicity) {
    //_Pragma("clang diagnostic pop")
    if ([atomicity isEqualToString:@"atomic"]) {
        if ([storage isEqualToString:@"assign"] || [storage isEqualToString:@"weak"]) {
            return OBJC_ASSOCIATION_ASSIGN;
        }
        else if ([storage isEqualToString:@"retain"] || [storage isEqualToString:@"strong"]) {
            return OBJC_ASSOCIATION_RETAIN;
        }
        else if ([storage isEqualToString:@"copy"]) {
            return OBJC_ASSOCIATION_COPY;
        }
        else {
            NSLog(@"No such storage policy: %@", storage);
            assert(false);
        }
    }
    else if ([atomicity isEqualToString:@"nonatomic"]) {
        if ([storage isEqualToString:@"assign"] || [storage isEqualToString:@"weak"]) {
            return OBJC_ASSOCIATION_ASSIGN;
        }
        else if ([storage isEqualToString:@"retain"] || [storage isEqualToString:@"strong"]) {
            return OBJC_ASSOCIATION_RETAIN_NONATOMIC;
        }
        else if ([storage isEqualToString:@"copy"]) {
            return OBJC_ASSOCIATION_COPY_NONATOMIC;
        }
        else {
            NSLog(@"No such storage policy: %@", storage);
            assert(false);
        }
    }
    else {
        NSLog(@"No such atomicity policy: %@", atomicity);
        assert(false);
    }
    
    return 0;
}
#define _associatedObject(storage, atomicity, type, getter, setter) static char gb_##getter##_key; -(void)setter:(type)getter { objc_setAssociatedObject(self, &gb_##getter##_key, getter, AssociationPolicyFromStorageAndAtomicity(STRINGIFY(storage), STRINGIFY(atomicity))); } -(type)getter { return objc_getAssociatedObject(self, &gb_##getter##_key); }


//Set
#define _set(...) ([NSSet setWithArray:@[__VA_ARGS__]])

//Resource Bundles
#define _res(bundle, resource) [NSString stringWithFormat:@"%@Resources.bundle/%@", bundle, resource]

//Singleton
#define _singleton(accessor) +(instancetype)accessor {static id accessor;@synchronized(self) {if (!accessor) {accessor = [[self alloc] init];}return accessor;}}

//Bitmasks
static inline BOOL _bitmask(int var, int comparison) {
    return ((var & comparison) == comparison);
}
#define _attachToBitmask(targetBitmask, whatToAttach, shouldAttach) if (shouldAttach) { targetBitmask |= whatToAttach; }

//Arguments
static inline BOOL _argumentIsSet(NSString *argument) {
    return [[[NSProcessInfo processInfo] arguments] containsObject:argument];
}
static inline NSString *_argumentValue(NSString *argument) {
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    NSUInteger index = [arguments indexOfObject:argument];
    if (index != NSNotFound && arguments.count >= (index + 2)) {
        return arguments[index + 1];
    }
    else {
        return nil;
    }
}

//Debugging
static inline NSString * _b(BOOL expression) {if (expression) {return @"YES";} else {return @"NO";}}
static inline void _lRect(CGRect rect) {l(@"Rect: %f %f %f %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);}
static inline void _lPoint(CGPoint point) {l(@"Point: %f %f", point.x, point.y);}
static inline void _lSize(CGSize size) {l(@"Size: %f %f", size.width, size.height);}
static inline void _lObject(id object) {l(@"Object: %@", object);}
static inline void _lObjectWithPrefix(NSString *prefix, id object) {l(@"%@: %@", prefix, object);}
static inline void _lString(NSString *string) {l(@"String: %@", string);}
static inline void _lFloating(CGFloat floating) {l(@"Floating: %f", floating);}
static inline void _lIntegral(NSInteger integer) {l(@"Integer: %ld", (long)integer);}
static inline void _lBoolean(BOOL boolean) {l(@"Boolean: %@", _b(boolean));}

//Equality checking (where nil == nil evals to YES)
#define IsEqual(a, b) ((a == b) || [a isEqual:b])

//Strings
static inline BOOL IsValidString(NSString *string) {
    return ([string isKindOfClass:NSString.class] && string.length > 0);
}

static inline BOOL IsValidAttributedString(NSAttributedString *attributedString) {
    return ([attributedString isKindOfClass:NSAttributedString.class] && attributedString.length > 0);
}

static inline BOOL IsEmptyString(NSString *string) {
    return !IsValidString(string);
}

#define _f(string, ...) ([NSString stringWithFormat:string, __VA_ARGS__])

//Arrays
static inline BOOL IsPopulatedArray(NSArray *array) {
    return ([array isKindOfClass:[NSArray class]] && array.count > 0);
}

//Code introspection
#define IsClassAvailable(classType) ([NSClassFromString(STRINGIFY(classType)) class] ? YES : NO)

//Info.plist
#define InfoPlist [[NSBundle mainBundle] infoDictionary]

//Localization
#define PreferredLanguage [[NSLocale preferredLanguages] objectAtIndex:0]

//Control flow
#define loop while (YES)

//Assertions
#define AssertParameterNotNil(input) if (!input) { @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Input parameter `%@` for method `%s` was nil, expected it not to be nil.", STRINGIFY(input), __PRETTY_FUNCTION__] userInfo:nil]; }
#define AssertParameterNotEmptyArray(input) if (!input || ![input isKindOfClass:[NSArray class]] || (input.count == 0)) { @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Input parameter `%@` for method `%s` was not a non-empty array, expected it to be an array with at least 1 element.", STRINGIFY(input), __PRETTY_FUNCTION__] userInfo:nil]; }
#define AssertParameterIsHomogenousArrayWithElementsOfType(parameter, objectClass) \
if (![parameter isKindOfClass:NSArray.class]) { @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Parameter must be an array, passed in object of type %@", NSStringFromClass([parameter class])] userInfo:nil]; } \
for (id object in parameter) { if (![object isKindOfClass:objectClass]) { @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Array contents must be of type %@, passed in object of type %@", NSStringFromClass(objectClass), NSStringFromClass([object class])] userInfo:nil]; } }


#define AssertVariableNotNil(input) if (!input) { @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Variable `%@` inside method `%s` was nil, expected it not to be nil.", STRINGIFY(input), __PRETTY_FUNCTION__] userInfo:nil]; }
#define AssertVariableIsNil(input) if (input) { @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Variable `%@` inside method `%s` was not nil, expected it to be nil.", STRINGIFY(input), __PRETTY_FUNCTION__] userInfo:nil]; }

#endif

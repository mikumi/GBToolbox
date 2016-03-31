//
//  NSOrderedSet+GBToolbox.h
//  GBToolbox
//
//  Created by Luka Mirosevic on 28/03/16.
//  Copyright © 2016 Luka Mirosevic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOrderedSet (GBToolbox)

/**
 Returns the index of the object that is identical to anObject, or NSNotFound if the set doesn't contain it.
 */
- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject;

/**
 Returns a new array with the elements from the receiver transformed by function.
 */
- (NSOrderedSet *)map:(id(^)(id object))function;

/**
 Fold Left
 */
- (id)foldLeft:(id(^)(id objectA, id objectB))function lastObject:(id)lastObject;

/**
 Fold Right.
 */
- (id)foldRight:(id(^)(id objectA, id objectB))function initialObject:(id)initialObject;

/**
 Synonym for foldLeft
 */
- (id)reduce:(id(^)(id objectA, id objectB))function lastObject:(id)lastObject;

@end

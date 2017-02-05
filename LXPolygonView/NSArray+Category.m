//
//  NSArray+Category.m
//
//
//  Created by Leexin on 15/9/25.
//  Copyright © 2016年 garden. All rights reserved.
//

#import "NSArray+Category.h"

@implementation NSArray (Category)

- (id)safeObjectAtIndex:(NSUInteger)index {
    
    id obj = nil;
    if (index < self.count) {
        obj = [self objectAtIndex:index];
    }
    return obj;
}

@end

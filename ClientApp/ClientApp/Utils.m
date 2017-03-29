//
//  Utils.m
//  ClientApp
//
//  Created by Alexander Davydov on 29/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import "Utils.h"

@implementation Utils


+ (NSString *) randomString
{
    NSInteger nameLength = arc4random_uniform(15);
    
    return [self randomStringWithLength:nameLength];
}

+ (NSString *) randomStringWithLength: (NSInteger) nameLength {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: nameLength];
    
    for (int i = 0; i < nameLength; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

@end

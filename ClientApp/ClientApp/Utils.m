//
//  Utils.m
//  ClientApp
//
//  Created by Alexander Davydov on 29/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import "Utils.h"

@implementation Utils

/*! @brief Creates new random string with length between 0 and 15
 *  @return new random string
 */
+ (NSString *) randomString
{
    NSInteger nameLength = arc4random_uniform(15);
    
    return [self randomStringWithLength:nameLength];
}

/*! @brief Creates new random string with length between 0 and stringLength
 *  @discussion The string will include alphabetic characters include lowercase and uppercase and numbers
 *  @param stringLength - Indicates how long the string will be
 *  @return new random string with specific length
 */
+ (NSString *) randomStringWithLength: (NSInteger) stringLength {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: stringLength];
    
    for (int i = 0; i < stringLength; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

@end

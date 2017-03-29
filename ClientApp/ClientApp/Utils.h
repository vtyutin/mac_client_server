//
//  Utils.h
//  ClientApp
//
//  Created by Alexander Davydov on 29/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

/*! @brief Creates new random string with length between 0 and 15 */
+ (NSString *) randomString;

/*! @brief Creates new random string with length between 0 and stringLength */
+ (NSString *) randomStringWithLength: (NSInteger) stringLength;

@end

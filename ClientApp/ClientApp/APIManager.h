//
//  APIManager.h
//  ClientApp
//
//  Created by Alexander on 25/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject

+ (id)sharedManager;

- (void) signUpWithUsername:(NSString*) name password:(NSString*) password year:(NSNumber*) year handler:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

@end

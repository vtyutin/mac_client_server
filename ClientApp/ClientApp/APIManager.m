//
//  APIManager.m
//  ClientApp
//
//  Created by Alexander on 25/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager

//const NSString* PARAM_URL = @"http://localhost:8181/adduser";
const NSString* PARAM_URL = @"http://192.168.50.201:8181/adduser";


static APIManager *sharedMyManager = nil;

+ (id)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

/*! @brief Send the sign in information to server
 *  @param name - user name
 *  @param password - user password
 *  @param handler - block to handle response
 */
- (void) signInWithUsername:(NSString*) name password:(NSString*) password handler:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    // Prepare data to send
    NSDictionary* json = @{@"login" : name,
                           @"password" : password,
                           };
    
    [self sendJsonRequest:json withHandler:handler];
}


/*! @brief Send the sign in information to server
 *  @param name - user name
 *  @param password - user password
 *  @param year - user birthday year
 *  @param handler - block to handle response
 */
- (void) signUpWithUsername:(NSString*) name password:(NSString*) password year:(NSNumber*) year  handler:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    // Prepare data to send
    NSDictionary* json = @{@"login" : name,
                           @"password" : password,
                           @"birthday" : year,
                           };
    
    [self sendJsonRequest:json withHandler:handler];
}


#pragma mark - Send request base methods

/*! @brief Send new request with json
 *  @param json - dictionary with json data
 *  @param handler - block to handle response
 */
-(void) sendJsonRequest:(NSDictionary*) json withHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:&error];
    
    if (error) {
        handler(nil, nil, error);
    } else {
        NSLog(@"Sending JSON: %@", json);
        [self sendRequestUsingSessionData:data withHandler:handler];
        
    }
}

/*! @brief Send new request with data
 *  @param data - data to send with the responce
 *  @param handler - block to handle response
 */
-(void) sendRequestUsingSessionData:(NSData*) data withHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    NSURL *url = [NSURL URLWithString:[PARAM_URL copy]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;

    // Add heders
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *requestTask = nil;
    
    if (data) {
        requestTask = [session uploadTaskWithRequest:request fromData:data completionHandler:handler];
    } else {
        requestTask = [session dataTaskWithRequest:request completionHandler:handler];
    }
    
    NSLog(@"Sending %@ request: %@ data: %@", request.HTTPMethod, url.absoluteURL, data);
    NSLog(@"Request obj: %@", request);
    
    [requestTask resume];
}

@end

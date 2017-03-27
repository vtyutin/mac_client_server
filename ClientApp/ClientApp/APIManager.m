//
//  APIManager.m
//  ClientApp
//
//  Created by Alexander on 25/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager

const NSString* PARAM_URL = @"http://localhost:8181/adduser";


static APIManager *sharedMyManager = nil;

+ (id)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


- (void) signUpWithUsername:(NSString*) name password:(NSString*) password year:(NSNumber*) year  handler:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    // Prepare data to send
    NSDictionary* json = @{
                           @"login" : name,
                           @"password" : password,
                           @"birthday" : year,
                           };
    
    [self sendJsonRequest:json withHandler:handler];
}


#pragma mark - Send request base methods

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


-(void) sendRequestUsingSessionData:(NSData*) data withHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    
    NSURL *url = [NSURL URLWithString:[PARAM_URL copy]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *requestTask = nil;
    
    if (data) {
        requestTask = [session uploadTaskWithRequest:request fromData:data completionHandler:handler];
    } else {
        requestTask = [session dataTaskWithRequest:request completionHandler:handler];
    }
    
    NSLog(@"Sending %@ request: %@", request.HTTPMethod, url.absoluteURL);
    
    [requestTask resume];
}

@end

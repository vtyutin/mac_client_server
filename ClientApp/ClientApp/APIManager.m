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

/* This method of sending request is deprecated */
-(void) sendRequestUsingURLConnection
{
    NSURL *URL = [NSURL URLWithString:[PARAM_URL copy]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (error) {
                                   NSLog(@"Request Error: %@", error);
                               } else{
                                   NSLog(@"Request succeded: %@", response);
                               }
                               
                           }];
    
}

-(void) sendRequestUsingSession
{
    
    NSURL *url = [NSURL URLWithString:[PARAM_URL copy]];
    
    
    NSURLSessionDataTask *requestTask = [[NSURLSession sharedSession]
                                         dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                             if (error) {
                                                 NSLog(@"Request Error: %@", error);
                                             } else{
                                                 NSLog(@"Request succeded: %@", response);
                                                 NSLog(@"Request Data: %@", data);
                                                 
                                                 NSError* jsonError = nil;
                                                 NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                      options:NULL
                                                                                                        error:&jsonError];
                                                 if (jsonError) {
                                                     NSLog(@"JSON PARSING ERRPR!!!");
                                                 } else {
                                                     NSLog(@"JSON: %@", json);
                                                 }
                                             }
                                         }];
    
    
    [requestTask resume];
}

@end

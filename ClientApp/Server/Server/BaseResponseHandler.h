//
//  BaseResponseHandler.h
//  Server
//
//  Copyright © 2017 Harman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPServer;

@interface BaseResponseHandler : NSObject
{
    CFHTTPMessageRef request;
    NSString *requestMethod;
    NSDictionary *headerFields;
    NSFileHandle *fileHandle;
    HTTPServer *server;
    NSURL *url;
}

+ (NSUInteger)priority;
+ (void)registerHandler:(Class)handlerClass;

+ (BaseResponseHandler *)handlerForRequest:(CFHTTPMessageRef)aRequest
                                fileHandle:(NSFileHandle *)requestFileHandle server:(HTTPServer *)aServer;

- (id)initWithRequest:(CFHTTPMessageRef)aRequest method:(NSString *)method url:(NSURL *)requestURL
         headerFields:(NSDictionary *)requestHeaderFields fileHandle:(NSFileHandle *)requestFileHandle
               server:(HTTPServer *)aServer;
- (void)startResponse;
- (void)endResponse;
@end

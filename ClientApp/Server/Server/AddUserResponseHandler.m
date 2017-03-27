//
//  AddUserResponseHandler.m
//  Server
//
//  Copyright © 2017 Harman. All rights reserved.
//

#import "AddUserResponseHandler.h"
#import "HTTPServer.h"

@implementation AddUserResponseHandler
// load
//
// Implementing the load method and invoking
// [BaseResponseHandler registerHandler:self] causes BaseResponseHandler
// to register this class in the list of registered HTTP response handlers.
//
+ (void)load
{
    [BaseResponseHandler registerHandler:self];
}

// canHandleRequest:method:url:headerFields:
//
// Class method to determine if the response handler class can handle
// a given request.
//
// Parameters:
//    aRequest - the request
//    requestMethod - the request method
//    requestURL - the request URL
//    requestHeaderFields - the request headers
//
// returns YES (if the handler can handle the request), NO (otherwise)
//
+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
                  method:(NSString *)requestMethod
                     url:(NSURL *)requestURL
            headerFields:(NSDictionary *)requestHeaderFields
{    
    if ([requestURL.path hasPrefix:@"/adduser"])
    {
        return YES;
    }
    
    return NO;
}

//
// startResponse
//
// Since this is a simple response, we handle it synchronously by sending
// everything at once.
//
- (void)startResponse
{
    NSDictionary *jsonResponse = [self addUser];
    CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [[jsonResponse valueForKey:@"code"] integerValue], NULL, kCFHTTPVersion1_1);
    
    CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Type", (CFStringRef)@"application/json");
    CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Connection", (CFStringRef)@"close");
    CFHTTPMessageSetBody(response, (__bridge CFDataRef)[[jsonResponse valueForKey:@"data"]  dataUsingEncoding:NSUTF8StringEncoding]);
    
    CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);
    @try
    {
        [fileHandle writeData:(__bridge NSData *)headerData];
    }
    @catch (NSException *exception)
    {
        NSLog(@"exception: %@", exception);
        // Ignore the exception, it normally just means the client
        // closed the connection from the other end.
    }
    @finally
    {
        CFRelease(headerData);
        CFRelease(response);
        [server closeHandler:self];
    }
}

//
// addUser
//
// Handle adduser request and store new user data.
//
- (NSDictionary*)addUser
{
    NSData *data = (__bridge NSData *)(CFHTTPMessageCopyBody(request));
    NSError *error;
    NSDictionary* jsonRequest = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:400], @"code", @"{\"message\": \"invalid data\",\"code\": 400}", @"data", nil];
    }
    NSString *login = [jsonRequest valueForKey:@"login"];
    NSString *password = [jsonRequest valueForKey:@"password"];
    if ([login length] > 0 && [password length] > 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *savedUser = [userDefaults valueForKey:login];
        if (savedUser != nil) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:409], @"code", @"{\"message\": \"user is already existed\",\"code\": 409}", @"data", nil];
        }
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:login, @"login", password, @"password", nil];
        [userDefaults setValue:dictData forKey:login];
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:200], @"code", @"{\"message\": \"ok\",\"code\": 200}", @"data", nil];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:400], @"code", @"{\"message\": \"invalid data\",\"code\": 400}", @"data", nil];
}
@end

/*!
 @header AddUserResponseHandler.h
 
 @brief This is the class for "/adduser" HTTP request handler.
 
 @copyright  2017 Harman
 @version    1.0.0
 */
#import "AddUserResponseHandler.h"
#import "HTTPServer.h"

@implementation AddUserResponseHandler
/*! @brief Implementing the load method and invoking
 @code [BaseResponseHandler registerHandler:self] @endcode causes BaseResponseHandler to register this class in the list of registered HTTP response handlers.
 */
+ (void)load
{
    [BaseResponseHandler registerHandler:self];
}

/*! @brief Class method to determine if the response handler class can handle a given request.
 @param aRequest the request
 @param requestMethod the request method
 @param requestURL the request URL
 @param requestHeaderFields the request headers
 @return YES (if the handler can handle the request), NO (otherwise)
 */
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

/*! @brief Since this is a simple response, we handle it synchronously by sending everything at once.
 */
- (void)startResponse
{
    NSDictionary *jsonResponse = [self addUser];
    CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [[jsonResponse valueForKey:@"code"] integerValue], NULL, kCFHTTPVersion1_1);
    
    NSLog(@"respond with JSON: %@", jsonResponse);
    
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

/*! @brief Handle adduser request and store new user data.
 * @return dictionary that contains NSNumber for operation code (@"code" key) and result data in JSON (@"data" key)
 */
- (NSDictionary*)addUser
{
    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionary];
    NSError *error;
    NSDictionary* jsonRequest = [NSJSONSerialization JSONObjectWithData:requestData options:kNilOptions error:&error];
    if (error) {
        [responseDictionary setValue:[NSNumber numberWithInteger:400] forKey:@"code"];
        [responseDictionary setValue:@"{\"message\": \"invalid data\",\"code\": 400}" forKey:@"data"];
        return responseDictionary;
    }
    
    NSLog(@"JSON data received: %@", jsonRequest);
    
    NSString *login = [jsonRequest valueForKey:@"login"];
    NSString *password = [jsonRequest valueForKey:@"password"];
    if ([login length] > 0 && [password length] > 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *savedUser = [userDefaults valueForKey:login];
        if (savedUser != nil) {
            [responseDictionary setValue:[NSNumber numberWithInteger:409] forKey:@"code"];
            [responseDictionary setValue:@"{\"message\": \"user is already existed\",\"code\": 409}" forKey:@"data"];
            return responseDictionary;
        }
        NSDictionary *dictData = [NSDictionary dictionaryWithObjectsAndKeys:login, @"login", password, @"password", nil];
        [userDefaults setValue:dictData forKey:login];
        
        NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:200], @"code", @"ok", @"message", login, @"login", nil];
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:&error];
        if (error) {
            [responseDictionary setValue:[NSNumber numberWithInteger:501] forKey:@"code"];
            [responseDictionary setValue:@"{\"message\": \"internal server error\",\"code\": 501}" forKey:@"data"];
            return responseDictionary;
        }
        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:200], @"code", responseStr, @"data", nil];
    }
    [responseDictionary setValue:[NSNumber numberWithInteger:400] forKey:@"code"];
    [responseDictionary setValue:@"{\"message\": \"invalid data\",\"code\": 400}" forKey:@"data"];
    return responseDictionary;    
}
@end

/*!
 @header BaseResponseHandler.h
 
 @brief This is base class for HTTP request handler.
 
 @copyright  2017 Harman
 @version    1.0.0
 */

#import "BaseResponseHandler.h"
#import "HTTPServer.h"

@interface BaseResponseHandler ()
@property (nonatomic, retain) NSFileHandle *fileHandle;
@end

@implementation BaseResponseHandler
@synthesize fileHandle;

static NSMutableArray *registeredHandlers = nil;

/*! @brief The priority determines which request handlers are given the option to
 * handle a request first. The highest number goes first.
 * @discussion Even if subclasses have a 0 priority, they will always receive precedence
 * over the base class, since the base class' implementation is intended as
 * an error condition only.
 * @return the priority.
 */
+ (NSUInteger)priority
{
    return 0;
}

/*! @brief Implementing the load method and invoking
 */
+ (void)load
{
    [BaseResponseHandler registerHandler:self];
}

/*! @brief Inserts the BaseResponseHandler class into the priority list.
 *  @param handlerClass new handler class
 */
+ (void)registerHandler:(Class)handlerClass
{
    if (registeredHandlers == nil)
    {
        registeredHandlers = [[NSMutableArray alloc] init];
    }
    
    NSUInteger i;
    NSUInteger count = [registeredHandlers count];
    for (i = 0; i < count; i++)
    {
        if ([handlerClass priority] >= [[registeredHandlers objectAtIndex:i] priority])
        {
            break;
        }
    }
    [registeredHandlers insertObject:handlerClass atIndex:i];
}

/*! @brief Class method to determine if the response handler class can handle
 a given request.
 @param aRequest the request
 @param requestMethod the request method
 @param requestURL the request URL
 @param requestHeaderFields - the request headers
 @return YES (if the handler can handle the request), NO (otherwise)
 */
+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
                  method:(NSString *)requestMethod
                     url:(NSURL *)requestURL
            headerFields:(NSDictionary *)requestHeaderFields
{
    return YES;
}

/*! @brief Important method to edit for your application.
 @discussion This method determines (from the HTTP request message, URL and headers)
 @param aRequest the CFHTTPMessageRef, with data at least as far as the end	of the headers
 @param requestMethod - the request method (GET, POST, PUT, DELETE etc)
 @param requestURL - the URL (likely only contains a path)
 @param requestHeaderFields - the parsed header fields
 @return the class to handle the request, or nil if no handler exists.
*/
+ (Class)handlerClassForRequest:(CFHTTPMessageRef)aRequest method:(NSString *)requestMethod
                            url:(NSURL *)requestURL headerFields:(NSDictionary *)requestHeaderFields
{
    for (Class handlerClass in registeredHandlers)
    {
        if ([handlerClass canHandleRequest:aRequest method:requestMethod url:requestURL
                              headerFields:requestHeaderFields])
        {
            return handlerClass;
        }
    }
    
    return nil;
}

/*! @brief This method parses the request method and header components, invokes
 @code +[handlerClassForRequest:method:url:headerFields:] @endcode
 to determine a handler class (if any) and creates the handler.
 @param aRequest the CFHTTPMessageRef request requiring a response
 @param requestFileHandle the file handle for the incoming request (still open and possibly receiving data) and for the outgoing response
 @param aServer the server that is invoking us
 @return the initialized handler (if one can handle the request) or nil (if no valid handler exists).
 */
+ (BaseResponseHandler *)handlerForRequest:(CFHTTPMessageRef)aRequest
                                fileHandle:(NSFileHandle *)requestFileHandle
                                    server:(HTTPServer *)aServer
{
    NSDictionary *requestHeaderFields = (__bridge NSDictionary *)CFHTTPMessageCopyAllHeaderFields(aRequest);
    NSURL *requestURL = (__bridge NSURL *)CFHTTPMessageCopyRequestURL(aRequest);
    NSString *method = (__bridge NSString *)CFHTTPMessageCopyRequestMethod(aRequest);
    
    Class classForRequest =
    [self handlerClassForRequest:aRequest method:method url:requestURL headerFields:requestHeaderFields];
    
    BaseResponseHandler *handler = [[classForRequest alloc] initWithRequest:aRequest method:method
                                                                        url:requestURL
                                                               headerFields:requestHeaderFields
                                                                 fileHandle:requestFileHandle
                                                                     server:aServer];
    
    return handler;
}

/*! @brief Init method for the handler. This method is mostly just a value copy operation so that the parts of the request don't need to be reparsed.
 @param aRequest - the CFHTTPMessageRef
 @param method - the request method
 @param requestURL - the URL
 @param requestHeaderFields - the CFHTTPMessageRef header fields
 @param requestFileHandle - the incoming request file handle, also used for the outgoing response.
 @param aServer - the server that spawned us
 @return the initialized object
 */
- (id)initWithRequest:(CFHTTPMessageRef)aRequest method:(NSString *)method url:(NSURL *)requestURL
         headerFields:(NSDictionary *)requestHeaderFields fileHandle:(NSFileHandle *)requestFileHandle
               server:(HTTPServer *)aServer
{
    self = [super init];
    if (self != nil)
    {
        request = (CFHTTPMessageRef)aRequest;
        requestMethod = method;
        url = requestURL;
        headerFields = requestHeaderFields;
        self.fileHandle = requestFileHandle;
        server = aServer;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIncomingDataNotification:) name:NSFileHandleDataAvailableNotification object:fileHandle];
        
        [fileHandle waitForDataInBackgroundAndNotify];
    }
    return self;
}

/*! @brief Begin sending a response over the fileHandle. Trivial cases can synchronously return a response but everything else should spawn a thread or otherwise asynchronously start returning the response data.
 
 @discussion THIS IS THE PRIMARY METHOD FOR SUBCLASSES TO OVERRIDE. YOU DO NOT NEED TO INVOKE SUPER FOR THIS METHOD.
 This method should only be invoked from HTTPServer (it needs to add the object to its responseHandlers before this method is invoked).
 @code [server closeHandler:self] @endcode should be invoked when done sending data.
 */
- (void)startResponse
{
    CFHTTPMessageRef response =
    CFHTTPMessageCreateResponse(kCFAllocatorDefault, 501, NULL, kCFHTTPVersion1_1);
    CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Type", (CFStringRef)@"application/json");
    CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Connection", (CFStringRef)@"close");
    CFHTTPMessageSetBody(response, (__bridge CFDataRef)[@"{"
                                              @"\"message\": \"not supported\","
                                              @"\"code\": 501"
                                              @"}"
                                     dataUsingEncoding:NSUTF8StringEncoding]);
    
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
        // So the handling will just be canceled
    }
    @finally
    {
        CFRelease(headerData);
        CFRelease(response);
        [server closeHandler:self];
    }
}

/*! @brief Closes the outgoing file handle.
 @discussin You should not invoke this method directly. It should only be invoked from HTTPServer (it needs to remove the object from its responseHandlers before this method is invoked). To close a reponse handler, use
 @code [server closeHandler:responseHandler] @endcode
 Subclasses should stop any other activity when this method is invoked and invoke super to close the file handle.

 If the connection is persistent, you must set fileHandle to nil (without closing the file) to prevent the connection getting closed by this method.
 */
- (void)endResponse
{
    if (fileHandle)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name: NSFileHandleDataAvailableNotification object:fileHandle];
        [fileHandle closeFile];
        fileHandle = nil;
    }
    
    server = nil;
}

/*! @brief Continues to receive incoming data for the connection. Remember that the first data past the end of the headers may already have been read into the request.

 @discussion Override this method to read the complete HTTP Request Body. This is a complicated process if you want to handle both Content-Length and all common Transfer-Encodings, so I haven't implemented it.
 If you want to handle persistent connections, you would need careful handling to determine the end of the request, seek the fileHandle so it points to the byte immediately after then end of this request, and then send an NSFileHandleConnectionAcceptedNotification notification with the fileHandle as the NSFileHandleNotificationFileHandleItem in the userInfo dictionary back to the server to handle the fileHandle as a new incoming request again (before setting fileHandle to nil so the connection won't get closed when this handler ends).
 @param notification notification that more data is available
 */
- (void)receiveIncomingDataNotification:(NSNotification *)notification
{
    NSFileHandle *incomingFileHandle = [notification object];
    NSData *data = [incomingFileHandle availableData];
    
    if ([data length] == 0)
    {
        [server closeHandler:self];
    }
    
    //
    // This is a default implementation and simply ignores all data.
    // If you need the HTTP body, you need to override this method to continue
    // accumulating data. Don't forget that new data may need to be combined
    // with any HTTP body data that may have already been received in the
    // "request" body.
    //
    [incomingFileHandle waitForDataInBackgroundAndNotify];
}

/*! @brief Stops the response if still running. */
//
- (void)dealloc
{
    if (server)
    {
        [self endResponse];
    }
    request = nil;
    requestMethod = nil;
    url = nil;
    headerFields = nil;    
}

@end

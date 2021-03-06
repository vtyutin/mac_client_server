/*!
 @header HTTPServer.h
 
 @brief This class is HTTP server implementation.
 
 @copyright  2017 Harman
 @version    1.0.0
 */
#import "HTTPServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "BaseResponseHandler.h"

#define HTTP_SERVER_PORT 8181

NSString * const ServerNotificationStateChanged = @"ServerNotificationStateChanged";

@interface HTTPServer ()
@property (nonatomic, readwrite, retain) NSError *lastError;
@property (readwrite, assign) ServerState state;
@property (nonatomic, retain) NSMutableSet *responseHandlers;
@end

@implementation HTTPServer

@synthesize lastError;
@synthesize state;
@synthesize responseHandlers;

/*! @brief initialize server object.
 */
- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.state = IDLE;
        self.responseHandlers = [[NSMutableSet alloc] init];
        incomingRequests = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

/*! @brief Custom setter method. Stops the server.
 *  @param anError the new error value (nil to clear)
 */
- (void)setLastError:(NSError *)anError
{
    lastError = anError;
    
    if (lastError == nil)
    {
        return;
    }
    
    [self stop];
    
    self.state = IDLE;
    NSLog(@"HTTPServer error: %@", self.lastError);
}

/*! @brief Create error and update last error.
 *  @param errorName error message
 */
- (void)errorWithName:(NSString *)errorName
{
    self.lastError = [NSError
                      errorWithDomain:@"ServerError"
                      code:0
                      userInfo:
                      [NSDictionary dictionaryWithObject:
                       NSLocalizedStringFromTable(errorName,
                                                  @"",
                                                  @"ServerErrors")
                                                  forKey:NSLocalizedDescriptionKey]];	
}

/*! @brief Changes the server state and posts a notification (if the state changes).
 *  @param newState the new state for the server
 */
- (void)setState:(ServerState)newState
{
    if (state == newState)
    {
        return;
    }
    
    state = newState;
    [[NSNotificationCenter defaultCenter] postNotificationName:ServerNotificationStateChanged object:self];
}

/*! @brief Creates the socket and starts listening for connections on it.
 */
- (void)start
{
    self.lastError = nil;
    self.state = STARTING;
    
    socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM,
                            IPPROTO_TCP, 0, NULL, NULL);
    if (!socket)
    {
        [self errorWithName:@"Unable to create socket."];
        return;
    }
    
    int reuse = true;
    int fileDescriptor = CFSocketGetNative(socket);
    if (setsockopt(fileDescriptor, SOL_SOCKET, SO_REUSEADDR,
                   (void *)&reuse, sizeof(int)) != 0)
    {
        [self errorWithName:@"Unable to set socket options."];
        return;
    }
    
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_ANY);
    address.sin_port = htons(HTTP_SERVER_PORT);
    CFDataRef addressData = CFDataCreate(NULL, (const UInt8 *)&address, sizeof(address));
    
    if (CFSocketSetAddress(socket, addressData) != kCFSocketSuccess)
    {
        [self errorWithName:@"Unable to bind socket to address."];
        return;
    }
    
    listeningHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileDescriptor closeOnDealloc:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveIncomingConnection:)
                                                 name:NSFileHandleConnectionAcceptedNotification
                                               object:nil];
    [listeningHandle acceptConnectionInBackgroundAndNotify];
    
    NSLog(@"Server started on port: %d", HTTP_SERVER_PORT);
    
    self.state = RUNNING;
}

/*! @brief If a file handle is accumulating the header for a new connection, this
 *  method will close the handle, stop listening to it and release the
 *  accumulated memory.
 *  @param incomingFileHandle the file handle for the incoming request
 *  @param closeFileHandle if YES, the file handle will be closed, if no it is
 *		assumed that an HTTPResponseHandler will close it when done.
 */
- (void)stopReceivingForFileHandle:(NSFileHandle *)incomingFileHandle close:(BOOL)closeFileHandle
{
    if (closeFileHandle) {
        [incomingFileHandle closeFile];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:incomingFileHandle];
    CFDictionaryRemoveValue(incomingRequests, (__bridge const void *)(incomingFileHandle));
}

/*! @brief Stops the server.
 */
- (void)stop
{
    self.state = STOPPING;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:nil];
    
    [responseHandlers removeAllObjects];
    [listeningHandle closeFile];
    listeningHandle = nil;
    
    for (NSFileHandle *incomingFileHandle in [(NSDictionary *)CFBridgingRelease(incomingRequests) copy])
    {
        [self stopReceivingForFileHandle:incomingFileHandle close:YES];
    }
    
    if (socket)
    {
        CFSocketInvalidate(socket);
        CFRelease(socket);
        socket = nil;
    }
    
    self.state = IDLE;
}

/*! @brief the notification for a new incoming request.
 *  @param notification the new connection notification
 */
- (void)receiveIncomingConnection:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSFileHandle *incomingFileHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
    
    if(incomingFileHandle)
    {
        CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
        CFDictionaryAddValue(incomingRequests, CFBridgingRetain(incomingFileHandle), message);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIncomingData:) name:NSFileHandleDataAvailableNotification object:incomingFileHandle];
        [incomingFileHandle waitForDataInBackgroundAndNotify];
    }
    
    [listeningHandle acceptConnectionInBackgroundAndNotify];
}

/*! @brief Receive new data for an incoming connection.
 *  @param notification data received notification
 */
- (void)receiveIncomingData:(NSNotification *)notification
{
    NSFileHandle *incomingFileHandle = [notification object];
    NSData *data = [incomingFileHandle availableData];
    
    if ([data length] == 0)
    {
        [self stopReceivingForFileHandle:incomingFileHandle close:NO];
        return;
    }
    
    CFHTTPMessageRef incomingRequest = (CFHTTPMessageRef)CFDictionaryGetValue(incomingRequests, CFBridgingRetain(incomingFileHandle));
    if (!incomingRequest)
    {
        [self stopReceivingForFileHandle:incomingFileHandle close:YES];
        return;
    }
    
    if (!CFHTTPMessageAppendBytes(incomingRequest, [data bytes], [data length]))
    {
        [self stopReceivingForFileHandle:incomingFileHandle close:YES];
    }
    
    NSData *message = (__bridge NSData *)CFHTTPMessageCopySerializedMessage(incomingRequest);
    NSString *messageStr = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    NSLog(@"received request message: %@", messageStr);
    
    NSData *requestBody = (__bridge NSData *)CFHTTPMessageCopyBody(incomingRequest);
    NSLog(@"received request body: %@", requestBody);
    
    if(CFHTTPMessageIsHeaderComplete(incomingRequest))
    {
        NSString *contentLength = (__bridge NSString*)CFHTTPMessageCopyHeaderFieldValue(incomingRequest, (CFStringRef)@"Content-Length");
        NSInteger lenght = [contentLength integerValue];
        if (lenght == 0 || (requestBody.length == lenght)) {
            BaseResponseHandler *handler = [BaseResponseHandler handlerForRequest:incomingRequest fileHandle:incomingFileHandle server:self];
            [responseHandlers addObject:handler];
            //[self stopReceivingForFileHandle:incomingFileHandle close:NO];
            [handler startResponse];
            return;
        }
    }
    
    [incomingFileHandle waitForDataInBackgroundAndNotify];
}

/*! @brief Shuts down a response handler and removes it from the set of handlers.
 *  @param aHandler the handler to shut down.
 */
- (void)closeHandler:(BaseResponseHandler *)aHandler
{
    [aHandler endResponse];
    [responseHandlers removeObject:aHandler];
}
@end

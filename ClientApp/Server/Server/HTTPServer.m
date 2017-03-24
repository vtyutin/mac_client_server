//
//  HTTPServer.m
//  Server
//
//  Copyright © 2017 Harman. All rights reserved.
//

#import "HTTPServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
//#import "BaseResponseHandler.h"

#define HTTP_SERVER_PORT 8181

NSString * const ServerNotificationStateChanged = @"ServerNotificationStateChanged";

@interface HTTPServer ()
@property (nonatomic, readwrite, retain) NSError *lastError;
@property (readwrite, assign) ServerState state;
@property (nonatomic, retain) NSMutableDictionary *incomingRequests;
@property (nonatomic, retain) NSMutableSet *responseHandlers;
@end

@implementation HTTPServer

@synthesize lastError;
@synthesize state;
@synthesize responseHandlers;
@synthesize incomingRequests;

// init
//
// initialize server object.
//
- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.state = IDLE;
        self.responseHandlers = [[NSMutableSet alloc] init];
        self.incomingRequests = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// setLastError:
//
// Custom setter method. Stops the server
//
// Parameters:
//    anError - the new error value (nil to clear)
//
- (void)setLastError:(NSError *)anError
{
<<<<<<< HEAD
    lastError = anError;
=======
    self.lastError = anError;
>>>>>>> 699e12c3a890848aae1e663cdfd7f9b322dfa24e
    
    if (lastError == nil)
    {
        return;
    }
    
    [self stop];
    
    self.state = IDLE;
    NSLog(@"HTTPServer error: %@", self.lastError);
}

// errorWithName:
//
// Create error and update last error
//
// Parameters:
//    errorName - error message
//
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

// setState:
//
// Changes the server state and posts a notification (if the state changes).
//
// Parameters:
//    newState - the new state for the server
//
- (void)setState:(ServerState)newState
{
    if (state == newState)
    {
        return;
    }
    
<<<<<<< HEAD
    state = newState;
=======
    self.state = newState;
>>>>>>> 699e12c3a890848aae1e663cdfd7f9b322dfa24e
    [[NSNotificationCenter defaultCenter] postNotificationName:ServerNotificationStateChanged object:self];
}

// start
//
// Creates the socket and starts listening for connections on it.
//
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

// stopReceivingForFileHandle:close:
//
// If a file handle is accumulating the header for a new connection, this
// method will close the handle, stop listening to it and release the
// accumulated memory.
//
// Parameters:
//    incomingFileHandle - the file handle for the incoming request
//    closeFileHandle - if YES, the file handle will be closed, if no it is
//		assumed that an HTTPResponseHandler will close it when done.
//
- (void)stopReceivingForFileHandle:(NSFileHandle *)incomingFileHandle
{
    [incomingFileHandle closeFile];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:incomingFileHandle];
    [incomingRequests removeObjectForKey:incomingFileHandle];
}

//
// stop
//
// Stops the server.
//
- (void)stop
{
    self.state = STOPPING;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:nil];
    
    [responseHandlers removeAllObjects];
    [listeningHandle closeFile];
    listeningHandle = nil;
    
    for (NSFileHandle *incomingFileHandle in incomingRequests.allKeys)
    {
        [self stopReceivingForFileHandle:incomingFileHandle];
    }
    
    if (socket)
    {
        CFSocketInvalidate(socket);
        CFRelease(socket);
        socket = nil;
    }
    
    self.state = IDLE;
}

// receiveIncomingConnection:
//
// Receive the notification for a new incoming request.
//
// Parameters:
//    notification - the new connection notification
//
- (void)receiveIncomingConnection:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSFileHandle *incomingFileHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
    
    if(incomingFileHandle)
    {
        CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
        [incomingRequests setValue:CFBridgingRelease(message) forKey:incomingFileHandle];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIncomingDataNotification:) name:NSFileHandleDataAvailableNotification object:incomingFileHandle];
        [incomingFileHandle waitForDataInBackgroundAndNotify];
    }
    
    [listeningHandle acceptConnectionInBackgroundAndNotify];
}

//
<<<<<<< HEAD
// receiveIncomingData:
//
// Receive new data for an incoming connection.
//
// Parameters:
//    notification - data received notification
//
- (void)receiveIncomingData:(NSNotification *)notification
=======
// receiveIncomingDataNotification:
//
// Receive new data for an incoming connection.
//
// Once enough data is received to fully parse the HTTP headers,
// a HTTPResponseHandler will be spawned to generate a response.
//
// Parameters:
//    notification - data received notification
//
- (void)receiveIncomingDataNotification:(NSNotification *)notification
>>>>>>> 699e12c3a890848aae1e663cdfd7f9b322dfa24e
{
    NSFileHandle *incomingFileHandle = [notification object];
    NSData *data = [incomingFileHandle availableData];
    
    if ([data length] == 0)
    {
<<<<<<< HEAD
        [self stopReceivingForFileHandle:incomingFileHandle];
        return;
    }
    
    CFHTTPMessageRef incomingRequest = CFBridgingRetain([incomingRequests objectForKey:incomingFileHandle]);
    if (!incomingRequest)
    {
        [self stopReceivingForFileHandle:incomingFileHandle];
        return;
    }
    
    if (!CFHTTPMessageAppendBytes(incomingRequest, [data bytes], [data length]))
    {
        [self stopReceivingForFileHandle:incomingFileHandle];
=======
        [self stopReceivingForFileHandle:incomingFileHandle close:NO];
        return;
    }
    
    CFHTTPMessageRef incomingRequest =
    (CFHTTPMessageRef)CFDictionaryGetValue(incomingRequests, incomingFileHandle);
    if (!incomingRequest)
    {
        [self stopReceivingForFileHandle:incomingFileHandle close:YES];
        return;
    }
    
    if (!CFHTTPMessageAppendBytes(
                                  incomingRequest,
                                  [data bytes],
                                  [data length]))
    {
        [self stopReceivingForFileHandle:incomingFileHandle close:YES];
>>>>>>> 699e12c3a890848aae1e663cdfd7f9b322dfa24e
        return;
    }
    
    if(CFHTTPMessageIsHeaderComplete(incomingRequest))
    {
<<<<<<< HEAD
        // ToDo handle request
        //HTTPResponseHandler *handler = [HTTPResponseHandler handlerForRequest:incomingRequest fileHandle:incomingFileHandle server:self];
        //[responseHandlers addObject:handler];
        //[self stopReceivingForFileHandle:incomingFileHandle];
        //[handler startResponse];
=======
        HTTPResponseHandler *handler =
        [HTTPResponseHandler
         handlerForRequest:incomingRequest
         fileHandle:incomingFileHandle
         server:self];
        
        [responseHandlers addObject:handler];
        [self stopReceivingForFileHandle:incomingFileHandle close:NO];
        
        [handler startResponse];	
>>>>>>> 699e12c3a890848aae1e663cdfd7f9b322dfa24e
        return;
    }
    
    [incomingFileHandle waitForDataInBackgroundAndNotify];
}

//
// closeHandler:
//
// Shuts down a response handler and removes it from the set of handlers.
//
// Parameters:
//    aHandler - the handler to shut down.
//
<<<<<<< HEAD
//- (void)closeHandler:(HTTPResponseHandler *)aHandler
//{
//    [aHandler endResponse];
//    [responseHandlers removeObject:aHandler];
//}
=======
- (void)closeHandler:(HTTPResponseHandler *)aHandler
{
    [aHandler endResponse];
    [responseHandlers removeObject:aHandler];
}
>>>>>>> 699e12c3a890848aae1e663cdfd7f9b322dfa24e

@end

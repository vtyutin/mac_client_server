/*!
 @header HTTPServer.h
 
 @brief This class is HTTP server implementation.
 
 @copyright  2017 Harman
 @version    1.0.0
 */
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

/*
 * Server states
 */
typedef enum
{
    IDLE,
    STARTING,
    RUNNING,
    STOPPING
} ServerState;

@class BaseResponseHandler;

/*!
 @class HTTPServer
 
 @brief The HTTP Server
 
 @discussion This class is implementation of server socket that is listening incomming requests and 
 send it to handlers to be handled in background.
 */
@interface HTTPServer : NSObject
{
    NSError *lastError;
    /*! @brief File handler for listening server socket. */
    NSFileHandle *listeningHandle;
    /*! @brief Server socket. */
    CFSocketRef socket;
    ServerState state;
    /*! @brief Dictionary that keeps all incoming requests that are being handled now. */
    CFMutableDictionaryRef incomingRequests;
    /*! @brief Set of handlers for requests. */
    NSMutableSet *responseHandlers;
}

/*! @brief This property to keep last error of socket operation. */
@property (nonatomic, readonly, retain) NSError *lastError;
/*! @brief This property to keep current server state. */
@property (nonatomic, readonly, assign) ServerState state;

/*! @brief Start the server. */
- (void)start;
/*! @brief Stop the server. */
- (void)stop;
/*! @brief close the response handler.
 * @param  responseHandler The handler that should be removed
 */
- (void)closeHandler:(BaseResponseHandler *)responseHandler;

@end

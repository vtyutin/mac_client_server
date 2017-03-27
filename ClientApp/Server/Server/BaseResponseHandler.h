/*!
 @header BaseResponseHandler.h
 
 @brief This is base class for HTTP request handler.
 
 @copyright  2017 Harman
 @version    1.0.0
 */
#import <Foundation/Foundation.h>

@class HTTPServer;

@interface BaseResponseHandler : NSObject
{
    /*! @brief Incomming HTTP request object. */
    CFHTTPMessageRef request;
    /*! @brief HTTP request method (GET, POST, DELETE, etc.). */
    NSString *requestMethod;
    /*! @brief Dictionary that contains incomming HTTP request header fields. */
    NSDictionary *headerFields;
    /*! @brief Connection file handle. */
    NSFileHandle *fileHandle;
    /*! @brief Link to HTTPServer object. */
    HTTPServer *server;
    /*! @brief Incoming request URL. */
    NSURL *url;
}

/*! @brief Get the handler priority.
 * @return NSUInteger 0 is minimal priority value
 */
+ (NSUInteger)priority;

/*! @brief Method to register new handler for HTTP request.
 * @param handlerClass class of new handler
 */
+ (void)registerHandler:(Class)handlerClass;

/*! @brief get the handler that will be responsible for HTTP request handling.
 * @param aRequest incomming HTTP request
 * @param requestFileHandle incomming HTTP request file handle
 * @param aServer link to HTTPServer object
 * @return BaseResponseHandler handler object
 */
+ (BaseResponseHandler *)handlerForRequest:(CFHTTPMessageRef)aRequest
                                fileHandle:(NSFileHandle *)requestFileHandle server:(HTTPServer *)aServer;

/*! @brief initialization method.
 * @param aRequest incomming HTTP request
 * @param requestURL incomming HTTP request url
 * @param requestHeaderFields incomming HTTP request header field
 * @param requestFileHandle incomming HTTP request file handle
 * @param aServer link to HTTPServer object
 * @return the link to initialized handler for this request
 */
- (id)initWithRequest:(CFHTTPMessageRef)aRequest method:(NSString *)method url:(NSURL *)requestURL
         headerFields:(NSDictionary *)requestHeaderFields fileHandle:(NSFileHandle *)requestFileHandle
               server:(HTTPServer *)aServer;
/*! @brief Start response creation.
 */
- (void)startResponse;
/*! @brief End response.
 */
- (void)endResponse;
@end

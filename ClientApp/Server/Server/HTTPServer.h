//
//  HTTPServer.h
//  Server
//
//  Copyright © 2017 Harman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef enum
{
    IDLE,
    STARTING,
    RUNNING,
    STOPPING
} ServerState;

@class BaseResponseHandler;

@interface HTTPServer : NSObject
{
    NSError *lastError;
    NSFileHandle *listeningHandle;
    CFSocketRef socket;
    ServerState state;
    NSMutableDictionary *incomingRequests;
    NSMutableSet *responseHandlers;
}

@property (nonatomic, readonly, retain) NSError *lastError;
@property (nonatomic, readonly, assign) ServerState state;

- (void)start;
- (void)stop;

- (void)closeHandler:(BaseResponseHandler *)responseHandler;

@end

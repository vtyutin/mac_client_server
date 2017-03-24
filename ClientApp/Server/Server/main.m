//
//  main.m
//  Server
//
//  Created by Vladimir Tyutin on 23/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"

int main(int argc, const char * argv[]) {
    #pragma unused(argc)
    #pragma unused(argv)
    @autoreleasepool {
        HTTPServer * server = [[HTTPServer alloc] init];
<<<<<<< HEAD
        [server start];
        if ( [server lastError] == nil) {
=======
        [server start]
        if ( [server lastError] == nil ) {
>>>>>>> 699e12c3a890848aae1e663cdfd7f9b322dfa24e
            [[NSRunLoop currentRunLoop] run];
        } else {
            NSLog(@"Error starting server: %@", server.lastError);
        }
    }
    return EXIT_SUCCESS;
}

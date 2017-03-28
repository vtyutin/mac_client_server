//
//  AppDelegate.m
//  ClientApp
//
//  Created by Alexander Davydov on 23/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        return NO;
    } else {
        [[[[NSApplication sharedApplication] windows] firstObject] makeKeyAndOrderFront:self];
        return YES;
    }
}


@end

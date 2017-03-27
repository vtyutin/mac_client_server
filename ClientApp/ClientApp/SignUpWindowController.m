//
//  SignUpWindowController.m
//  ClientApp
//
//  Created by Alexander Davydov on 27/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import "SignUpWindowController.h"

@interface SignUpWindowController ()

@end

@implementation SignUpWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] stopModal];
}

@end

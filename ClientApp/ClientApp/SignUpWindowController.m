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
}

-(void)windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] stopModal];
}

@end

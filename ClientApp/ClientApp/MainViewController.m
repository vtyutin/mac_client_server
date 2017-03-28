//
//  MainViewController.m
//  ClientApp
//
//  Created by Alexander Davydov on 27/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)openSignUp:(id)sender
{
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSWindowController *windowController = [storyboard instantiateControllerWithIdentifier:@"SignUp"];
    
    [[NSApplication sharedApplication] runModalForWindow:[windowController window]];
}

@end

//
//  ViewController.h
//  ClientApp
//
//  Created by Alexander Davydov on 23/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *loginField;
@property (weak) IBOutlet NSSecureTextField *passwordField;
@property (weak) IBOutlet NSPopUpButton *yearSelector;

@end


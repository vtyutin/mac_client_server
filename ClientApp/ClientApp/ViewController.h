//
//  ViewController.h
//  ClientApp
//
//  Created by Alexander Davydov on 23/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

/*! @brief Field to enter login */
@property (weak) IBOutlet NSTextField *loginField;
/*! @brief Secure field to enter password */
@property (weak) IBOutlet NSSecureTextField *passwordField;
/*! @brief Popup list to chose year of birth */
@property (weak) IBOutlet NSPopUpButton *yearSelector;

@end


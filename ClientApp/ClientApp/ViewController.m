//
//  ViewController.m
//  ClientApp
//
//  Created by Vladimir Tyutin on 23/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import "ViewController.h"
#import "APIManager.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    for (int y = 1989; y < 2018; y++) {
        [_yearSelector addItemWithTitle:[NSString stringWithFormat:@"%d", y]];
    }
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)loginButtonPressed:(id)sender
{
    
    [[APIManager sharedManager] signUpWithUsername:[_loginField stringValue]
                                          password:[_passwordField stringValue]
                                              year:[NSNumber numberWithInt:[[_yearSelector titleOfSelectedItem] intValue]]
                                           handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Request Error: %@", error);
        } else{
            NSLog(@"Request succeded: %@", response);
            NSLog(@"Request Data: %@", data);
            
            NSError* jsonError = nil;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NULL
                                                                   error:&jsonError];
            if (jsonError) {
                NSLog(@"JSON PARSING ERRPR!!!");
            } else {
                NSLog(@"JSON: %@", json);
            }
        }
    }];
    
}

@end

//
//  ViewController.m
//  ClientApp
//
//  Created by Alexander Davydov on 23/03/2017.
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

- (IBAction)signUpButtonPressed:(id)sender
{
    
    [[APIManager sharedManager] signUpWithUsername:[_loginField stringValue]
                                          password:[_passwordField stringValue]
                                              year:[NSNumber numberWithInt:[[_yearSelector titleOfSelectedItem] intValue]]
                                           handler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                               
                                               NSString *message = nil;
                                               NSString *informativeText = @"";
                                               int aletType;
                                               
                                               BOOL closesignIn = false;
                                               
                                               if (error) {
                                                   NSLog(@"Request Error: %@", error);
                                                   
                                                   aletType = NSAlertStyleCritical;
                                                   message = [[[error userInfo] objectForKey:NSUnderlyingErrorKey] localizedDescription];
                                                   
                                               } else {
                                                   NSLog(@"Request succeded: %@", response);
                                                   NSLog(@"Request Data: %@", data);
                                                   
                                                   NSError* jsonError = nil;
                                                   NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                        options:NULL
                                                                                                          error:&jsonError];
                                                   if (jsonError) {
                                                       NSLog(@"JSON PARSING ERROR!!!");
                                                       message = @"Parsing error. JSON is in invalid format";
                                                   } else {
                                                       NSLog(@"JSON: %@", json);
                                                       
                                                       NSInteger responceCode = [[json objectForKey:@"code"] integerValue];
                                                       
                                                       switch (responceCode) {
                                                           case 200:
                                                               message = @"You successfully signed up";
                                                               informativeText = [NSString stringWithFormat:@"You are signed up as [%@]", [json objectForKey:@"login"]];
                                                               aletType = NSAlertStyleInformational;
                                                               closesignIn = true;
                                                               break;
                                                           default:
                                                               message = [NSString stringWithFormat:@"Error %d", (int)responceCode];
                                                               informativeText = [json objectForKey:@"message"];
                                                               aletType = NSAlertStyleWarning;
                                                               break;
                                                       }
                                                   }
                                               }
                                               dispatch_async(dispatch_get_main_queue(), ^ {
                                                   NSAlert *alert = [[NSAlert alloc] init];
                                                   [alert addButtonWithTitle:@"OK"];
                                                   [alert setMessageText:message];
                                                   [alert setInformativeText:informativeText];
                                                   [alert setAlertStyle:aletType];
                                                   
                                                   if ([alert runModal] == NSAlertFirstButtonReturn) {
                                                       if (closesignIn) {
                                                           [[NSApplication sharedApplication] stopModal];
                                                       }
                                                   }
                                               });
                                           }];
}

@end

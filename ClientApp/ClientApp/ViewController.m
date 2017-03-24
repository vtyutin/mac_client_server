//
//  ViewController.m
//  ClientApp
//
//  Created by Vladimir Tyutin on 23/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import "ViewController.h"

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
    
}

@end

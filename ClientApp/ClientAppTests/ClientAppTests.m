//
//  ClientAppTests.m
//  ClientAppTests
//
//  Created by Vladimir Tyutin on 23/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "APIManager.h"
#import "Utils.h"

@interface ClientAppTests : XCTestCase

@end

@implementation ClientAppTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testSignUpWithExisistingUserName
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    [[APIManager sharedManager] signUpWithUsername:@"qwerty"
                                          password:@"123456"
                                              year:[NSNumber numberWithInt:1999]
                                           handler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                               
                                               // checking for connection error
                                               XCTAssertNil(error);
                                               
                                               // checking that data is exists
                                               XCTAssertNotNil(data);
                                               
                                               NSError *jsonError = nil;
                                               NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                    options:kNilOptions
                                                                                                      error:&jsonError];
                                               
                                               XCTAssertNil(jsonError);
                                               XCTAssertNotNil(json);
                                               
                                               XCTAssertEqual(409, [[json objectForKey:@"code"] integerValue]);
                                               
                                               dispatch_semaphore_signal(sem);
                                           }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}


- (void) testSignUpWithInvalidData
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    [[APIManager sharedManager] signUpWithUsername:@""
                                          password:@""
                                              year:[NSNumber numberWithInt:1999]
                                           handler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                               // checking for connection error
                                               XCTAssertNil(error);
                                               
                                               // checking that data is exists
                                               XCTAssertNotNil(data);
                                               
                                               NSError *jsonError = nil;
                                               NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                    options:kNilOptions
                                                                                                      error:&jsonError];
                                               
                                               XCTAssertNil(jsonError);
                                               XCTAssertNotNil(json);
                                               
                                               XCTAssertEqual(400, [[json objectForKey:@"code"] integerValue]);
                                               
                                               dispatch_semaphore_signal(sem);
                                           }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}


- (void) testSignUpWithNewUserName
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    NSString *newName = [Utils randomString];
    
    [[APIManager sharedManager] signUpWithUsername:newName
                                          password:@"123456"
                                              year:[NSNumber numberWithInt:1999]
                                           handler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                               
                                               // checking for connection error
                                               XCTAssertNil(error);
                                               
                                               // checking that data is exists
                                               XCTAssertNotNil(data);
                                               
                                               NSError *jsonError = nil;
                                               NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                    options:kNilOptions
                                                                                                      error:&jsonError];
                                               
                                               XCTAssertNil(jsonError);
                                               XCTAssertNotNil(json);
                                               
                                               XCTAssertTrue([newName isEqualToString:[json objectForKey:@"login"]]);
                                               
                                               dispatch_semaphore_signal(sem);
                                           }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}



@end

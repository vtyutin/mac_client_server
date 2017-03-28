//
//  ClientAppTests.m
//  ClientAppTests
//
//  Created by Vladimir Tyutin on 23/03/2017.
//  Copyright © 2017 Harman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "APIManager.h"

@interface ClientAppTests : XCTestCase

@end

@implementation ClientAppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
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

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}





@end

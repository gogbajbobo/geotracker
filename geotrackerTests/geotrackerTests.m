//
//  geotrackerTests.m
//  geotrackerTests
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "geotrackerTests.h"
#import "STSessionManager.h"
#import "STSession.h"

@implementation geotrackerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSessionManager
{
    STSessionManager *sessionManager = [STSessionManager sharedManager];
    
    [sessionManager startSessionForUID:@"1" authDelegate:nil];
    NSUInteger count = 1;
    STAssertEquals(sessionManager.sessions.count, count, @"");
    
    [sessionManager startSessionForUID:@"2" authDelegate:nil];
    count = 2;
    STAssertEquals(sessionManager.sessions.count, count, @"");

    [sessionManager startSessionForUID:@"1" authDelegate:nil];
    count = 2;
    STAssertEquals(sessionManager.sessions.count, count, @"");
    
    sessionManager.currentSessionUID = @"1";
    STAssertEquals(sessionManager.currentSessionUID, @"1", @"");

    sessionManager.currentSessionUID = @"3";
    STAssertEquals(sessionManager.currentSessionUID, @"1", @"");
    STAssertTrue([sessionManager.currentSessionUID boolValue], @"");

    sessionManager.currentSessionUID = nil;
    STAssertFalse([sessionManager.currentSessionUID boolValue], @"");

    [sessionManager stopSessionForUID:@"2"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.status == %@", @"completed"];
    NSArray *completedSessions = [[sessionManager.sessions allValues] filteredArrayUsingPredicate:predicate];
    count = 1;
    STAssertEquals(completedSessions.count, count, @"");
    
//    [sessionManager cleanCompletedSessions];
//    count = 1;
//    STAssertEquals(sessionManager.sessions.count, count, @"");

}

@end

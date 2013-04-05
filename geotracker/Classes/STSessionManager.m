//
//  STGTSessionManager.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STSessionManager.h"
#import "STSession.h"

@implementation STSessionManager

+ (STSessionManager *)sharedManager {
    static dispatch_once_t pred = 0;
    __strong static id _sharedManager = nil;
    dispatch_once(&pred, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)startSessionForUID:(NSString *)uid authDelegate:(id <STRequestAuthenticatable>)authDelegate {
    [self startSessionForUID:uid authDelegate:authDelegate settings:nil];
}

- (void)startSessionForUID:(NSString *)uid authDelegate:(id<STRequestAuthenticatable>)authDelegate settings:(NSDictionary *)settings {

    if (uid) {
        STSession *session = [self.sessions objectForKey:uid];
        if (!session) {
            session = [STSession initWithUID:uid authDelegate:authDelegate settings:settings];
            session.manager = self;
            [self.sessions setValue:session forKey:uid];
            session.status = @"starting";
        } else {
            session.authDelegate = authDelegate;
            session.status = @"running";
        }
        self.currentSessionUID = uid;
    } else {
        NSLog(@"no uid");
    }

}

- (void)stopSessionForUID:(NSString *)uid {
    STSession *session = [self.sessions objectForKey:uid];
    if ([session.status isEqualToString:@"running"]) {
        session.status = @"finishing";
        if ([self.currentSessionUID isEqualToString:uid]) {
            self.currentSessionUID = nil;
        }
        [session completeSession];
    }
}

- (void)sessionCompletionFinished:(STSession *)session {
    session.status = @"completed";
}

- (void)cleanCompletedSessions {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.status == %@", @"completed"];
    NSArray *completedSessions = [[self.sessions allValues] filteredArrayUsingPredicate:predicate];
    for (STSession *session in completedSessions) {
        [session dismissSession];
    }
}

- (void)removeSessionForUID:(NSString *)uid {
    if ([[(STSession *)[self.sessions objectForKey:uid] status] isEqualToString:@"completed"]) {
        [self.sessions removeObjectForKey:uid];
    }
}

- (NSMutableDictionary *)sessions {
    if (!_sessions) {
        _sessions = [NSMutableDictionary dictionary];
    }
    return _sessions;
}

- (void)setCurrentSessionUID:(NSString *)currentSessionUID {
    if ([[self.sessions allKeys] containsObject:currentSessionUID] || !currentSessionUID) {
        if (_currentSessionUID != currentSessionUID) {
            _currentSessionUID = currentSessionUID;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentSessionChanged" object:[self.sessions objectForKey:_currentSessionUID]];
        }
    }
}

@end

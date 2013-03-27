//
//  STGTSessionManager.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTSessionManager.h"
#import "STGTSession.h"

@implementation STGTSessionManager

+ (STGTSessionManager *)sharedManager {
    static dispatch_once_t pred = 0;
    __strong static id _sharedManager = nil;
    dispatch_once(&pred, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)startSessionForUID:(NSString *)uid authDelegate:(id <STGTRequestAuthenticatable>)authDelegate {
    [self startSessionForUID:uid authDelegate:authDelegate settings:nil];
}

- (void)startSessionForUID:(NSString *)uid authDelegate:(id<STGTRequestAuthenticatable>)authDelegate settings:(NSDictionary *)settings {

    if (uid) {
        STGTSession *session = [self.sessions objectForKey:uid];
        if (!session) {
            session = [STGTSession initWithUID:uid authDelegate:authDelegate];
            session.manager = self;
            [self.sessions setValue:session forKey:uid];
            session.status = @"starting";
        } else {
            session.authDelegate = authDelegate;
            session.status = @"running";
        }
        //    self.currentSessionUID = uid;
    } else {
        NSLog(@"no uid");
    }

}

- (void)stopSessionForUID:(NSString *)uid {
    STGTSession *session = [self.sessions objectForKey:uid];
    if (session) {
        session.status = @"finishing";
        if ([self.currentSessionUID isEqualToString:uid]) {
            self.currentSessionUID = nil;
        }
        [session completeSession];
    }
}

- (void)sessionCompletionFinished:(STGTSession *)session {
    session.status = @"completed";
}

- (void)cleanCompleteSessions {
    
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

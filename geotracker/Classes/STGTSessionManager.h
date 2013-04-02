//
//  STGTSessionManager.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STGTSessionManagement.h"
#import "STGTRequestAuthenticatable.h"

@interface STGTSessionManager : NSObject <STGTSessionManager>


@property (nonatomic, strong) NSMutableDictionary *sessions;
@property (nonatomic, strong) NSString *currentSessionUID;

- (void)startSessionForUID:(NSString *)uid authDelegate:(id <STGTRequestAuthenticatable>)authDelegate;
- (void)startSessionForUID:(NSString *)uid authDelegate:(id <STGTRequestAuthenticatable>)authDelegate settings:(NSDictionary *)settings;
- (void)stopSessionForUID:(NSString *)uid;
- (void)sessionCompletionFinished:(id <STGTSession>)session;
- (void)cleanCompletedSessions;
- (void)removeSessionForUID:(NSString *)uid;

+ (STGTSessionManager *)sharedManager;


@end

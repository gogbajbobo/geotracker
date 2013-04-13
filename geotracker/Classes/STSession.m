//
//  STGTSession.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STSession.h"
#import "STGTTracker.h"
#import "STSyncer.h"
#import "STLogger.h"

@interface STSession()

@property (nonatomic, strong) NSDictionary *startSettings;

@end


@implementation STSession

+ (STSession *)initWithUID:(NSString *)uid authDelegate:(id <STRequestAuthenticatable>)authDelegate {
    return [self initWithUID:uid authDelegate:authDelegate settings:nil];
}

+ (STSession *)initWithUID:(NSString *)uid authDelegate:(id<STRequestAuthenticatable>)authDelegate settings:(NSDictionary *)settings {

    if (uid) {
        STSession *session = [[STSession alloc] init];
        session.uid = uid;
        session.startSettings = settings;
        session.authDelegate = authDelegate;
        [[NSNotificationCenter defaultCenter] addObserver:session selector:@selector(documentReady:) name:@"documentReady" object:nil];
        session.document = [STManagedDocument documentWithUID:session.uid];
        return session;
    } else {
        NSLog(@"no uid");
        return nil;
    }

}

- (void)completeSession {
    if (self.document) {
        if (self.document.documentState == UIDocumentStateNormal) {
            [self.document saveDocument:^(BOOL success) {
                if (success) {
                    [self.manager sessionCompletionFinished:self];
                }
            }];
        }
    }
}

- (void)dismissSession {
    if ([self.status isEqualToString:@"completed"]) {
        if (self.document) {
            if (self.document.documentState != UIDocumentStateClosed) {
                [self.document closeWithCompletionHandler:^(BOOL success) {
                    [self.document.managedObjectContext reset];
                    [(STSessionManager *)self.manager removeSessionForUID:self.uid];
                }];
            }
        }
    }
}

- (void)documentReady:(NSNotification *)notification {
    if ([[notification.userInfo valueForKey:@"uid"] isEqualToString:self.uid]) {
        self.settingsController = [STGTSettingsController initWithSettings:self.startSettings];
        self.settingsController.session = self;
    }
}

- (void)settingsLoadComplete {
    self.logger = [[STLogger alloc] init];
    self.logger.session = self;
    self.locationTracker = [[STGTLocationTracker alloc] init];
    self.locationTracker.session = self;
    self.batteryTracker = [[STGTBatteryTracker alloc] init];
    self.batteryTracker.session = self;
    self.syncer = [[STSyncer alloc] init];
    self.syncer.session = self;
    self.syncer.authDelegate = self.authDelegate;
    self.status = @"running";    
}

- (void)setAuthDelegate:(id<STRequestAuthenticatable>)authDelegate {
    if (_authDelegate != authDelegate) {
        _authDelegate = authDelegate;
        self.syncer.authDelegate = _authDelegate;
    }
}

- (void)setStatus:(NSString *)status {
    if (_status != status) {
        _status = status;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionStatusChanged" object:self];
        [self.logger saveLogMessageWithText:[NSString stringWithFormat:@"Session status changed to %@", self.status] type:nil];
    }
}


@end

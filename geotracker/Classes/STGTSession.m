//
//  STGTSession.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTSession.h"
#import "STGTTracker.h"
#import "STGTSyncer.h"

@interface STGTSession()

@property (nonatomic, strong) NSDictionary *startSettings;

@end


@implementation STGTSession

+ (STGTSession *)initWithUID:(NSString *)uid authDelegate:(id <STGTRequestAuthenticatable>)authDelegate {
    return [self initWithUID:uid authDelegate:authDelegate settings:nil];
}

+ (STGTSession *)initWithUID:(NSString *)uid authDelegate:(id<STGTRequestAuthenticatable>)authDelegate settings:(NSDictionary *)settings {

    if (uid) {
        STGTSession *session = [[STGTSession alloc] init];
        session.uid = uid;
        session.startSettings = settings;
        session.authDelegate = authDelegate;
        [[NSNotificationCenter defaultCenter] addObserver:session selector:@selector(documentReady:) name:@"documentReady" object:nil];
        session.document = [STGTManagedDocument documentWithUID:session.uid];
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
                    [(STGTSessionManager *)self.manager removeSessionForUID:self.uid];
                }];
            }
        }
    }
}

- (void)documentReady:(NSNotification *)notification {
    if ([[notification.userInfo valueForKey:@"uid"] isEqualToString:self.uid]) {
        self.settingsController = [STGTSettingsController initWithSettings:self.startSettings];
        self.settingsController.session = self;
        self.locationTracker = [[STGTLocationTracker alloc] init];
        self.locationTracker.session = self;
        self.syncer = [[STGTSyncer alloc] init];
        self.syncer.session = self;
        self.syncer.authDelegate = self.authDelegate;
        self.status = @"running";
    }
}

- (void)setAuthDelegate:(id<STGTRequestAuthenticatable>)authDelegate {
    if (_authDelegate != authDelegate) {
        _authDelegate = authDelegate;
        self.syncer.authDelegate = _authDelegate;
    }
}

- (void)setStatus:(NSString *)status {
    if (_status != status) {
        _status = status;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionStatusChanged" object:self];
    }
}


@end

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
    [self.manager sessionCompletionFinished:self];
}

- (void)documentReady:(NSNotification *)notification {
    if ([[notification.userInfo valueForKey:@"uid"] isEqualToString:self.uid]) {
//        self.settingsController = [[STGTSettingsController alloc] init];
        self.settingsController = [STGTSettingsController initWithSettings:[NSDictionary dictionaryWithObjectsAndKeys:@"200", @"timeFilter", nil]];
        self.settingsController.session = self;
//        NSLog(@"currentSettings1 %@", self.settingsController.currentSettings);
//        [self.settingsController updateSettingsWith:self.startSettings];
//        NSLog(@"currentSettings2 %@", self.settingsController.currentSettings);
        self.tracker = [[STGTTracker alloc] init];
        self.tracker.session = self;
        self.syncer = [[STGTSyncer alloc] init];
        self.syncer.session = self;
        self.syncer.authDelegate = self.authDelegate;
        self.status = @"running";
//        [self.settingsController updateSettingsWith:[NSDictionary dictionaryWithObjectsAndKeys:@"200", @"distanceFilter", nil]];
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

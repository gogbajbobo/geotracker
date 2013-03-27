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
#import "STGTSettingsController.h"

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
        self.tracker = [[STGTTracker alloc] init];
        self.tracker.session = self;
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

- (STGTSettings *)settings {
    if (!_settings && self.document.documentState == UIDocumentStateNormal) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTSettings"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        NSError *error;
        STGTSettings *settings = (STGTSettings *)[[self.document.managedObjectContext executeFetchRequest:request error:&error] lastObject];
        
        if (!settings) {
//            NSLog(@"settings create from defaultSettings");
            settings = (STGTSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTSettings" inManagedObjectContext:self.document.managedObjectContext];
            [settings setValuesForKeysWithDictionary:[STGTSettingsController defaultSettings]];
        } else {
//            NSLog(@"settings load from locationsDatabase success");
        }
        
        if (self.startSettings) {
            for (NSString *key in [settings.entity.propertiesByName allKeys]) {
                if ([[self.startSettings allKeys] containsObject:key]) {
                    [settings setValue:[self.startSettings objectForKey:key] forKey:key];
                }
            }
        }
        
        _settings = settings;
    }
    return _settings;
}


@end

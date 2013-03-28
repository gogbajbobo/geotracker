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
@property (nonatomic, strong) STGTSettingsController *settingsController;

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
//        NSLog(@"self.settings %@", self.settings);
        self.settingsController = [[STGTSettingsController alloc] init];
        self.settingsController.session = self;
        NSLog(@"currentSettings1 %@", self.settingsController.currentSettings);
        [self.settingsController updateSettingsWith:self.startSettings];
        NSLog(@"currentSettings2 %@", self.settingsController.currentSettings);
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

//- (NSArray *)settings {
//    if (!_settings && self.document.documentState == UIDocumentStateNormal) {
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTSettings"];
//        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
//        NSError *error;
//        NSArray *savedSettings = [self.document.managedObjectContext executeFetchRequest:request error:&error];
////        NSLog(@"savedSettings %@", savedSettings);
//        
//        NSDictionary *defaultSettings = [STGTSettingsController defaultSettings];
////        NSLog(@"defaultSettings %@", defaultSettings);
//
//        for (NSString *settingsGroupName in [defaultSettings allKeys]) {
////            NSLog(@"settingsGroup %@", settingsGroupName);
//            NSDictionary *settingsGroup = [defaultSettings valueForKey:settingsGroupName];
//
//            for (NSString *settingName in [settingsGroup allKeys]) {
////                NSLog(@"setting %@ %@", settingName, [settingsGroup valueForKey:settingName]);
//                
//                NSArray *setting;
//                
//                if ([[self.startSettings allKeys] containsObject:settingName]) {
//                    setting = [NSArray arrayWithObjects:[self.startSettings valueForKey:settingName], [[settingsGroup valueForKey:settingName] objectAtIndex:1], nil];
//                } else {
//                    setting = [settingsGroup valueForKey:settingName];
//                }
//                
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@", settingName];
//                STGTSettings *savedSetting = [[savedSettings filteredArrayUsingPredicate:predicate] lastObject];
//                if (!savedSetting) {
//                    NSLog(@"settingName %@", settingName);
//                    STGTSettings *newSetting = (STGTSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTSettings" inManagedObjectContext:self.document.managedObjectContext];
//                    newSetting.group = settingsGroupName;
//                    newSetting.name = settingName;
//                    newSetting.value = [setting objectAtIndex:0];
//                    newSetting.control = [setting objectAtIndex:1];
//                } else {
//                    if (savedSetting.value != [setting objectAtIndex:0]) {
//                        [savedSetting setValue:[setting objectAtIndex:0] forKey:@"value"];
//                    }
//                }
//            }
//        }
//        
//        savedSettings = [self.document.managedObjectContext executeFetchRequest:request error:&error];
//        
////        if (self.startSettings) {
////            for (NSString *key in [settings.entity.propertiesByName allKeys]) {
////                if ([[self.startSettings allKeys] containsObject:key]) {
////                    [settings setValue:[self.startSettings objectForKey:key] forKey:key];
////                }
////            }
////        }
//        
////        NSLog(@"savedSettings %@", savedSettings);
//        _settings = savedSettings;
//    }
//    return _settings;
//}


@end

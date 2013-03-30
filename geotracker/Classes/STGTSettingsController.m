//
//  STGTSettingsController.m
//  geotracking
//
//  Created by Maxim Grigoriev on 1/24/13.
//  Copyright (c) 2013 Maxim V. Grigoriev. All rights reserved.
//

#import "STGTSettingsController.h"
#import "STGTSettings.h"

@interface STGTSettingsController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedSettingsResultController;
@property (nonatomic, strong) NSDictionary *startSettings;

@end

@implementation STGTSettingsController

+ (NSDictionary *)defaultSettings {
    NSMutableDictionary *defaultSettings = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *trackerSettings = [NSMutableDictionary dictionary];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", kCLLocationAccuracyNearestTenMeters], @"slider" , nil] forKey:@"desiredAccuracy"];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 10.0], @"slider" , nil] forKey:@"requiredAccuracy"];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 50.0], @"slider" , nil] forKey:@"distanceFilter"];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 20.0], @"slider" , nil] forKey:@"timeFilter"];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 300.0], @"slider" , nil] forKey:@"trackDetectionTime"];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", NO], @"switch" , nil] forKey:@"trackerAutoStart"];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 8.0], @"slider" , nil] forKey:@"trackerStartTime"];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 20.0], @"slider" , nil] forKey:@"trackerFinishTime"];
    
    [defaultSettings setValue:trackerSettings forKey:@"tracker"];
    
    NSMutableDictionary *mapSettings = [NSMutableDictionary dictionary];
    [mapSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", MKUserTrackingModeNone], @"switch" , nil] forKey:@"mapHeading"];
    [mapSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", MKMapTypeStandard], @"segmentedControl" , nil] forKey:@"mapType"];
    [mapSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 1.5], @"slider" , nil] forKey:@"trackScale"];
    
    [defaultSettings setValue:mapSettings forKey:@"map"];
    
    NSMutableDictionary *syncerSettings = [NSMutableDictionary dictionary];
    [syncerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", 20], @"slider" , nil] forKey:@"fetchLimit"];
    [syncerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 240.0], @"slider" , nil] forKey:@"syncInterval"];
    [syncerSettings setValue:[NSArray arrayWithObjects:@"https://system.unact.ru/asa/?_host=asa0&_svc=chest", @"textField" , nil] forKey:@"syncServerURI"];
    [syncerSettings setValue:[NSArray arrayWithObjects:@"https://github.com/sys-team/ASA.chest", @"textField" , nil] forKey:@"xmlNamespace"];
    
    [defaultSettings setValue:syncerSettings forKey:@"syncer"];
    
    NSMutableDictionary *generalSettings = [NSMutableDictionary dictionary];
    [generalSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", YES], @"switch" , nil] forKey:@"localAccessToSettings"];
    
    [defaultSettings setValue:generalSettings forKey:@"general"];
    
    NSMutableDictionary *batterySettings = [NSMutableDictionary dictionary];
    [batterySettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", YES], @"switch" , nil] forKey:@"checkingBattery"];
    [batterySettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 8.0], @"slider" , nil] forKey:@"batteryCheckingStartTime"];
    [batterySettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", 20.0], @"slider" , nil] forKey:@"batteryCheckingFinishTime"];
    
    [defaultSettings setValue:batterySettings forKey:@"battery"];
    
    return [defaultSettings copy];
}

- (id)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {

}

+ (STGTSettingsController *)initWithSettings:(NSDictionary *)startSettings {
    STGTSettingsController *settingsController = [[STGTSettingsController alloc] init];
    settingsController.startSettings = startSettings;
    return settingsController;
}

- (void)setSession:(id<STGTSession>)session {
    _session = session;

    NSError *error;
    if (![self.fetchedSettingsResultController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    } else {
        [self checkSettings];
    }
}

- (NSFetchedResultsController *)fetchedSettingsResultController {
    if (!_fetchedSettingsResultController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTSettings"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:NO selector:@selector(compare:)]];
//        NSLog(@"session %@", self.session);
//        NSLog(@"document %@", self.session.document);
//        NSLog(@"managedObjectContext %@", self.session.document.managedObjectContext);
        _fetchedSettingsResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedSettingsResultController.delegate = self;
    }
    return _fetchedSettingsResultController;
}

- (NSArray *)currentSettings {
    return self.fetchedSettingsResultController.fetchedObjects;
}

- (NSMutableDictionary *)currentSettingsForGroup:(NSString *)group {
    NSMutableDictionary *settingsDictionary = [NSMutableDictionary dictionary];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.group == %@", group];
    NSArray *groupSettings = [[self currentSettings] filteredArrayUsingPredicate:predicate];
    for (STGTSettings *setting in groupSettings) {
        [settingsDictionary setValue:setting.value forKey:setting.name];
    }
    return settingsDictionary;
}

- (void)checkSettings {
    NSDictionary *defaultSettings = [STGTSettingsController defaultSettings];
    //        NSLog(@"defaultSettings %@", defaultSettings);
    
    for (NSString *settingsGroupName in [defaultSettings allKeys]) {
        //            NSLog(@"settingsGroup %@", settingsGroupName);
        NSDictionary *settingsGroup = [defaultSettings valueForKey:settingsGroupName];
        
        for (NSString *settingName in [settingsGroup allKeys]) {
            //                NSLog(@"setting %@ %@", settingName, [settingsGroup valueForKey:settingName]);
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@", settingName];
            STGTSettings *settingToCheck = [[[self currentSettings] filteredArrayUsingPredicate:predicate] lastObject];

            NSArray *setting;
            if ([[self.startSettings allKeys] containsObject:settingName]) {
                setting = [NSArray arrayWithObjects:[self.startSettings valueForKey:settingName], [[settingsGroup valueForKey:settingName] objectAtIndex:1], nil];
            } else {
                setting = [settingsGroup valueForKey:settingName];
            }

            if (!settingToCheck) {
//                    NSLog(@"settingName %@", settingName);
                STGTSettings *newSetting = (STGTSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTSettings" inManagedObjectContext:self.session.document.managedObjectContext];
                newSetting.group = settingsGroupName;
                newSetting.name = settingName;
                newSetting.value = [setting objectAtIndex:0];
                newSetting.control = [setting objectAtIndex:1];
            } else {
                if ([[self.startSettings allKeys] containsObject:settingName]) {
                    settingToCheck.value = [setting objectAtIndex:0];
                }
            }
        }
    }
//    NSLog(@"fetchedObjects1 %@", self.fetchedSettingsResultController.fetchedObjects);
}

#pragma mark - NSFetchedResultsController delegate


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"controllerDidChangeContent");
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSLog(@"controller didChangeObject");
    
    if ([anObject isKindOfClass:[STGTSettings class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@SettingsChange", [anObject valueForKey:@"group"]] object:anObject userInfo:[NSDictionary dictionaryWithObject:[anObject valueForKey:@"value"] forKey:[anObject valueForKey:@"name"]]];
    }
        
    if (type == NSFetchedResultsChangeDelete) {
        
//        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
//        NSLog(@"NSFetchedResultsChangeInsert");
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
//        NSLog(@"NSFetchedResultsChangeUpdate");
        
    }
    
}


@end

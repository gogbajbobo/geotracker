//
//  STGTSettingsController.m
//  geotracking
//
//  Created by Maxim Grigoriev on 1/24/13.
//  Copyright (c) 2013 Maxim V. Grigoriev. All rights reserved.
//

#import "STGTSettingsController.h"
#import "STGTSettings.h"
#import "STSession.h"

@interface STGTSettingsController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedSettingsResultController;
@property (nonatomic, strong) NSMutableDictionary *startSettings;

@end

@implementation STGTSettingsController


#pragma mark - class methods

+ (NSDictionary *)defaultSettings {
    NSMutableDictionary *defaultSettings = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *locationTrackerSettings = [NSMutableDictionary dictionary];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%f", kCLLocationAccuracyNearestTenMeters] forKey:@"desiredAccuracy"];
    [locationTrackerSettings setValue:@"10.0" forKey:@"requiredAccuracy"];
    [locationTrackerSettings setValue:@"50.0" forKey:@"distanceFilter"];
    [locationTrackerSettings setValue:@"20.0" forKey:@"timeFilter"];
    [locationTrackerSettings setValue:@"300.0" forKey:@"trackDetectionTime"];
    [locationTrackerSettings setValue:@"100.0" forKey:@"trackSeparationDistance"];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"locationTrackerAutoStart"];
    [locationTrackerSettings setValue:@"8.0" forKey:@"locationTrackerStartTime"];
    [locationTrackerSettings setValue:@"20.0" forKey:@"locationTrackerFinishTime"];
    
    [defaultSettings setValue:locationTrackerSettings forKey:@"location"];
    
    
    NSMutableDictionary *mapSettings = [NSMutableDictionary dictionary];
    [mapSettings setValue:[NSString stringWithFormat:@"%d", MKUserTrackingModeNone] forKey:@"mapHeading"];
    [mapSettings setValue:[NSString stringWithFormat:@"%d", MKMapTypeStandard] forKey:@"mapType"];
    [mapSettings setValue:@"1.5" forKey:@"trackScale"];
    
    [defaultSettings setValue:mapSettings forKey:@"map"];
    
    
    NSMutableDictionary *syncerSettings = [NSMutableDictionary dictionary];
    [syncerSettings setValue:@"20" forKey:@"fetchLimit"];
    [syncerSettings setValue:@"240.0" forKey:@"syncInterval"];
    [syncerSettings setValue:@"https://system.unact.ru/asa/?_host=asa0&_svc=chest" forKey:@"syncServerURI"];
    [syncerSettings setValue:@"https://github.com/sys-team/ASA.chest" forKey:@"xmlNamespace"];
    
    [defaultSettings setValue:syncerSettings forKey:@"syncer"];
    
    
    NSMutableDictionary *generalSettings = [NSMutableDictionary dictionary];
    [generalSettings setValue:[NSString stringWithFormat:@"%d", YES] forKey:@"localAccessToSettings"];
    
    [defaultSettings setValue:generalSettings forKey:@"general"];
    
    
    NSMutableDictionary *batteryTrackerSettings = [NSMutableDictionary dictionary];
    [batteryTrackerSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"batteryTrackerAutoStart"];
    [batteryTrackerSettings setValue:@"8.0" forKey:@"batteryTrackerStartTime"];
    [batteryTrackerSettings setValue:@"20.0" forKey:@"batteryTrackerFinishTime"];
    
    [defaultSettings setValue:batteryTrackerSettings forKey:@"battery"];
    
    
    return [defaultSettings copy];
}

+ (NSDictionary *)controlsSettings {
    
    NSMutableDictionary *controlsSettings = [NSMutableDictionary dictionary];

    NSMutableArray *locationTrackerSettings = [NSMutableArray array];
//                                      control, min, max, step
    [locationTrackerSettings addObject:@[@"slider", @"0", @"5", @"1", @"desiredAccuracy"]];
    [locationTrackerSettings addObject:@[@"slider", @"5", @"100", @"10", @"requiredAccuracy"]];
    [locationTrackerSettings addObject:@[@"slider", @"-1", @"200", @"10", @"distanceFilter"]];
    [locationTrackerSettings addObject:@[@"slider", @"1", @"60", @"5", @"timeFilter"]];
    [locationTrackerSettings addObject:@[@"slider", @"0", @"600", @"30", @"trackDetectionTime"]];
    [locationTrackerSettings addObject:@[@"slider", @"1", @"1000", @"100", @"trackSeparationDistance"]];
    [locationTrackerSettings addObject:@[@"switch", @"", @"", @"", @"locationTrackerAutoStart"]];
    [locationTrackerSettings addObject:@[@"slider", @"0", @"24", @"0.5", @"locationTrackerStartTime"]];
    [locationTrackerSettings addObject:@[@"slider", @"0", @"24", @"0.5", @"locationTrackerFinishTime"]];

    [controlsSettings setValue:locationTrackerSettings forKey:@"location"];

    
    NSMutableArray *mapSettings = [NSMutableArray array];
    [mapSettings addObject:@[@"segmentedControl", @"", @"", @"", @"mapHeading"]];
    [mapSettings addObject:@[@"segmentedControl", @"", @"", @"", @"mapType"]];
    [mapSettings addObject:@[@"slider", @"1", @"10", @"0.5", @"trackScale"]];

    [controlsSettings setValue:mapSettings forKey:@"map"];
    
    
    NSMutableArray *syncerSettings = [NSMutableArray array];
    [syncerSettings addObject:@[@"slider", @"10", @"200", @"10", @"fetchLimit"]];
    [syncerSettings addObject:@[@"slider", @"10", @"3600", @"60", @"syncInterval"]];
    [syncerSettings addObject:@[@"textField", @"", @"", @"", @"syncServerURI"]];
    [syncerSettings addObject:@[@"textField", @"", @"", @"", @"xmlNamespace"]];

    [controlsSettings setValue:syncerSettings forKey:@"syncer"];
    
    
    NSMutableArray *generalSettings = [NSMutableArray array];
    [generalSettings addObject:@[@"switch", @"", @"", @"", @"localAccessToSettings"]];

    [controlsSettings setValue:generalSettings forKey:@"general"];
    
    
    NSMutableArray *batteryTrackerSettings = [NSMutableArray array];
    [batteryTrackerSettings addObject:@[@"switch", @"", @"", @"", @"batteryTrackerAutoStart"]];
    [batteryTrackerSettings addObject:@[@"slider", @"0", @"24", @"0.5", @"batteryTrackerStartTime"]];
    [batteryTrackerSettings addObject:@[@"slider", @"0", @"24", @"0.5", @"batteryTrackerFinishTime"]];

    [controlsSettings setValue:batteryTrackerSettings forKey:@"battery"];

//    NSLog(@"controlsSettings %@", controlsSettings);
    return controlsSettings;
}

+ (NSString *)normalizeValue:(NSString *)value forKey:(NSString *)key {
    if ([key isEqualToString:@"desiredAccuracy"]) {
        double dValue = [value doubleValue];
        if (dValue == -2 || dValue == -1 || dValue == 10 || dValue == 100 || dValue == 1000 || dValue == 3000) {
            return [NSString stringWithFormat:@"%f", dValue];
        }
    } else if ([key isEqualToString:@"requiredAccuracy"]) {
        if ([self isPositiveDouble:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
    } else if ([key isEqualToString:@"distanceFilter"]) {
        double dValue = [value doubleValue];
        if (dValue == -1 || dValue >= 0) {
            return [NSString stringWithFormat:@"%f", dValue];
        }
        
    } else if ([key isEqualToString:@"timeFilter"]) {
        if ([self isPositiveDouble:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else if ([key isEqualToString:@"trackDetectionTime"]) {
        if ([self isPositiveDouble:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else if ([key isEqualToString:@"trackDetectionDistance"]) {
        if ([self isPositiveDouble:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else if ([key hasSuffix:@"TrackerAutoStart"]) {
        if ([self isBool:value]) {
            return [NSString stringWithFormat:@"%d", [value boolValue]];
        }
        
    } else if ([key hasSuffix:@"TrackerStartTime"]) {
        if ([self isValidTime:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else if ([key hasSuffix:@"TrackerFinishTime"]) {
        if ([self isValidTime:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else if ([key isEqualToString:@"mapHeading"]) {
        double iValue = [value doubleValue];
        if (iValue == 0 || iValue == 1 || iValue == 2) {
            return [NSString stringWithFormat:@"%.f", iValue];
        }
        
    } else if ([key isEqualToString:@"mapType"]) {
        double iValue = [value doubleValue];
        if (iValue == 0 || iValue == 1 || iValue == 2) {
            return [NSString stringWithFormat:@"%.f", iValue];
        }
        
    } else if ([key isEqualToString:@"fetchLimit"]) {
        if ([self isPositiveDouble:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else if ([key isEqualToString:@"syncInterval"]) {
        if ([self isPositiveDouble:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else if ([key isEqualToString:@"syncServerURI"]) {
        if ([self isValidURI:value]) {
            return value;
        }
        
    } else if ([key isEqualToString:@"xmlNamespace"]) {
        if ([self isValidURI:value]) {
            return value;
        }
        
    } else if ([key isEqualToString:@"localAccessToSettings"]) {
        if ([self isBool:value]) {
            return [NSString stringWithFormat:@"%d", [value boolValue]];
        }
        
    }
    
    return nil;
}


+ (BOOL)isPositiveDouble:(NSString *)value {
    return ([value doubleValue] > 0);
}

+ (BOOL)isBool:(NSString *)value {
    double dValue = [value doubleValue];
    return (dValue == 0 || dValue == 1);
}

+ (BOOL)isValidTime:(NSString *)value {
    double dValue = [value doubleValue];
    return (dValue >= 0 && dValue <= 24);
}

+ (BOOL)isValidURI:(NSString *)value {
    return ([value hasPrefix:@"http://"] || [value hasPrefix:@"https://"]);
}

+ (STGTSettingsController *)initWithSettings:(NSDictionary *)startSettings {
    STGTSettingsController *settingsController = [[STGTSettingsController alloc] init];
    settingsController.startSettings = [startSettings mutableCopy];
    return settingsController;
}

#pragma mark - instance methods

//- (id)init {
//    self = [super init];
//    if (self) {
//        [self customInit];
//    }
//    return self;
//}
//
//- (void)customInit {
//
//}

- (void)setSession:(id<STSession>)session {
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

            NSString *settingValue = [settingsGroup valueForKey:settingName];
            
            if ([[self.startSettings allKeys] containsObject:settingName]) {
                NSString *nValue = [STGTSettingsController normalizeValue:[self.startSettings valueForKey:settingName] forKey:settingName];
                if (nValue) {
                    settingValue = nValue;
                } else {
                    NSLog(@"value is not correct %@", [self.startSettings valueForKey:settingName]);
                    [self.startSettings removeObjectForKey:settingName];
                }
            }

            if (!settingToCheck) {
//                    NSLog(@"settingName %@", settingName);
                STGTSettings *newSetting = (STGTSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTSettings" inManagedObjectContext:self.session.document.managedObjectContext];
                newSetting.group = settingsGroupName;
                newSetting.name = settingName;
                newSetting.value = settingValue;
                [newSetting addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];

            } else {
                [settingToCheck addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
                if ([[self.startSettings allKeys] containsObject:settingName]) {
                    if (![settingToCheck.value isEqualToString:settingValue]) {
                        settingToCheck.value = settingValue;
//                        NSLog(@"new value");
                    }
                }
            }
        }
    }
    [self.session settingsLoadComplete];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"observeChangeValueForObject %@", object);
//    NSLog(@"old value %@", [change valueForKey:NSKeyValueChangeOldKey]);
//    NSLog(@"new value %@", [change valueForKey:NSKeyValueChangeNewKey]);
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"controllerDidChangeContent");
    [[(STSession *)self.session document] saveDocument:^(BOOL success) {
        if (success) {
            NSLog(@"save settings success");
        }
    }];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSLog(@"controller didChangeObject");
    
    if ([anObject isKindOfClass:[STGTSettings class]]) {
//        NSLog(@"anObject %@", anObject);
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

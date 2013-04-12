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
    
    NSMutableDictionary *trackerSettings = [NSMutableDictionary dictionary];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", kCLLocationAccuracyNearestTenMeters], @"slider", @"0", @"5", @"1", nil] forKey:@"desiredAccuracy"];
    [trackerSettings setValue:[NSArray arrayWithObjects:@"10.0", @"slider", @"5", @"100", @"10", nil] forKey:@"requiredAccuracy"];
    [trackerSettings setValue:[NSArray arrayWithObjects:@"50.0", @"slider", @"-1", @"200", @"10", nil] forKey:@"distanceFilter"];
    [trackerSettings setValue:[NSArray arrayWithObjects:@"20.0", @"slider", @"1", @"60", @"5", nil] forKey:@"timeFilter"];
    [trackerSettings setValue:[NSArray arrayWithObjects:@"300.0", @"slider", @"0", @"600", @"30", nil] forKey:@"trackDetectionTime"];
    [trackerSettings setValue:[NSArray arrayWithObjects:@"100.0", @"slider", @"1", @"1000", @"100", nil] forKey:@"trackDetectionDistance"];
    [trackerSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", NO], @"switch", @"", @"", @"", nil] forKey:@"locationTrackerAutoStart"];
    [trackerSettings setValue:[NSArray arrayWithObjects:@"8.0", @"slider", @"0", @"24", @"0.5", nil] forKey:@"locationTrackerStartTime"];
    [trackerSettings setValue:[NSArray arrayWithObjects:@"20.0", @"slider", @"0", @"24", @"0.5", nil] forKey:@"locationTrackerFinishTime"];
    
    [defaultSettings setValue:trackerSettings forKey:@"location"];
    
    NSMutableDictionary *mapSettings = [NSMutableDictionary dictionary];
    [mapSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", MKUserTrackingModeNone], @"segmentedControl", @"", @"", @"", nil] forKey:@"mapHeading"];
    [mapSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", MKMapTypeStandard], @"segmentedControl", @"", @"", @"", nil] forKey:@"mapType"];
    [mapSettings setValue:[NSArray arrayWithObjects:@"1.5", @"slider", @"1", @"10", @"0.5", nil] forKey:@"trackScale"];
    
    [defaultSettings setValue:mapSettings forKey:@"map"];
    
    NSMutableDictionary *syncerSettings = [NSMutableDictionary dictionary];
    [syncerSettings setValue:[NSArray arrayWithObjects:@"20", @"slider", @"10", @"200", @"10", nil] forKey:@"fetchLimit"];
    [syncerSettings setValue:[NSArray arrayWithObjects:@"240.0", @"slider", @"10", @"3600", @"60", nil] forKey:@"syncInterval"];
    [syncerSettings setValue:[NSArray arrayWithObjects:@"https://system.unact.ru/asa/?_host=asa0&_svc=chest", @"textField", @"", @"", @"", nil] forKey:@"syncServerURI"];
    [syncerSettings setValue:[NSArray arrayWithObjects:@"https://github.com/sys-team/ASA.chest", @"textField", @"", @"", @"", nil] forKey:@"xmlNamespace"];
    
    [defaultSettings setValue:syncerSettings forKey:@"syncer"];
    
    NSMutableDictionary *generalSettings = [NSMutableDictionary dictionary];
    [generalSettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", YES], @"switch", @"", @"", @"", nil] forKey:@"localAccessToSettings"];
    
    [defaultSettings setValue:generalSettings forKey:@"general"];
    
    NSMutableDictionary *batterySettings = [NSMutableDictionary dictionary];
    [batterySettings setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", YES], @"switch", @"", @"", @"", nil] forKey:@"batteryTrackerAutoStart"];
    [batterySettings setValue:[NSArray arrayWithObjects:@"8.0", @"slider", @"0", @"24", @"0.5", nil] forKey:@"batteryTrackerStartTime"];
    [batterySettings setValue:[NSArray arrayWithObjects:@"20.0", @"slider", @"0", @"24", @"0.5", nil] forKey:@"batteryTrackerFinishTime"];
    
    [defaultSettings setValue:batterySettings forKey:@"battery"];
    
    return [defaultSettings copy];
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

            NSMutableArray *setting = [[settingsGroup valueForKey:settingName] mutableCopy];
            
            if ([[self.startSettings allKeys] containsObject:settingName]) {
                NSString *nValue = [STGTSettingsController normalizeValue:[self.startSettings valueForKey:settingName] forKey:settingName];
                if (nValue) {
                    [setting replaceObjectAtIndex:0 withObject:nValue];
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
                newSetting.value = [setting objectAtIndex:0];
                newSetting.control = [setting objectAtIndex:1];
                newSetting.min = [setting objectAtIndex:2];
                newSetting.max = [setting objectAtIndex:3];
                newSetting.step = [setting objectAtIndex:4];
                [newSetting addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];

            } else {
                [settingToCheck addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
                if ([[self.startSettings allKeys] containsObject:settingName]) {
                    if (![settingToCheck.value isEqualToString:[setting objectAtIndex:0]]) {
                        settingToCheck.value = [setting objectAtIndex:0];
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

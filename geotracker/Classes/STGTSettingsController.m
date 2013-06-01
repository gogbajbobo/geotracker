//
//  STGTSettingsController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 5/31/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTSettingsController.h"

@implementation STGTSettingsController


- (NSDictionary *)defaultSettings {
    NSMutableDictionary *defaultSettings = [[super defaultSettings] mutableCopy];

    NSMutableDictionary *locationTrackerSettings = [NSMutableDictionary dictionary];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%f", kCLLocationAccuracyBestForNavigation] forKey:@"desiredAccuracy"];
    [locationTrackerSettings setValue:@"10.0" forKey:@"requiredAccuracy"];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%f", kCLDistanceFilterNone] forKey:@"distanceFilter"];
    [locationTrackerSettings setValue:@"0" forKey:@"timeFilter"];

    [locationTrackerSettings setValue:@"300.0" forKey:@"trackDetectionTime"];
    [locationTrackerSettings setValue:@"100.0" forKey:@"trackSeparationDistance"];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"locationTrackerAutoStart"];
    [locationTrackerSettings setValue:@"8.0" forKey:@"locationTrackerStartTime"];
    [locationTrackerSettings setValue:@"20.0" forKey:@"locationTrackerFinishTime"];
    [locationTrackerSettings setValue:@"100.0" forKey:@"maxSpeedThreshold"];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"getLocationsWithNegativeSpeed"];

// Temporarily add for HippoTracker

//    [locationTrackerSettings setValue:@"100.0" forKey:@"HTCheckpointInterval"];
//    [locationTrackerSettings setValue:@"0.7" forKey:@"HTSlowdownValue"];
//    [locationTrackerSettings setValue:@"5" forKey:@"HTStartSpeedThreshold"];
//    [locationTrackerSettings setValue:@"10" forKey:@"HTFinishSpeedThreshold"];
//    [locationTrackerSettings setValue:@"0.1" forKey:@"deviceMotionUpdateInterval"];
//    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"deviceMotionUpdate"];


// ___________________ HippoTracker

    [defaultSettings setValue:locationTrackerSettings forKey:@"location"];


    NSMutableDictionary *mapSettings = [NSMutableDictionary dictionary];
    [mapSettings setValue:[NSString stringWithFormat:@"%d", MKUserTrackingModeNone] forKey:@"mapHeading"];
    [mapSettings setValue:[NSString stringWithFormat:@"%d", MKMapTypeStandard] forKey:@"mapType"];
    [mapSettings setValue:@"1.5" forKey:@"trackScale"];
    [mapSettings setValue:[NSString stringWithFormat:@"%d", mapApple] forKey:@"mapProvider"];

    [defaultSettings setValue:mapSettings forKey:@"map"];


    NSMutableDictionary *syncerSettings = [NSMutableDictionary dictionary];
    [syncerSettings setValue:@"20" forKey:@"fetchLimit"];
    [syncerSettings setValue:@"240.0" forKey:@"syncInterval"];
    [syncerSettings setValue:@"https://asa0.unact.ru/chest" forKey:@"syncServerURI"];
    [syncerSettings setValue:@"https://github.com/sys-team/ASA.chest" forKey:@"xmlNamespace"];

    [defaultSettings setValue:syncerSettings forKey:@"syncer"];

    NSMutableDictionary *batteryTrackerSettings = [NSMutableDictionary dictionary];
    [batteryTrackerSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"batteryTrackerAutoStart"];
    [batteryTrackerSettings setValue:@"8.0" forKey:@"batteryTrackerStartTime"];
    [batteryTrackerSettings setValue:@"20.0" forKey:@"batteryTrackerFinishTime"];

    [defaultSettings setValue:batteryTrackerSettings forKey:@"battery"];


    NSMutableDictionary *generalSettings = [NSMutableDictionary dictionary];
    [generalSettings setValue:[NSString stringWithFormat:@"%d", YES] forKey:@"localAccessToSettings"];

    [defaultSettings setValue:generalSettings forKey:@"general"];

    return [defaultSettings copy];

}

- (NSString *)normalizeValue:(NSString *)value forKey:(NSString *)key {
    
    [super normalizeValue:value forKey:key];
    
    NSArray *positiveDouble = [NSArray arrayWithObjects:@"requiredAccuracy", @"trackDetectionTime", @"trackSeparationDistance", @"trackScale", @"fetchLimit", @"syncInterval", @"HTCheckpointInterval", @"deviceMotionUpdateInterval", nil];

    if ([positiveDouble containsObject:key]) {
        if ([self isPositiveDouble:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }

    } else if ([key isEqualToString:@"desiredAccuracy"]) {
        double dValue = [value doubleValue];
        if (dValue == -2 || dValue == -1 || dValue == 10 || dValue == 100 || dValue == 1000 || dValue == 3000) {
            return [NSString stringWithFormat:@"%f", dValue];
        }

    } else if ([key isEqualToString:@"distanceFilter"]) {
        double dValue = [value doubleValue];
        if (dValue == -1 || dValue >= 0) {
            return [NSString stringWithFormat:@"%f", dValue];
        }

    } else if ([key isEqualToString:@"timeFilter"] || [key isEqualToString:@"maxSpeedThreshold"]) {
        double dValue = [value doubleValue];
        if (dValue >= 0) {
            return [NSString stringWithFormat:@"%f", dValue];
        }

    } else if ([key isEqualToString:@"HTSlowdownValue"]) {
        double dValue = [value doubleValue];
        if (dValue > 0 && dValue < 1) {
            return [NSString stringWithFormat:@"%f", dValue];
        }

    } else  if ([key hasSuffix:@"TrackerAutoStart"] || [key isEqualToString:@"localAccessToSettings"] || [key isEqualToString:@"deviceMotionUpdate"] || [key isEqualToString:@"getLocationsWithNegativeSpeed"]) {
        if ([self isBool:value]) {
            return [NSString stringWithFormat:@"%d", [value boolValue]];
        }

    } else if ([key hasSuffix:@"TrackerStartTime"] || [key hasSuffix:@"TrackerFinishTime"]) {
        if ([self isValidTime:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }

    } else if ([key isEqualToString:@"mapHeading"] || [key isEqualToString:@"mapType"]) {
        double iValue = [value doubleValue];
        if (iValue == 0 || iValue == 1 || iValue == 2) {
            return [NSString stringWithFormat:@"%.f", iValue];
        }

    } else if ([key isEqualToString:@"mapProvider"]) {
        double iValue = [value doubleValue];
        if (iValue == 0 || iValue == 1) {
            return [NSString stringWithFormat:@"%.f", iValue];
        }
        
    } else if ([key isEqualToString:@"syncServerURI"] || [key isEqualToString:@"xmlNamespace"]) {
        if ([self isValidURI:value]) {
            return value;
        }
        
    }
    
    return nil;
}


@end

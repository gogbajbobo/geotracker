//
//  STGTLocationTracker.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTLocationTracker.h"
#import "STGTLocation.h"

@interface STGTLocationTracker() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) STGTTrack *currentTrack;

@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) double requiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic) NSTimeInterval timeFilter;
@property (nonatomic) NSTimeInterval trackDetectionTime;
@property (nonatomic) CLLocationDistance trackDetectionDistance;


@end

@implementation STGTLocationTracker

@synthesize desiredAccuracy = _desiredAccuracy;
//@synthesize requiredAccuracy = _requiredAccuracy;
@synthesize distanceFilter = _distanceFilter;
//@synthesize timeFilter = _timeFilter;
//@synthesize trackDetectionTime = _trackDetectionTime;


- (void)customInit {
    self.group = @"location";
    [super customInit];
}

- (void)trackerSettingsChange:(NSNotification *)notification {
    
    [super trackerSettingsChange:notification];
    
    NSString *key = [[notification.userInfo allKeys] lastObject];
    if ([key isEqualToString:@"distanceFilter"]) {
        self.distanceFilter = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key isEqualToString:@"desiredAccuracy"]) {
        self.desiredAccuracy = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key isEqualToString:@"requiredAccuracy"]) {
        self.requiredAccuracy = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key isEqualToString:@"timeFilter"]) {
        self.timeFilter = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key isEqualToString:@"trackDetectionTime"]) {
        self.trackDetectionTime = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key isEqualToString:@"trackDetectionDistance"]) {
        self.trackDetectionDistance = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key isEqualToString:@"trackerAutoStart"]) {
        self.trackerAutoStart = [[notification.userInfo valueForKey:key] boolValue];
        
    } else if ([key isEqualToString:@"trackerStartTime"]) {
        self.trackerStartTime = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key isEqualToString:@"trackerFinishTime"]) {
        self.trackerFinishTime = [[notification.userInfo valueForKey:key] doubleValue];
        
    }
    //    NSLog(@"self.settings %@", self.settings);
}

#pragma mark - locationTracker settings

- (CLLocationAccuracy) desiredAccuracy {
    if (!_desiredAccuracy) {
        _desiredAccuracy = [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
    }
    return _desiredAccuracy;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    if (_desiredAccuracy != desiredAccuracy) {
        _desiredAccuracy = desiredAccuracy;
        self.locationManager.desiredAccuracy = _desiredAccuracy;
    }
}


- (double)requiredAccuracy {
    if (!_requiredAccuracy) {
        _requiredAccuracy = [[self.settings valueForKey:@"requiredAccuracy"] doubleValue];
    }
    return _requiredAccuracy;
}


- (CLLocationDistance)distanceFilter {
    if (!_distanceFilter) {
        _distanceFilter = [[self.settings valueForKey:@"distanceFilter"] doubleValue];
    }
    return _distanceFilter;
}

- (void)setDistanceFilter:(CLLocationDistance)distanceFilter {
    if (_distanceFilter != distanceFilter) {
        _distanceFilter = distanceFilter;
        self.locationManager.distanceFilter = _distanceFilter;
    }
}


- (NSTimeInterval)timeFilter {
    if (!_timeFilter) {
        _timeFilter = [[self.settings valueForKey:@"timeFilter"] doubleValue];
    }
    return _timeFilter;
}


- (NSTimeInterval)trackDetectionTime {
    if (!_trackDetectionTime) {
        _trackDetectionTime = [[self.settings valueForKey:@"trackDetectionTime"] doubleValue];
    }
    return _trackDetectionTime;
}

- (CLLocationDistance)trackDetectionDistance {
    if (!_trackDetectionDistance) {
        _trackDetectionDistance = [[self.settings valueForKey:@"trackDetectionDistance"] doubleValue];
    }
    return _trackDetectionDistance;
}

- (STGTTrack *)currentTrack {
    if (!_currentTrack) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTTrack"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO selector:@selector(compare:)]];
        NSError *error;
        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:&error];
        if (result.count > 0) {
            _currentTrack = [result objectAtIndex:0];
        }
    }
    return _currentTrack;
}

- (CLLocation *)lastLocation {
    if (!_lastLocation) {
        if (self.currentTrack.locations.count > 0) {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:NO selector:@selector(compare:)]];
            STGTLocation *lastLocation = [[self.currentTrack.locations sortedArrayUsingDescriptors:sortDescriptors] objectAtIndex:0];
            if (lastLocation) {
                _lastLocation = [self locationFromLocationObject:lastLocation];
            }
        }
    }
    return _lastLocation;
}

#pragma mark - tracking

- (void)startTracking {
    [super startTracking];
    if (self.tracking) {
        [[self locationManager] startUpdatingLocation];
    }
}

- (void)stopTracking {
    [[self locationManager] stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    [super stopTracking];
}


#pragma mark - CLLocationManager

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = self.distanceFilter;
        _locationManager.desiredAccuracy = self.desiredAccuracy;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge < 5.0 &&
        newLocation.horizontalAccuracy > 0 &&
        newLocation.horizontalAccuracy <= self.requiredAccuracy) {
        if (!self.lastLocation || [newLocation.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] > self.timeFilter) {
            [self addLocation:newLocation];
        }
    }
    
}

#pragma mark - track management

- (void)addLocation:(CLLocation *)currentLocation {
    //    NSLog(@"addLocation %@", [NSDate date]);
    if (!self.currentTrack) {
        [self startNewTrack];
    }
    NSDate *timestamp = currentLocation.timestamp;
    if ([currentLocation.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] > self.trackDetectionTime && self.currentTrack.locations.count != 0) {
        [self startNewTrack];
        if ([currentLocation distanceFromLocation:self.lastLocation] < self.trackDetectionDistance) {
            NSDate *ts = [NSDate date];
            [self.currentTrack setStartTime:ts];
            [self.currentTrack addLocationsObject:[self locationObjectFromCLLocation:self.lastLocation]];
            //            NSLog(@"copy lastLocation to new Track as first location");
        } else {
            //            NSLog(@"no");
            self.lastLocation = currentLocation;
        }
        timestamp = [NSDate date];
    }
        
    if (self.currentTrack.locations.count == 0) {
        self.currentTrack.startTime = timestamp;
    }
    [self.currentTrack addLocationsObject:[self locationObjectFromCLLocation:currentLocation]];
    self.currentTrack.finishTime = timestamp;
        
    self.lastLocation = currentLocation;
    
    [self.document saveDocument:^(BOOL success) {
        NSLog(@"save newLocation");
        if (success) {
            NSLog(@"save newLocation success");
        }
    }];
    
}

- (void)startNewTrack {
    STGTTrack *track = (STGTTrack *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTTrack" inManagedObjectContext:self.document.managedObjectContext];
    track.startTime = [NSDate date];
    self.currentTrack = track;
    //    NSLog(@"track %@", track);
    [self.document saveDocument:^(BOOL success) {
        NSLog(@"save newTrack");
        if (success) {
            NSLog(@"save newTrack success");
        }
    }];
}

- (void)deleteTrack:(STGTTrack *)track {
    [self.document.managedObjectContext deleteObject:track];
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            NSLog(@"deleteTrack success");
        }
    }];
}

- (void)splitTrack {
    self.currentTrack.finishTime = self.lastLocation.timestamp;
    [self startNewTrack];
    STGTLocation *location = [self locationObjectFromCLLocation:self.lastLocation];
    [self.currentTrack addLocationsObject:location];
    self.lastLocation = [self locationFromLocationObject:location];
}

- (STGTLocation *)locationObjectFromCLLocation:(CLLocation *)location {
    STGTLocation *locationObject = (STGTLocation *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTLocation" inManagedObjectContext:self.document.managedObjectContext];
    [locationObject setLatitude:[NSNumber numberWithDouble:location.coordinate.latitude]];
    [locationObject setLongitude:[NSNumber numberWithDouble:location.coordinate.longitude]];
    [locationObject setHorizontalAccuracy:[NSNumber numberWithDouble:location.horizontalAccuracy]];
    [locationObject setSpeed:[NSNumber numberWithDouble:location.speed]];
    [locationObject setCourse:[NSNumber numberWithDouble:location.course]];
    [locationObject setAltitude:[NSNumber numberWithDouble:location.altitude]];
    [locationObject setVerticalAccuracy:[NSNumber numberWithDouble:location.verticalAccuracy]];
    return locationObject;
}

- (CLLocation *)locationFromLocationObject:(STGTLocation *)locationObject {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locationObject.latitude doubleValue], [locationObject.longitude doubleValue]);
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                  altitude:[locationObject.altitude doubleValue]
                                        horizontalAccuracy:[locationObject.horizontalAccuracy doubleValue]
                                          verticalAccuracy:[locationObject.verticalAccuracy doubleValue]
                                                    course:[locationObject.course doubleValue]
                                                     speed:[locationObject.speed doubleValue]
                                                 timestamp:locationObject.cts];
    return location;
}

@end

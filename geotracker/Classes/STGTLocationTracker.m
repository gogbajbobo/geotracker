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
@property (nonatomic) CLLocationDistance trackSeparationDistance;


@end

@implementation STGTLocationTracker

@synthesize desiredAccuracy = _desiredAccuracy;
@synthesize distanceFilter = _distanceFilter;


- (void)customInit {
    self.group = @"location";
    [super customInit];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([change valueForKey:NSKeyValueChangeNewKey] != [change valueForKey:NSKeyValueChangeOldKey]) {
        if ([keyPath isEqualToString:@"distanceFilter"] || [keyPath isEqualToString:@"desiredAccuracy"]) {
            self.locationManager.desiredAccuracy = [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
            self.locationManager.distanceFilter = [[self.settings valueForKey:@"distanceFilter"] doubleValue];
        }
    }
    
}


#pragma mark - locationTracker settings

- (CLLocationAccuracy) desiredAccuracy {
    return [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
}

- (double)requiredAccuracy {
    return [[self.settings valueForKey:@"requiredAccuracy"] doubleValue];
}


- (CLLocationDistance)distanceFilter {
    return [[self.settings valueForKey:@"distanceFilter"] doubleValue];
}

- (NSTimeInterval)timeFilter {
    return [[self.settings valueForKey:@"timeFilter"] doubleValue];
}

- (NSTimeInterval)trackDetectionTime {
    return [[self.settings valueForKey:@"trackDetectionTime"] doubleValue];
}

- (CLLocationDistance)trackSeparationDistance {
    return [[self.settings valueForKey:@"trackSeparationDistance"] doubleValue];
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
        if ([currentLocation distanceFromLocation:self.lastLocation] < self.trackSeparationDistance) {
            NSDate *ts = [NSDate date];
            [self.currentTrack setStartTime:ts];
            STGTLocation *lastLocation = [self locationObjectFromCLLocation:self.lastLocation];
            lastLocation.timestamp = currentLocation.timestamp;
            [self.currentTrack addLocationsObject:lastLocation];
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
//        NSLog(@"save newLocation");
        if (success) {
            NSLog(@"save newLocation success");
        } else {
            NSLog(@"save newLocation NOT success");
        }
    }];
    
}

- (void)startNewTrack {
    STGTTrack *track = (STGTTrack *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTTrack" inManagedObjectContext:self.document.managedObjectContext];
    track.startTime = [NSDate date];
    self.currentTrack = track;
    //    NSLog(@"track %@", track);
    [self.document saveDocument:^(BOOL success) {
//        NSLog(@"save newTrack");
        if (success) {
            NSLog(@"save newTrack success");
        } else {
            NSLog(@"save newTrack NOT success");
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
    [locationObject setTimestamp:location.timestamp];
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
                                                 timestamp:locationObject.timestamp];
    return location;
}

@end

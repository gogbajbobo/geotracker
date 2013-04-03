//
//  STGTTracker.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTTracker.h"
#import "STGTSession.h"
#import "STGTSettings.h"
#import "STGTTrack.h"
#import "STGTLocation.h"

@interface STGTTracker() <CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic, strong) NSTimer *startTimer;
@property (nonatomic, strong) NSTimer *finishTimer;
@property (nonatomic) BOOL tracking;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) STGTTrack *currentTrack;

@end

@implementation STGTTracker

- (id)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackerSettingsChange:) name:@"trackerSettingsChange" object:[(STGTSession *)self.session settingsController]];
}

- (void)setSession:(id<STGTSession>)session {
    _session = session;
    self.document = [(STGTSession *)session document];
}

- (NSMutableDictionary *)settings {
    if (!_settings) {
        _settings = [[(STGTSession *)self.session settingsController] currentSettingsForGroup:@"tracker"];
    }
    return _settings;
}

- (void)trackerSettingsChange:(NSNotification *)notification {
    [self.settings addEntriesFromDictionary:notification.userInfo];
    NSString *key = [[notification.userInfo allKeys] lastObject];
    if ([key isEqualToString:@"distanceFilter"] || [key isEqualToString:@"desiredAccuracy"]) {
        self.locationManager.distanceFilter = [[self.settings valueForKey:@"distanceFilter"] doubleValue];
        self.locationManager.desiredAccuracy = [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
    } else if ([key isEqualToString:@"trackerAutoStart"]) {
        if ([[self.settings valueForKey:@"trackerAutoStart"] boolValue]) {
            [self checkTrackerAutoStart];
            [self initTimers];
        } else {
            [self releaseTimers];
        }
    }
//    NSLog(@"self.settings %@", self.settings);
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    if ([[(STGTSession *)notification.object status] isEqualToString:@"finishing"]) {
        [self releaseTimers];
        [self stopTracking];
    } else if ([[(STGTSession *)notification.object status] isEqualToString:@"running"]) {
        if ([[self.settings valueForKey:@"trackerAutoStart"] boolValue]) {
            [self checkTrackerAutoStart];
            [self initTimers];
        }
    }
}

#pragma mark - timers

- (void)initTimers {
    [[NSRunLoop currentRunLoop] addTimer:self.startTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:self.finishTimer forMode:NSDefaultRunLoopMode];
}

- (void)releaseTimers {
    [self.startTimer invalidate];
    [self.finishTimer invalidate];
}

- (NSTimer *)startTimer {
    if (!_startTimer) {
        if ([self.settings valueForKey:@"trackerStartTime"]) {
            NSDate *startTime = [self dateFromNumber:[self.settings valueForKey:@"trackerStartTime"]];
            if ([startTime compare:[NSDate date]] == NSOrderedAscending) {
                startTime = [NSDate dateWithTimeInterval:24*3600 sinceDate:startTime];
            }
//            NSLog(@"startTime %@", startTime);
            _startTimer = [[NSTimer alloc] initWithFireDate:startTime interval:24*3600 target:self selector:@selector(startTracking) userInfo:nil repeats:YES];
        }
    }
    return _startTimer;
}

- (NSTimer *)finishTimer {
    if (!_finishTimer) {
        if ([self.settings valueForKey:@"trackerFinishTime"]) {
            NSDate *finishTime = [self dateFromNumber:[self.settings valueForKey:@"trackerFinishTime"]];
            if ([finishTime compare:[NSDate date]] == NSOrderedAscending) {
                finishTime = [NSDate dateWithTimeInterval:24*3600 sinceDate:finishTime];
            }
//            NSLog(@"finishTime %@", finishTime);
            _finishTimer = [[NSTimer alloc] initWithFireDate:finishTime interval:24*3600 target:self selector:@selector(stopTracking) userInfo:nil repeats:YES];
        }
    }
    return _finishTimer;
}

- (void)checkTrackerAutoStart {
    double startTime = [[self.settings valueForKey:@"trackerStartTime"] doubleValue];
    double finishTime = [[self.settings valueForKey:@"trackerFinishTime"] doubleValue];
    double currentTime = [self currentTimeInDouble];
    if (startTime < finishTime) {
        if (currentTime > startTime && currentTime < finishTime) {
            if (!self.tracking) {
                [self startTracking];
            }
        } else {
            if (self.tracking) {
                [self stopTracking];
            }
        }
    } else {
        if (currentTime < startTime && currentTime > finishTime) {
            if (self.tracking) {
                [self stopTracking];
            }
        } else {
            if (!self.tracking) {
                [self startTracking];
            }
        }
    }
}

- (NSDate *)dateFromNumber:(NSNumber *)time {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    double seconds = [time doubleValue] * 3600;
    currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:currentDate]];
    return [NSDate dateWithTimeInterval:seconds sinceDate:currentDate];
}

- (double)currentTimeInDouble {
    NSDate *localDate = [NSDate date];
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    hourFormatter.dateFormat = @"HH";
    double hour = [[hourFormatter stringFromDate:localDate] doubleValue];
    NSDateFormatter *minuteFormatter = [[NSDateFormatter alloc] init];
    minuteFormatter.dateFormat = @"mm";
    double minute = [[minuteFormatter stringFromDate:localDate] doubleValue];
    double currentTime = hour + minute/60;
    return currentTime;
}

#pragma mark - tracking

- (void)startTracking {
//    NSLog(@"startTracking %@", [NSDate date]);
    if ([[(STGTSession *)self.session status] isEqualToString:@"running"]) {
        [[self locationManager] startUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"trackerStart" object:self];
        self.tracking = YES;
    }
}

- (void)stopTracking {
//    NSLog(@"stopTracking %@", [NSDate date]);
    [[self locationManager] stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"trackerStop" object:self];
    self.tracking = NO;
}


#pragma mark - CLLocationManager

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = [[self.settings valueForKey:@"distanceFilter"] doubleValue];
        _locationManager.desiredAccuracy = [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *newLocation = [locations lastObject];
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge < 5.0 &&
        newLocation.horizontalAccuracy > 0 &&
        newLocation.horizontalAccuracy <= [[self.settings valueForKey:@"requiredAccuracy"] doubleValue]) {
        if (!self.lastLocation || [newLocation.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] > [[self.settings valueForKey:@"timeFilter"] doubleValue]) {
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
    if ([currentLocation.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] > [[self.settings valueForKey:@" trackDetectionTime"] doubleValue] && self.currentTrack.locations.count != 0) {
        [self startNewTrack];
        if ([currentLocation distanceFromLocation:self.lastLocation] < (2 * [[self.settings valueForKey:@"distanceFilter"] doubleValue])) {
            NSDate *ts = [NSDate date];
            STGTLocation *location = (STGTLocation *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTLocation" inManagedObjectContext:self.document.managedObjectContext];
            [location setLatitude:[NSNumber numberWithDouble:self.lastLocation.coordinate.latitude]];
            [location setLongitude:[NSNumber numberWithDouble:self.lastLocation.coordinate.longitude]];
            [location setHorizontalAccuracy:[NSNumber numberWithDouble:self.lastLocation.horizontalAccuracy]];
            [location setSpeed:[NSNumber numberWithDouble:-1]];
            [location setCourse:[NSNumber numberWithDouble:-1]];
            [location setAltitude:[NSNumber numberWithDouble:self.lastLocation.altitude]];
            [location setVerticalAccuracy:[NSNumber numberWithDouble:self.lastLocation.verticalAccuracy]];
            [self.currentTrack setStartTime:ts];
            [self.currentTrack addLocationsObject:location];
            //            NSLog(@"copy lastLocation to new Track as first location");
        } else {
            //            NSLog(@"no");
            self.lastLocation = currentLocation;
        }
        timestamp = [NSDate date];
    }
    
    STGTLocation *location = (STGTLocation *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTLocation" inManagedObjectContext:self.document.managedObjectContext];
    CLLocationCoordinate2D coordinate = [currentLocation coordinate];
    [location setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
    [location setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
    [location setHorizontalAccuracy:[NSNumber numberWithDouble:currentLocation.horizontalAccuracy]];
    [location setSpeed:[NSNumber numberWithDouble:currentLocation.speed]];
    [location setCourse:[NSNumber numberWithDouble:currentLocation.course]];
    [location setAltitude:[NSNumber numberWithDouble:currentLocation.altitude]];
    [location setVerticalAccuracy:[NSNumber numberWithDouble:currentLocation.verticalAccuracy]];
    
    if (self.currentTrack.locations.count == 0) {
        self.currentTrack.startTime = timestamp;
    }
    self.currentTrack.finishTime = timestamp;
    [self.currentTrack addLocationsObject:location];
    
    //    NSLog(@"currentLocation %@",currentLocation);
    
    self.lastLocation = currentLocation;
    
//    NSLog(@"location %@", location);
    [self.document saveDocument:^(BOOL success) {
        NSLog(@"addLocation success");
    }];

}

- (void)startNewTrack {
    STGTTrack *track = (STGTTrack *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTTrack" inManagedObjectContext:self.document.managedObjectContext];
    track.startTime = [NSDate date];
    self.currentTrack = track;
//    NSLog(@"track %@", track);
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            NSLog(@"save newTrack success");
        }
    }];
}


@end

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

@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) double requiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic) NSTimeInterval timeFilter;
@property (nonatomic) NSTimeInterval trackDetectionTime;
@property (nonatomic) BOOL trackerAutoStart;
@property (nonatomic) double trackerStartTime;
@property (nonatomic) double trackerFinishTime;

@end

@implementation STGTTracker

@synthesize desiredAccuracy = _desiredAccuracy;
@synthesize requiredAccuracy = _requiredAccuracy;
@synthesize distanceFilter = _distanceFilter;
@synthesize timeFilter = _timeFilter;
@synthesize trackDetectionTime = _trackDetectionTime;
@synthesize trackerAutoStart = _trackerAutoStart;
@synthesize trackerStartTime = _trackerStartTime;
@synthesize trackerFinishTime = _trackerFinishTime;


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
        
    } else if ([key isEqualToString:@"trackerAutoStart"]) {
        self.trackerAutoStart = [[notification.userInfo valueForKey:key] boolValue];
        
    } else if ([key isEqualToString:@"trackerStartTime"]) {
        self.trackerStartTime = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key isEqualToString:@"trackerFinishTime"]) {
        self.trackerFinishTime = [[notification.userInfo valueForKey:key] doubleValue];
        
    }
//    NSLog(@"self.settings %@", self.settings);
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    if ([[(STGTSession *)notification.object status] isEqualToString:@"finishing"]) {
        [self releaseTimers];
        [self stopTracking];
    } else if ([[(STGTSession *)notification.object status] isEqualToString:@"running"]) {
        [self checkTrackerAutoStart];
    }
}

#pragma mark - tracker settings

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


- (BOOL)trackerAutoStart {
    if (!_trackerAutoStart) {
        _trackerAutoStart = [[self.settings valueForKey:@"trackerAutoStart"] boolValue];
    }
    return _trackerAutoStart;
}

- (void)setTrackerAutoStart:(BOOL)trackerAutoStart {
    if (_trackerAutoStart != trackerAutoStart) {
        _trackerAutoStart = trackerAutoStart;
        [self checkTrackerAutoStart];
    }
}


- (double)trackerStartTime {
    if (!_trackerStartTime) {
        _trackerStartTime = [[self.settings valueForKey:@"trackerStartTime"] doubleValue];
    }
    return _trackerStartTime;
}

- (void)setTrackerStartTime:(double)trackerStartTime {
    if (_trackerStartTime != trackerStartTime) {
        _trackerStartTime = trackerStartTime;
        [self checkTrackerAutoStart];
    }
}


- (double)trackerFinishTime {
    if (!_trackerFinishTime) {
        _trackerFinishTime = [[self.settings valueForKey:@"trackerFinishTime"] doubleValue];
    }
    return _trackerFinishTime;
}

- (void)setTrackerFinishTime:(double)trackerFinishTime {
    if (_trackerFinishTime != trackerFinishTime) {
        _trackerFinishTime = trackerFinishTime;
        [self checkTrackerAutoStart];
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
        if (self.trackerStartTime) {
            NSDate *startTime = [self dateFromDouble:self.trackerStartTime];
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
        if (self.trackerFinishTime) {
            NSDate *finishTime = [self dateFromDouble:self.trackerFinishTime];
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
    if (self.trackerAutoStart) {
        if (self.trackerStartTime && self.trackerFinishTime) {
            [self releaseTimers];
            [self checkTimeForTracking];
            [self initTimers];
        } else {
            [self releaseTimers];
            self.trackerAutoStart = NO;
            NSLog(@"trackerStartTime OR trackerFinishTime not set");
        }
    } else {
        [self releaseTimers];
    }
}

- (void)checkTimeForTracking {
    double currentTime = [self currentTimeInDouble];
    if (self.trackerStartTime < self.trackerFinishTime) {
        if (currentTime > self.trackerStartTime && currentTime < self.trackerFinishTime) {
            if (!self.tracking) {
                [self startTracking];
            }
        } else {
            if (self.tracking) {
                [self stopTracking];
            }
        }
    } else {
        if (currentTime < self.trackerStartTime && currentTime > self.trackerFinishTime) {
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

- (NSDate *)dateFromDouble:(double)time {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    double seconds = time * 3600;
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
    NSLog(@"startTracking %@", [NSDate date]);
    if ([[(STGTSession *)self.session status] isEqualToString:@"running"]) {
        [[self locationManager] startUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"trackerStart" object:self];
        self.tracking = YES;
    }
}

- (void)stopTracking {
    NSLog(@"stopTracking %@", [NSDate date]);
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
        if ([currentLocation distanceFromLocation:self.lastLocation] < (2 * self.distanceFilter)) {
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
        if (success) {
            NSLog(@"save newTrack success");
        }
    }];
}


@end

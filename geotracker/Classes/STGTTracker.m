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

@interface STGTTracker() <CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic, strong) NSTimer *startTimer;
@property (nonatomic, strong) NSTimer *finishTimer;
@property (nonatomic) BOOL tracking;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;

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


- (void)startTracking {
//    NSLog(@"startTracking %@", [NSDate date]);
    self.tracking = YES;
}

- (void)stopTracking {
//    NSLog(@"stopTracking %@", [NSDate date]);
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
//        NSLog(@"addLocation");
        }
    }

}



@end

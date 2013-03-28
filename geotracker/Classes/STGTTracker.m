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

@property (nonatomic, strong) NSArray *settings;
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
//    self.settings = [(STGTSession *)self.session settings];
}

- (NSArray *)settings {
    if (!_settings) {
//        _settings = [(STGTSession *)self.session settings];
    }
    return _settings;
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    if ([[(STGTSession *)notification.object status] isEqualToString:@"finishing"]) {
        [self releaseTimers];
        [self stopTracking];
    } else if ([[(STGTSession *)notification.object status] isEqualToString:@"running"]) {
        [self initTimers];
    }
}

- (void)initTimers {
//    if ([self.settings.trackerAutoStart boolValue]) {
//        [[NSRunLoop currentRunLoop] addTimer:self.startTimer forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] addTimer:self.finishTimer forMode:NSDefaultRunLoopMode];
//        
//    }
}

- (void)releaseTimers {
    [self.startTimer invalidate];
    [self.finishTimer invalidate];
}

//- (NSTimer *)startTimer {
//    if (!_startTimer) {
//        if (self.settings.trackerStartTime) {
//            NSDate *startTime = [self dateFromNumber:self.settings.trackerStartTime];
//            _startTimer = [[NSTimer alloc] initWithFireDate:startTime interval:24*3600 target:self selector:@selector(startTracking:) userInfo:nil repeats:YES];
//        }
//    }
//    return _startTimer;
//}

//- (NSTimer *)finishTimer {
//    if (!_finishTimer) {
//        if (self.settings.trackerFinishTime) {
//            NSDate *finishTime = [self dateFromNumber:self.settings.trackerFinishTime];
//            _finishTimer = [[NSTimer alloc] initWithFireDate:finishTime interval:24*3600 target:self selector:@selector(stopTracking:) userInfo:nil repeats:YES];
//        }
//    }
//    return _finishTimer;
//}

//- (void)checkTrackerAutoStart {
//    double startTime = [self.settings.trackerStartTime doubleValue];
//    double finishTime = [self.settings.trackerFinishTime doubleValue];
//    double currentTime = [self currentTimeInDouble];
//    if (startTime < finishTime) {
//        if (currentTime > startTime && currentTime < finishTime) {
//            if (!self.tracking) {
//                [self startTracking];
//            }
//        } else {
//            if (self.tracking) {
//                [self stopTracking];
//            }
//        }
//    } else {
//        if (currentTime < startTime && currentTime > finishTime) {
//            if (self.tracking) {
//                [self stopTracking];
//            }
//        } else {
//            if (!self.tracking) {
//                [self startTracking];
//            }
//        }
//    }
//}

- (NSDate *)dateFromNumber:(NSNumber *)time {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    double seconds = [time doubleValue] * 3600;
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
    self.tracking = YES;
}

- (void)stopTracking {
    self.tracking = NO;
}


#pragma mark - CLLocationManager

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
//        _locationManager.distanceFilter = [self.settings.distanceFilter doubleValue];
//        _locationManager.desiredAccuracy = [self.settings.desiredAccuracy doubleValue];
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    return _locationManager;
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    
//    CLLocation *newLocation = [locations lastObject];
//    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
//    if (locationAge < 5.0 &&
//        newLocation.horizontalAccuracy > 0 &&
//        newLocation.horizontalAccuracy <= [self.settings.requiredAccuracy doubleValue]) {
//        if (!self.lastLocation || [newLocation.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] > [self.settings.timeFilter doubleValue]) {
////        NSLog(@"addLocation");
//        }
//    }
    
//}



@end

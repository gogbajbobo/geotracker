//
//  STGTTracker.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTTracker.h"

@interface STGTTracker()

@end

@implementation STGTTracker

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackerSettingsChange:) name:[NSString stringWithFormat:@"%@SettingsChange", self.group] object:[(id <STSession>)self.session settingsController]];
}

- (void)setSession:(id<STSession>)session {
    _session = session;
    self.document = (STManagedDocument *)[(id <STSession>)session document];
}

- (NSMutableDictionary *)settings {
    if (!_settings) {
        _settings = [[(id <STSession>)self.session settingsController] currentSettingsForGroup:self.group];
//        NSLog(@"settings for %@: %@", self.group, _settings);
    }
    return _settings;
}

- (void)trackerSettingsChange:(NSNotification *)notification {
    
    [self.settings addEntriesFromDictionary:notification.userInfo];
    NSString *key = [[notification.userInfo allKeys] lastObject];

//    NSLog(@"%@ %@", [notification.userInfo valueForKey:key], key);
    if ([key hasSuffix:@"TrackerAutoStart"]) {
        self.trackerAutoStart = [[notification.userInfo valueForKey:key] boolValue];
        
    } else if ([key hasSuffix:@"TrackerStartTime"]) {
        self.trackerStartTime = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key hasSuffix:@"TrackerFinishTime"]) {
        self.trackerFinishTime = [[notification.userInfo valueForKey:key] doubleValue];
        
    }

}

- (void)sessionStatusChanged:(NSNotification *)notification {
    if ([[(id <STSession>)notification.object status] isEqualToString:@"finishing"]) {
        [self releaseTimers];
        [self stopTracking];
    } else if ([[(id <STSession>)notification.object status] isEqualToString:@"running"]) {
        [self checkTrackerAutoStart];
    }
}

#pragma mark - tracker settings

- (BOOL)trackerAutoStart {
    if (!_trackerAutoStart) {
        _trackerAutoStart = [[self.settings valueForKey:[NSString stringWithFormat:@"%@TrackerAutoStart", self.group]] boolValue];
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
        _trackerStartTime = [[self.settings valueForKey:[NSString stringWithFormat:@"%@TrackerStartTime", self.group]] doubleValue];
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
        _trackerFinishTime = [[self.settings valueForKey:[NSString stringWithFormat:@"%@TrackerFinishTime", self.group]] doubleValue];
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
    NSLog(@"%@ startTracking %@", self.group, [NSDate date]);
    if ([[(id <STSession>)self.session status] isEqualToString:@"running"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@TrackingStart", self.group] object:self];
        self.tracking = YES;
    }
}

- (void)stopTracking {
    NSLog(@"%@ stopTracking %@", self.group, [NSDate date]);
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@TrackingStop", self.group] object:self];
    self.tracking = NO;
}


@end

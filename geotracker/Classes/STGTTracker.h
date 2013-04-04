//
//  STGTTracker.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "STSessionManagement.h"
#import "STManagedDocument.h"

@interface STGTTracker : NSObject

@property (strong, nonatomic) STManagedDocument *document;
@property (nonatomic, strong) id <STSession> session;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic, strong) NSTimer *startTimer;
@property (nonatomic, strong) NSTimer *finishTimer;
@property (nonatomic) BOOL tracking;
@property (nonatomic) BOOL trackerAutoStart;
@property (nonatomic) double trackerStartTime;
@property (nonatomic) double trackerFinishTime;
@property (nonatomic, strong) NSString *group;

- (void)customInit;
- (void)startTracking;
- (void)stopTracking;
- (void)trackerSettingsChange:(NSNotification *)notification;

@end

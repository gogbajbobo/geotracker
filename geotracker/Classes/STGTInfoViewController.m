//
//  STGTInfoViewController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/6/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTInfoViewController.h"
#import "STGTMainViewController.h"

@interface STGTInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation STGTInfoViewController


- (void)initView {
    NSString *info;
    
    NSString *bundleVersion = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"BUNDLE VERSION", @""), [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]];

    NSString *uid = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"CURRENT UID", @""), self.currentSession.uid];
    NSString *locationTracker = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"LOCATION TRACKER", @""), self.currentSession.locationTracker.tracking ? NSLocalizedString(@"ON", @"") : NSLocalizedString(@"OFF", @"")];
    NSString *batteryTracker = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"BATTERY TRACKER", @""), self.currentSession.batteryTracker.tracking ? NSLocalizedString(@"ON", @"") : NSLocalizedString(@"OFF", @"")];
    
    NSDictionary *locationTrackerSettings = [self.currentSession.settingsController currentSettingsForGroup:@"location"];
    NSDictionary *syncerSettings = [self.currentSession.settingsController currentSettingsForGroup:@"syncer"];
    NSDictionary *generalSettings = [self.currentSession.settingsController currentSettingsForGroup:@"general"];
    
    NSString *desiredAccuracy = [NSString stringWithFormat:@"%@: %.f", NSLocalizedString(@"desiredAccuracy", @""), [[locationTrackerSettings valueForKey:@"desiredAccuracy"] doubleValue]];
    NSString *requiredAccuracy = [NSString stringWithFormat:@"%@: %.f", NSLocalizedString(@"requiredAccuracy", @""), [[locationTrackerSettings valueForKey:@"requiredAccuracy"] doubleValue]];
    NSString *distanceFilter = [NSString stringWithFormat:@"%@: %.f", NSLocalizedString(@"distanceFilter", @""), [[locationTrackerSettings valueForKey:@"distanceFilter"] doubleValue]];
    NSString *timeFilter = [NSString stringWithFormat:@"%@: %.f", NSLocalizedString(@"timeFilter", @""), [[locationTrackerSettings valueForKey:@"timeFilter"] doubleValue]];
    NSString *trackDetectionTime = [NSString stringWithFormat:@"%@: %.f", NSLocalizedString(@"trackDetectionTime", @""), [[locationTrackerSettings valueForKey:@"trackDetectionTime"] doubleValue]];
    
    NSString *autoStartValues;
    if ([[locationTrackerSettings valueForKey:@"locationTrackerAutoStart"] boolValue]) {
        NSNumberFormatter *timeFormatter = [[NSNumberFormatter alloc] init];
        timeFormatter.formatWidth = 2;
        timeFormatter.paddingCharacter = @"0";
        double time = [[locationTrackerSettings valueForKey:@"locationTrackerStartTime"] doubleValue];
        double hours = floor(time);
        double minutes = rint((time - floor(time)) * 60);
        NSString *startTime = [NSString stringWithFormat:@"%@:%@", [timeFormatter stringFromNumber:[NSNumber numberWithDouble:hours]], [timeFormatter stringFromNumber:[NSNumber numberWithDouble:minutes]]];
        time = [[locationTrackerSettings valueForKey:@"locationTrackerFinishTime"] doubleValue];
        hours = floor(time);
        minutes = rint((time - floor(time)) * 60);
        NSString *finishTime = [NSString stringWithFormat:@"%@:%@", [timeFormatter stringFromNumber:[NSNumber numberWithDouble:hours]], [timeFormatter stringFromNumber:[NSNumber numberWithDouble:minutes]]];
        autoStartValues = [NSString stringWithFormat:@"%@ - %@", startTime, finishTime];

    } else {
        autoStartValues = NSLocalizedString(@"NO", @"");
    }
    
    NSString *locationTrackerAutoStart = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"locationTrackerAutoStart", @""), autoStartValues];
    
    NSString *fetchLimit = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"fetchLimit", @""), [syncerSettings valueForKey:@"fetchLimit"]];
    NSString *syncInterval = [NSString stringWithFormat:@"%@: %.f", NSLocalizedString(@"syncInterval", @""), [[syncerSettings valueForKey:@"syncInterval"] doubleValue]];

    NSString *localAccessToSettings = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"localAccessToSettings", @""), [[generalSettings valueForKey:@"localAccessToSettings"] boolValue] ? NSLocalizedString(@"YES", @"") : NSLocalizedString(@"NO", @"")];

    
    NSString *settings = [NSString stringWithFormat:@"%@\r\n%@\r\n%@\r\n%@\r\n%@\r\n%@\r\n%@\r\n%@\r\n%@", desiredAccuracy, requiredAccuracy, distanceFilter, timeFilter, trackDetectionTime, locationTrackerAutoStart, fetchLimit, syncInterval, localAccessToSettings];
    
    info = [NSString stringWithFormat:@"%@\r\n%@\r\n%@\r\n%@\r\n%@", bundleVersion, uid, locationTracker, batteryTracker, settings];
    self.infoLabel.text = info;
}


#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
    }
}

@end

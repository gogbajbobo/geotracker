//
//  STGTSettingsTableViewController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/13/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTSettingsTableViewController.h"
#import "STGTSettingsController.h"
#import "STSession.h"

@interface STGTSettingsTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSDictionary *controlsSettings;
@property (nonatomic, strong) NSArray *currentSettings;

@end

@interface STGTSettingsTableViewCell ()

@end

@implementation STGTSettingsTableViewCell

- (void) layoutSubviews {

    [super layoutSubviews];

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.textLabel.frame = CGRectMake(10, 10, 220, 24);
    self.textLabel.font = [UIFont boldSystemFontOfSize:16];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.frame = CGRectMake(230, 10, 60, 24);
    self.detailTextLabel.font = [UIFont boldSystemFontOfSize:18];
    self.detailTextLabel.textAlignment = NSTextAlignmentRight;

}


@end


@implementation STGTSettingsTableViewController


#pragma mark - STGTSettingsTableViewController

+ (NSDictionary *)controlsSettings {
    
    NSMutableDictionary *controlsSettings = [NSMutableDictionary dictionary];
    
    NSMutableArray *locationTrackerSettings = [NSMutableArray array];
    //                                      control, min, max, step, name
    [locationTrackerSettings addObject:@[@"slider", @"0", @"5", @"1", @"desiredAccuracy"]];
    [locationTrackerSettings addObject:@[@"slider", @"5", @"100", @"10", @"requiredAccuracy"]];
    [locationTrackerSettings addObject:@[@"slider", @"-1", @"200", @"10", @"distanceFilter"]];
    [locationTrackerSettings addObject:@[@"slider", @"1", @"60", @"5", @"timeFilter"]];
    [locationTrackerSettings addObject:@[@"slider", @"0", @"600", @"30", @"trackDetectionTime"]];
    [locationTrackerSettings addObject:@[@"slider", @"1", @"1000", @"100", @"trackSeparationDistance"]];
    [locationTrackerSettings addObject:@[@"switch", @"", @"", @"", @"locationTrackerAutoStart"]];
    [locationTrackerSettings addObject:@[@"slider", @"0", @"24", @"0.5", @"locationTrackerStartTime"]];
    [locationTrackerSettings addObject:@[@"slider", @"0", @"24", @"0.5", @"locationTrackerFinishTime"]];
    
    [controlsSettings setValue:locationTrackerSettings forKey:@"location"];
    
    
    NSMutableArray *mapSettings = [NSMutableArray array];
    [mapSettings addObject:@[@"segmentedControl", @"1", @"3", @"1", @"mapHeading"]];
    [mapSettings addObject:@[@"segmentedControl", @"1", @"3", @"1", @"mapType"]];
    [mapSettings addObject:@[@"slider", @"1", @"10", @"0.5", @"trackScale"]];
    
    [controlsSettings setValue:mapSettings forKey:@"map"];
    
    
    NSMutableArray *syncerSettings = [NSMutableArray array];
    [syncerSettings addObject:@[@"slider", @"10", @"200", @"10", @"fetchLimit"]];
    [syncerSettings addObject:@[@"slider", @"10", @"3600", @"60", @"syncInterval"]];
    [syncerSettings addObject:@[@"textField", @"", @"", @"", @"syncServerURI"]];
    [syncerSettings addObject:@[@"textField", @"", @"", @"", @"xmlNamespace"]];
    
    [controlsSettings setValue:syncerSettings forKey:@"syncer"];
    
    
    NSMutableArray *generalSettings = [NSMutableArray array];
    [generalSettings addObject:@[@"switch", @"", @"", @"", @"localAccessToSettings"]];
    
    [controlsSettings setValue:generalSettings forKey:@"general"];
    
    
    NSMutableArray *batteryTrackerSettings = [NSMutableArray array];
    [batteryTrackerSettings addObject:@[@"switch", @"", @"", @"", @"batteryTrackerAutoStart"]];
    [batteryTrackerSettings addObject:@[@"slider", @"0", @"24", @"0.5", @"batteryTrackerStartTime"]];
    [batteryTrackerSettings addObject:@[@"slider", @"0", @"24", @"0.5", @"batteryTrackerFinishTime"]];
    
    [controlsSettings setValue:batteryTrackerSettings forKey:@"battery"];
    
    //    NSLog(@"controlsSettings %@", controlsSettings);
    return controlsSettings;
}


- (NSDictionary *)controlsSettings {
    if (!_controlsSettings) {
        _controlsSettings = [STGTSettingsTableViewController controlsSettings];
    }
    return _controlsSettings;
}

- (NSArray *)currentSettings {
    if (!_currentSettings) {
        _currentSettings = [[(STSession *)self.session settingsController] currentSettings];
    }
    return _currentSettings;
}

- (NSArray *)settingsGroupForSection:(NSInteger)section {
    NSArray *keys = [self.controlsSettings allKeys];
    return [self.controlsSettings valueForKey:[keys objectAtIndex:section]];
}

- (NSString *)controlTypeForIndexPath:(NSIndexPath *)indexPath {
    NSArray *controlGroup = [self settingsGroupForSection:indexPath.section];
    return [[controlGroup objectAtIndex:indexPath.row] objectAtIndex:0];
}

- (NSString *)minForIndexPath:(NSIndexPath *)indexPath {
    NSArray *controlGroup = [self settingsGroupForSection:indexPath.section];
    return [[controlGroup objectAtIndex:indexPath.row] objectAtIndex:1];
}

- (NSString *)maxForIndexPath:(NSIndexPath *)indexPath {
    NSArray *controlGroup = [self settingsGroupForSection:indexPath.section];
    return [[controlGroup objectAtIndex:indexPath.row] objectAtIndex:2];
}

- (NSString *)stepForIndexPath:(NSIndexPath *)indexPath {
    NSArray *controlGroup = [self settingsGroupForSection:indexPath.section];
    return [[controlGroup objectAtIndex:indexPath.row] objectAtIndex:3];
}

- (NSString *)settingNameForIndexPath:(NSIndexPath *)indexPath {
    NSArray *controlGroup = [self settingsGroupForSection:indexPath.section];
    return [[controlGroup objectAtIndex:indexPath.row] lastObject];
}

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath {
    
    NSString *settingName = [self settingNameForIndexPath:indexPath];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@", settingName];
    NSString *value = [[[self.currentSettings filteredArrayUsingPredicate:predicate] lastObject] valueForKey:@"value"];
    
    if ([[self controlTypeForIndexPath:indexPath] isEqualToString:@"slider"]) {
        if ([settingName hasSuffix:@"StartTime"] || [settingName hasSuffix:@"FinishTime"]) {
            double time = [value doubleValue];
            double hours = floor(time);
            double minutes = rint((time - floor(time)) * 60);
            NSNumberFormatter *timeFormatter = [[NSNumberFormatter alloc] init];
            timeFormatter.formatWidth = 2;
            timeFormatter.paddingCharacter = @"0";
            value = [NSString stringWithFormat:@"%@:%@", [timeFormatter stringFromNumber:[NSNumber numberWithDouble:hours]], [timeFormatter stringFromNumber:[NSNumber numberWithDouble:minutes]]];
        } else if ([settingName isEqualToString:@"trackScale"]) {
            value = [NSString stringWithFormat:@"%.1f", [value doubleValue]];
        } else {
            value = [NSString stringWithFormat:@"%.f", [value doubleValue]];
        }
    }
    
    return value;
}

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"SETTINGS", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.controlsSettings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [self.controlsSettings allKeys];
    return [[self.controlsSettings valueForKey:[keys objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = [NSString stringWithFormat:@"SETTING%@",[[self.controlsSettings allKeys] objectAtIndex:section]];
    return NSLocalizedString(title, @"");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *controlType = [self controlTypeForIndexPath:indexPath];
    
    if ([controlType isEqualToString:@"slider"] || [controlType isEqualToString:@"textField"]) {
        return 70.0;
    } else if ([controlType isEqualToString:@"switch"] || [controlType isEqualToString:@"segmentedControl"]) {
        return 44.0;
    } else {
        return 0.0;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"settingCell";
    STGTSettingsTableViewCell *cell = nil;
    
    NSString *controlType = [self controlTypeForIndexPath:indexPath];
    
    if ([controlType isEqualToString:@"slider"]) {
        cell = [[STGTSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.detailTextLabel.text = [self valueForIndexPath:indexPath];
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(25, 38, 270, 24)];
        slider.maximumValue = [[self maxForIndexPath:indexPath] doubleValue];
        slider.minimumValue = [[self minForIndexPath:indexPath] doubleValue];
        if ([[self settingNameForIndexPath:indexPath] isEqualToString:@"desiredAccuracy"]) {
            double value = [[self valueForIndexPath:indexPath] doubleValue];
            NSArray *accuracyArray = [NSArray arrayWithObjects: [NSNumber numberWithDouble:kCLLocationAccuracyBestForNavigation],
                                      [NSNumber numberWithDouble:kCLLocationAccuracyBest],
                                      [NSNumber numberWithDouble:kCLLocationAccuracyNearestTenMeters],
                                      [NSNumber numberWithDouble:kCLLocationAccuracyHundredMeters],
                                      [NSNumber numberWithDouble:kCLLocationAccuracyKilometer],
                                      [NSNumber numberWithDouble:kCLLocationAccuracyThreeKilometers],nil];
            value = [accuracyArray indexOfObject:[NSNumber numberWithDouble:value]];
            if (value == NSNotFound) {
                NSLog(@"NSNotFoundS");
                value = [accuracyArray indexOfObject:[NSNumber numberWithDouble:kCLLocationAccuracyNearestTenMeters]];
            }
            slider.value = value;
        } else {
            slider.value = [[self valueForIndexPath:indexPath] doubleValue];            
        }

        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderValueChangeFinished:) forControlEvents:UIControlEventTouchUpInside];

        [cell.contentView addSubview:slider];
        
    } else {
        cell = [[STGTSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        if ([controlType isEqualToString:@"switch"]) {
            UISwitch *headingSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(230, 9, 80, 27)];
            [headingSwitch setOn:[[self valueForIndexPath:indexPath] boolValue] animated:NO];
//            [headingSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:headingSwitch];

        } else if ([controlType isEqualToString:@"textField"]) {
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(25, 38, 270, 24)];
            textField.text = [self valueForIndexPath:indexPath];
            textField.font = [UIFont systemFontOfSize:14];
            textField.keyboardType = UIKeyboardTypeURL;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.delegate = self;
            [cell.contentView addSubview:textField];
            
        } else if ([controlType isEqualToString:@"segmentedControl"]) {
            int i = [[self minForIndexPath:indexPath] intValue];
            int ii = [[self maxForIndexPath:indexPath] intValue];
            int step = [[self stepForIndexPath:indexPath] intValue];
            
            NSMutableArray *segments = [NSMutableArray array];
            while (i <= ii) {
                NSString *segmentTitle = [NSString stringWithFormat:@"%@_%d", [self settingNameForIndexPath:indexPath], i];
                [segments addObject:NSLocalizedString(segmentTitle, @"")];
                i += step;
            }
            
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segments];
            segmentedControl.frame = CGRectMake(110, 7, 200, 30);
            segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
            NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:12], UITextAttributeFont, nil];
            [segmentedControl setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
//            [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
            segmentedControl.selectedSegmentIndex = [[self valueForIndexPath:indexPath] integerValue];
            [cell.contentView addSubview:segmentedControl];

        }

    }
    
    cell.textLabel.text = NSLocalizedString([self settingNameForIndexPath:indexPath], @"");
    
    return cell;
}


#pragma mark - controls

- (void)sliderValueChanged:(UISlider *)slider {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)slider.superview.superview];
    NSString *settingName = [self settingNameForIndexPath:indexPath];
    double step = [[self stepForIndexPath:indexPath] doubleValue];

//    NSDictionary *stepValue = [NSDictionary dictionaryWithObjectsAndKeys:
//                               [NSNumber numberWithDouble:10], @"requiredAccuracy",
//                               [NSNumber numberWithDouble:5], @"timeFilter",
//                               [NSNumber numberWithDouble:30], @"trackDetectionTime",
//                               [NSNumber numberWithDouble:60], @"syncInterval",
//                               [NSNumber numberWithDouble:10], @"fetchLimit",
//                               [NSNumber numberWithDouble:0.5], @"trackerStartTime",
//                               [NSNumber numberWithDouble:0.5], @"trackerFinishTime",
//                               [NSNumber numberWithDouble:0.5], @"trackScale", nil];
    
    if ([settingName isEqualToString:@"desiredAccuracy"]) {
//        NSArray *accuracyArray = [NSArray arrayWithObjects: [NSNumber numberWithDouble:kCLLocationAccuracyBestForNavigation],
//                                  [NSNumber numberWithDouble:kCLLocationAccuracyBest],
//                                  [NSNumber numberWithDouble:kCLLocationAccuracyNearestTenMeters],
//                                  [NSNumber numberWithDouble:kCLLocationAccuracyHundredMeters],
//                                  [NSNumber numberWithDouble:kCLLocationAccuracyKilometer],
//                                  [NSNumber numberWithDouble:kCLLocationAccuracyThreeKilometers],nil];
        [slider setValue:rint(slider.value)];
//        self.settings.desiredAccuracy = [accuracyArray objectAtIndex:(NSUInteger)sender.value];
    } else if ([settingName isEqualToString:@"distanceFilter"]) {
        [slider setValue:floor(slider.value/10)*10];
//        self.settings.distanceFilter = [NSNumber numberWithDouble:sender.value];
        //    } else if ([settingName isEqualToString:@"batteryCheckingInterval"]) {
        //        [sender setValue:rint(sender.value/60)*60];
        //        UILabel *valueLabel = (UILabel *)[[(UITableViewCell *)sender.superview.superview contentView] viewWithTag:2];
        //        valueLabel.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:sender.value]];
    } else {
        [slider setValue:rint(slider.value/step)*step];
//        [self.settings setValue:[NSNumber numberWithDouble:sender.value] forKey:settingName];
    }
    
}

- (void)sliderValueChangeFinished:(UISlider *)slider {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)slider.superview.superview];
    NSString *settingName = [self settingNameForIndexPath:indexPath];
    NSString *value = [NSString stringWithFormat:@"%f", slider.value];
    if ([settingName isEqualToString:@"desiredAccuracy"]) {
        NSArray *accuracyArray = [NSArray arrayWithObjects: [NSNumber numberWithDouble:kCLLocationAccuracyBestForNavigation],
                                  [NSNumber numberWithDouble:kCLLocationAccuracyBest],
                                  [NSNumber numberWithDouble:kCLLocationAccuracyNearestTenMeters],
                                  [NSNumber numberWithDouble:kCLLocationAccuracyHundredMeters],
                                  [NSNumber numberWithDouble:kCLLocationAccuracyKilometer],
                                  [NSNumber numberWithDouble:kCLLocationAccuracyThreeKilometers],nil];
        value = [NSString stringWithFormat:@"%@", [accuracyArray objectAtIndex:rint(slider.value)]];
    }
//    NSLog(@"value %@", value);
    [[(STSession *)self.session settingsController] applyNewSettings:[NSDictionary dictionaryWithObjectsAndKeys:value, settingName, nil]];
}

@end

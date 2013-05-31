//
//  STGTSettingsTableViewController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/13/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTSettingsController.h"
#import "STGTSettingsTableViewController.h"
#import "STSession.h"

@interface STGTSettingsTableViewController () <UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSDictionary *controlsSettings;
//@property (nonatomic, strong) NSFetchedResultsController *settingsResultController;

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
    [mapSettings addObject:@[@"segmentedControl", @"0", @"2", @"1", @"mapHeading"]];
    [mapSettings addObject:@[@"segmentedControl", @"0", @"2", @"1", @"mapType"]];
    [mapSettings addObject:@[@"segmentedControl", @"0", @"1", @"1", @"mapProvider"]];
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
    
    NSArray *groupNames = [NSArray arrayWithObjects:@"general", @"location", @"battery", @"map", @"syncer", nil];
    [controlsSettings setValue:groupNames forKey:@"groupNames"];
    
    //    NSLog(@"controlsSettings %@", controlsSettings);
    return controlsSettings;
}


- (NSDictionary *)controlsSettings {
    if (!_controlsSettings) {
        _controlsSettings = [STGTSettingsTableViewController controlsSettings];
    }
    return _controlsSettings;
}

- (STSettings *)settingObjectForIndexPath:(NSIndexPath *)indexPath {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.group == %@ && SELF.name == %@", [[self groupNames] objectAtIndex:indexPath.section], [self settingNameForIndexPath:indexPath]];
    return [[[[(STSession *)self.session settingsController] currentSettings] filteredArrayUsingPredicate:predicate] lastObject];
}

- (NSArray *)groupNames {
    return [[self controlsSettings] valueForKey:@"groupNames"];
}

- (NSArray *)settingsGroupForSection:(NSInteger)section {
    NSString *groupName = [[self groupNames] objectAtIndex:section];
    return [self.controlsSettings valueForKey:groupName];
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
    
    return [[[self settingsGroupForSection:indexPath.section] objectAtIndex:indexPath.row] lastObject];
}


- (NSIndexPath *)indexPathForGroup:(NSString *)groupName setting:(NSString *)settingName {
    NSInteger *section = [[self groupNames] indexOfObject:groupName];
    NSInteger *row;
    for (NSArray *controlSetting in [self settingsGroupForSection:section]) {
        if ([[controlSetting lastObject] isEqualToString:settingName]) {
            row = [[self settingsGroupForSection:section] indexOfObject:controlSetting];
        }
    }
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath {
    
    NSString *settingName = [self settingNameForIndexPath:indexPath];
    NSString *value = [[self settingObjectForIndexPath:indexPath] valueForKey:@"value"];
    if ([[self controlTypeForIndexPath:indexPath] isEqualToString:@"slider"]) {
        value = [self formatValue:value forSettingName:settingName];
    }
    return value;

}

- (NSString *)formatValue:(NSString *)valueString forSettingName:(NSString *)settingName{
    
    if ([settingName hasSuffix:@"StartTime"] || [settingName hasSuffix:@"FinishTime"]) {
        double time = [valueString doubleValue];
        double hours = floor(time);
        double minutes = rint((time - floor(time)) * 60);
        NSNumberFormatter *timeFormatter = [[NSNumberFormatter alloc] init];
        timeFormatter.formatWidth = 2;
        timeFormatter.paddingCharacter = @"0";
        valueString = [NSString stringWithFormat:@"%@:%@", [timeFormatter stringFromNumber:[NSNumber numberWithDouble:hours]], [timeFormatter stringFromNumber:[NSNumber numberWithDouble:minutes]]];
    } else if ([settingName isEqualToString:@"trackScale"]) {
        valueString = [NSString stringWithFormat:@"%.1f", [valueString doubleValue]];
    } else {
        valueString = [NSString stringWithFormat:@"%.f", [valueString doubleValue]];
    }
    return valueString;

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self groupNames] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [self groupNames];
    return [[self.controlsSettings valueForKey:[keys objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = [NSString stringWithFormat:@"SETTING%@",[[self groupNames] objectAtIndex:section]];
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
        [self addSliderToCell:cell atIndexPath:indexPath];

    } else {
        cell = [[STGTSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        if ([controlType isEqualToString:@"switch"]) {
            [self addSwitchToCell:cell atIndexPath:indexPath];

        } else if ([controlType isEqualToString:@"textField"]) {
            [self addTextFieldToCell:cell atIndexPath:indexPath];
            
        } else if ([controlType isEqualToString:@"segmentedControl"]) {
            [self addSegmentedControlToCell:cell atIndexPath:indexPath];

        }

    }
    
    cell.textLabel.text = NSLocalizedString([self settingNameForIndexPath:indexPath], @"");
    
    return cell;
}

- (void)addSliderToCell:(STGTSettingsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.detailTextLabel.text = [self valueForIndexPath:indexPath];
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(25, 38, 270, 24)];
    slider.maximumValue = [[self maxForIndexPath:indexPath] doubleValue];
    slider.minimumValue = [[self minForIndexPath:indexPath] doubleValue];
    [self setSlider:slider value:[[self valueForIndexPath:indexPath] doubleValue] forSettingName:[self settingNameForIndexPath:indexPath]];
    
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderValueChangeFinished:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:slider];
    cell.slider = slider;

}

- (void)addSwitchToCell:(STGTSettingsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    UISwitch *senderSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(230, 9, 80, 27)];
    [senderSwitch setOn:[[self valueForIndexPath:indexPath] boolValue] animated:NO];
    [senderSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:senderSwitch];
    cell.senderSwitch = senderSwitch;

}

- (void)addTextFieldToCell:(STGTSettingsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(25, 38, 270, 24)];
    textField.text = [self valueForIndexPath:indexPath];
    textField.font = [UIFont systemFontOfSize:14];
    textField.keyboardType = UIKeyboardTypeURL;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.delegate = self;
    [cell.contentView addSubview:textField];
    cell.textField = textField;

}

- (void)addSegmentedControlToCell:(STGTSettingsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
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
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = [[self valueForIndexPath:indexPath] integerValue];
    [cell.contentView addSubview:segmentedControl];
    cell.segmentedControl = segmentedControl;

}


#pragma mark - show changes in situ

- (void)settingsChanged:(NSNotification *)notification {
//    NSLog(@"notification.userInfo %@", notification.userInfo);
    NSString *groupName = [[notification.userInfo valueForKey:@"changedObject"] valueForKey:@"group"];
    NSString *settingName = [[notification.userInfo valueForKey:@"changedObject"] valueForKey:@"name"];
    NSIndexPath *indexPath = [self indexPathForGroup:groupName setting:settingName];
    STGTSettingsTableViewCell *cell = (STGTSettingsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *value = [self valueForIndexPath:indexPath];
    cell.detailTextLabel.text = value;
    [self setSlider:cell.slider value:[value doubleValue] forSettingName:settingName];
    [cell.senderSwitch setOn:[value boolValue]];
    [cell.segmentedControl setSelectedSegmentIndex:[value integerValue]];
    cell.textField.text = value;
}


#pragma mark - controls

- (void)setSlider:(UISlider *)slider value:(double)value forSettingName:(NSString *)settingName {
    
    if ([settingName isEqualToString:@"desiredAccuracy"]) {
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
    }
    slider.value = value;

}

- (void)sliderValueChanged:(UISlider *)slider {
    
    STGTSettingsTableViewCell *cell = (STGTSettingsTableViewCell *)slider.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *settingName = [self settingNameForIndexPath:indexPath];
    double step = [[self stepForIndexPath:indexPath] doubleValue];
    
    if ([settingName isEqualToString:@"distanceFilter"]) {
        [slider setValue:floor(slider.value/step)*step];
    } else {
        [slider setValue:rint(slider.value/step)*step];
    }
    
    NSString *value = [NSString stringWithFormat:@"%f", slider.value];
    if ([settingName isEqualToString:@"desiredAccuracy"]) {
        value = [self desiredAccuracyValueFrom:rint(slider.value)];
    }
    cell.detailTextLabel.text = [self formatValue:value forSettingName:settingName];
}

- (void)sliderValueChangeFinished:(UISlider *)slider {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(STGTSettingsTableViewCell *)slider.superview.superview];
    NSString *settingName = [self settingNameForIndexPath:indexPath];
    NSString *value = [NSString stringWithFormat:@"%f", slider.value];
    if ([settingName isEqualToString:@"desiredAccuracy"]) {
        value = [self desiredAccuracyValueFrom:rint(slider.value)];
    }
    NSString *groupName = [[self groupNames] objectAtIndex:indexPath.section];
    [[(STSession *)self.session settingsController] addNewSettings:[NSDictionary dictionaryWithObjectsAndKeys:value, settingName, nil] forGroup:groupName];

}

- (NSString *)desiredAccuracyValueFrom:(int)index {
    NSArray *accuracyArray = [NSArray arrayWithObjects: [NSNumber numberWithDouble:kCLLocationAccuracyBestForNavigation],
                              [NSNumber numberWithDouble:kCLLocationAccuracyBest],
                              [NSNumber numberWithDouble:kCLLocationAccuracyNearestTenMeters],
                              [NSNumber numberWithDouble:kCLLocationAccuracyHundredMeters],
                              [NSNumber numberWithDouble:kCLLocationAccuracyKilometer],
                              [NSNumber numberWithDouble:kCLLocationAccuracyThreeKilometers],nil];
    return [NSString stringWithFormat:@"%@", [accuracyArray objectAtIndex:index]];
}

- (void)switchValueChanged:(UISwitch *)senderSwitch {
    STGTSettingsTableViewCell *cell = (STGTSettingsTableViewCell *)senderSwitch.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *settingName = [self settingNameForIndexPath:indexPath];
    NSString *value = [NSString stringWithFormat:@"%d", senderSwitch.on];
    NSString *groupName = [[self groupNames] objectAtIndex:indexPath.section];
    [[(STSession *)self.session settingsController] addNewSettings:[NSDictionary dictionaryWithObjectsAndKeys:value, settingName, nil] forGroup:groupName];
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
    STGTSettingsTableViewCell *cell = (STGTSettingsTableViewCell *)segmentedControl.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *settingName = [self settingNameForIndexPath:indexPath];
    NSString *value = [NSString stringWithFormat:@"%d", segmentedControl.selectedSegmentIndex];
    NSString *groupName = [[self groupNames] objectAtIndex:indexPath.section];
    [[(STSession *)self.session settingsController] addNewSettings:[NSDictionary dictionaryWithObjectsAndKeys:value, settingName, nil] forGroup:groupName];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    STGTSettingsTableViewCell *cell = (STGTSettingsTableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *settingName = [self settingNameForIndexPath:indexPath];
    NSString *groupName = [[self groupNames] objectAtIndex:indexPath.section];
    textField.text = [[(STSession *)self.session settingsController] addNewSettings:[NSDictionary dictionaryWithObjectsAndKeys:textField.text, settingName, nil] forGroup:groupName];

    return YES;
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

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:@"settingsChanged" object:self.session];
    [super viewWillAppear:animated];
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
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"settingsChanged" object:self.session];
        self.view = nil;
    }
}

@end

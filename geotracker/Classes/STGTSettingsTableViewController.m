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

@interface STGTSettingsTableViewController () <UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSDictionary *controlsSettings;
@property (nonatomic, strong) NSFetchedResultsController *settingsResultController;

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
    
    NSMutableDictionary *locationTrackerSettings = [NSMutableDictionary dictionary];
    //                                      control, min, max, step
    [locationTrackerSettings setValue:@[@"slider", @"0", @"5", @"1"] forKey:@"desiredAccuracy"];
    [locationTrackerSettings setValue:@[@"slider", @"5", @"100", @"10"] forKey:@"requiredAccuracy"];
    [locationTrackerSettings setValue:@[@"slider", @"-1", @"200", @"10"] forKey:@"distanceFilter"];
    [locationTrackerSettings setValue:@[@"slider", @"1", @"60", @"5"] forKey:@"timeFilter"];
    [locationTrackerSettings setValue:@[@"slider", @"0", @"600", @"30"] forKey:@"trackDetectionTime"];
    [locationTrackerSettings setValue:@[@"slider", @"1", @"1000", @"100"] forKey:@"trackSeparationDistance"];
    [locationTrackerSettings setValue:@[@"switch", @"", @"", @""] forKey:@"locationTrackerAutoStart"];
    [locationTrackerSettings setValue:@[@"slider", @"0", @"24", @"0.5"] forKey:@"locationTrackerStartTime"];
    [locationTrackerSettings setValue:@[@"slider", @"0", @"24", @"0.5"] forKey:@"locationTrackerFinishTime"];
    
    [controlsSettings setValue:locationTrackerSettings forKey:@"location"];
    
    
    NSMutableDictionary *mapSettings = [NSMutableDictionary dictionary];
    [mapSettings setValue:@[@"segmentedControl", @"1", @"3", @"1"] forKey:@"mapHeading"];
    [mapSettings setValue:@[@"segmentedControl", @"1", @"3", @"1"] forKey:@"mapType"];
    [mapSettings setValue:@[@"slider", @"1", @"10", @"0.5"] forKey:@"trackScale"];
    
    [controlsSettings setValue:mapSettings forKey:@"map"];
    
    
    NSMutableDictionary *syncerSettings = [NSMutableDictionary dictionary];
    [syncerSettings setValue:@[@"slider", @"10", @"200", @"10"] forKey:@"fetchLimit"];
    [syncerSettings setValue:@[@"slider", @"10", @"3600", @"60"] forKey:@"syncInterval"];
    [syncerSettings setValue:@[@"textField", @"", @"", @""] forKey:@"syncServerURI"];
    [syncerSettings setValue:@[@"textField", @"", @"", @""] forKey:@"xmlNamespace"];
    
    [controlsSettings setValue:syncerSettings forKey:@"syncer"];
    
    
    NSMutableDictionary *generalSettings = [NSMutableDictionary dictionary];
    [generalSettings setValue:@[@"switch", @"", @"", @""] forKey:@"localAccessToSettings"];
    
    [controlsSettings setValue:generalSettings forKey:@"general"];
    
    
    NSMutableDictionary *batteryTrackerSettings = [NSMutableDictionary dictionary];
    [batteryTrackerSettings setValue:@[@"switch", @"", @"", @""] forKey:@"batteryTrackerAutoStart"];
    [batteryTrackerSettings setValue:@[@"slider", @"0", @"24", @"0.5"] forKey:@"batteryTrackerStartTime"];
    [batteryTrackerSettings setValue:@[@"slider", @"0", @"24", @"0.5"] forKey:@"batteryTrackerFinishTime"];
    
    [controlsSettings setValue:batteryTrackerSettings forKey:@"battery"];
    
    //    NSLog(@"controlsSettings %@", controlsSettings);
    return controlsSettings;
}

- (void)setSession:(id<STSession>)session {
    _session = session;
    NSError *error;
    if (![self.settingsResultController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    } else {

    }
}

- (NSFetchedResultsController *)settingsResultController {
    if (!_settingsResultController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTSettings"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        _settingsResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:@"group" cacheName:nil];
        _settingsResultController.delegate = self;
    }
    return _settingsResultController;
}


- (NSDictionary *)controlsSettings {
    if (!_controlsSettings) {
        _controlsSettings = [STGTSettingsTableViewController controlsSettings];
    }
    return _controlsSettings;
}

- (STGTSettings *)settingObjectForIndexPath:(NSIndexPath *)indexPath {
    return [[[[self.settingsResultController sections] objectAtIndex:indexPath.section] objects] objectAtIndex:indexPath.row];
}

- (NSDictionary *)settingsGroupForSection:(NSInteger)section {
    NSString *groupName = [[[self.settingsResultController sections] objectAtIndex:section] name];
    return [self.controlsSettings valueForKey:groupName];
}

- (NSString *)controlTypeForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *controlGroup = [self settingsGroupForSection:indexPath.section];
    return [[controlGroup valueForKey:[self settingNameForIndexPath:indexPath]] objectAtIndex:0];
}

- (NSString *)minForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *controlGroup = [self settingsGroupForSection:indexPath.section];
    return [[controlGroup valueForKey:[self settingNameForIndexPath:indexPath]] objectAtIndex:1];
}

- (NSString *)maxForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *controlGroup = [self settingsGroupForSection:indexPath.section];
    return [[controlGroup valueForKey:[self settingNameForIndexPath:indexPath]] objectAtIndex:2];
}

- (NSString *)stepForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *controlGroup = [self settingsGroupForSection:indexPath.section];
    return [[controlGroup valueForKey:[self settingNameForIndexPath:indexPath]] objectAtIndex:3];
}

- (NSString *)settingNameForIndexPath:(NSIndexPath *)indexPath {
    return [[self settingObjectForIndexPath:indexPath] valueForKey:@"name"];
}

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath {
    
    NSString *settingName = [self settingNameForIndexPath:indexPath];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@", settingName];
//    NSString *value = [[[self.settingsResultController.fetchedObjects filteredArrayUsingPredicate:predicate] lastObject] valueForKey:@"value"];
    
    NSString *value = [[self settingObjectForIndexPath:indexPath] valueForKey:@"value"];
    
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
//    NSLog(@"section %d, row %d id %@", indexPath.section, indexPath.row, [[self settingObjectForIndexPath:indexPath] valueForKey:@"id"]);
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
    return [[self.settingsResultController sections] count];
//    return [self.controlsSettings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSArray *keys = [self.controlsSettings allKeys];
//    return [[self.controlsSettings valueForKey:[keys objectAtIndex:section]] count];
    return [[[self.settingsResultController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = [NSString stringWithFormat:@"SETTING%@",[[[self.settingsResultController sections] objectAtIndex:section] name]];
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
    
    if ([settingName isEqualToString:@"distanceFilter"]) {
        [slider setValue:floor(slider.value/step)*step];
    } else {
        [slider setValue:rint(slider.value/step)*step];
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
    [[(STSession *)self.session settingsController] applyNewSettings:[NSDictionary dictionaryWithObjectsAndKeys:value, settingName, nil]];
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerDidChangeContent");
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
        
    if (type == NSFetchedResultsChangeDelete) {
        
        //        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
        //        NSLog(@"NSFetchedResultsChangeInsert");
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        //        NSLog(@"NSFetchedResultsChangeUpdate");
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
    
}

@end

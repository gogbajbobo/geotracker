//
//  STGTSettingsTableViewController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/13/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTSettingsTableViewController.h"
#import "STGTSettingsController.h"

@interface STGTSettingsTableViewController ()

@property (nonatomic, strong) NSDictionary *controlsSettings;

@end

@implementation STGTSettingsTableViewController


- (NSDictionary *)controlsSettings {
    if (!_controlsSettings) {
        _controlsSettings = [STGTSettingsController controlsSettings];
    }
    return _controlsSettings;
}

- (NSString *)controlTypeForIndexPath:(NSIndexPath *)indexPath {
    NSArray *keys = [self.controlsSettings allKeys];
    NSArray *controlGroup = [self.controlsSettings valueForKey:[keys objectAtIndex:indexPath.section]];
    return [[controlGroup objectAtIndex:indexPath.row] objectAtIndex:0];
}

- (NSString *)controlNameForIndexPath:(NSIndexPath *)indexPath {
    NSArray *keys = [self.controlsSettings allKeys];
    NSArray *controlGroup = [self.controlsSettings valueForKey:[keys objectAtIndex:indexPath.section]];
    return [[controlGroup objectAtIndex:indexPath.row] lastObject];
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = NSLocalizedString([self controlNameForIndexPath:indexPath], @"");
    cell.detailTextLabel.text = @"123";
    
    return cell;
}


@end

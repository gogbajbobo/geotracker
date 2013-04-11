//
//  STGTTrackController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/5/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTTrackController.h"
#import "STGTLocation.h"

@interface STGTTrackController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation STGTTrackController

- (void)setCurrentSession:(STSession *)currentSession {
    
    _currentSession = currentSession;
    self.resultsController = nil;
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    } else {
        
    }
    
}

- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTTrack"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO selector:@selector(compare:)]];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.currentSession.document.managedObjectContext sectionNameKeyPath:@"dayAsString" cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

- (STGTTrack *)currentTrack {
    if (self.resultsController.fetchedObjects.count > 0) {
        return (STGTTrack *)[self.resultsController.fetchedObjects objectAtIndex:0];
    } else {
        return nil;
    }
}

- (NSDictionary *)currentTrackInfo {
    
    NSDictionary *currentTrackInfo;
    
    NSDictionary *trackInfo = [self infoForTrack:[self currentTrack]];
        
    currentTrackInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [trackInfo valueForKey:@"overallDistance"], @"overallDistance",
                        [trackInfo valueForKey:@"averageSpeed"], @"averageSpeed",
                        [[self currentTrack] startTime], @"startTime",
                        nil];
    
    return currentTrackInfo;
    
}

- (NSDictionary *)summaryInfo {
    
    NSDictionary *summaryInfo;
    CLLocationDistance overallDistance = 0.0;
    NSTimeInterval overallTime = 0.0;
    CLLocationSpeed averageSpeed = 0.0;

    for (STGTTrack *track in self.resultsController.fetchedObjects) {
        
        NSDictionary *trackInfo = [self infoForTrack:track];
        overallDistance += [[trackInfo valueForKey:@"overallDistance"] doubleValue];
        overallTime += [[trackInfo valueForKey:@"overallTime"] doubleValue];
    }

    if (overallTime != 0) {
        averageSpeed = fabs(3.6 * overallDistance / overallTime);
    }

    summaryInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithDouble:overallDistance], @"overallDistance",
                    [NSNumber numberWithDouble:averageSpeed], @"averageSpeed",
                    [NSNumber numberWithInt:self.resultsController.fetchedObjects.count], @"numberOfTracks",
                    nil];
    
    
    return summaryInfo;

}

- (NSDictionary *)infoForTrack:(STGTTrack *)track {
    CLLocationDistance overallDistance = 0.0;
    NSTimeInterval overallTime = 0.0;
    CLLocationSpeed averageSpeed = 0.0;
    STGTLocation *previousLocation;
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:NO selector:@selector(compare:)]];
    for (STGTLocation *location in [track.locations sortedArrayUsingDescriptors:sortDescriptors]) {
        if (previousLocation) {
            CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:[previousLocation.latitude doubleValue] longitude:[previousLocation.longitude doubleValue]];
            CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[location.latitude doubleValue] longitude:[location.longitude doubleValue]];
            overallDistance += fabs([loc1 distanceFromLocation:loc2]);
        }
        previousLocation = location;
    }
    
    overallTime = [[self currentTrack].finishTime timeIntervalSinceDate:[self currentTrack].startTime];

    if (overallTime != 0) {
        averageSpeed = fabs(3.6 * overallDistance / overallTime);
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:overallDistance], @"overallDistance",
            [NSNumber numberWithDouble:overallTime], @"overallTime",
            [NSNumber numberWithDouble:averageSpeed], @"averageSpeed",
            nil];
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerDidChangeContent");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"trackControllerDidChangeContent" object:self];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
    
    if ([[self.currentSession status] isEqualToString:@"running"]) {
        
        
        if (type == NSFetchedResultsChangeDelete) {
            
            //        NSLog(@"NSFetchedResultsChangeDelete");
            
            if ([self.tableView numberOfRowsInSection:indexPath.section] == 1) {
                [self.tableView reloadData];
            } else {
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            }
            
        } else if (type == NSFetchedResultsChangeInsert) {
            
            //        NSLog(@"NSFetchedResultsChangeInsert");
            
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            
        } else if (type == NSFetchedResultsChangeUpdate) {
            
            //        NSLog(@"NSFetchedResultsChangeUpdate");
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        
    }
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.resultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:section];
    
    double ddistance = 0;
    for (STGTTrack *track in [sectionInfo objects]) {
        ddistance += [[[self infoForTrack:track] valueForKey:@"overallDistance"] doubleValue];
    }
    int idistance = ddistance;
    
    NSString *keyString;
    int testNumber = [sectionInfo numberOfObjects] % 100;
    if (testNumber >= 11 && testNumber <= 19) {
        keyString = @"5TRACKS";
    } else {
        int switchNumber = testNumber % 10;
        switch (switchNumber) {
            case 1:
                keyString = @"1TRACKS";
                break;
            case 2:
            case 3:
            case 4:
                keyString = @"2TRACKS";
                break;
            default:
                keyString = @"5TRACKS";
                break;
        }
    }
    
    return [NSString stringWithFormat:@"%@ - %d %@ - %d%@", [sectionInfo name], [sectionInfo numberOfObjects], NSLocalizedString(keyString, @""), idistance, NSLocalizedString(@"M", @"")];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"trackCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    //    STGTTrack *track = (STGTTrack *)[self.resultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    STGTTrack *track = (STGTTrack *)[[sectionInfo objects] objectAtIndex:indexPath.row];
    
    NSDictionary *trackInfo = [self infoForTrack:track];
    
    NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
    [startDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [startDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSDateFormatter *finishDateFormatter = [[NSDateFormatter alloc] init];
    [finishDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [finishDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSNumberFormatter *distanceNumberFormatter = [[NSNumberFormatter alloc] init];
    [distanceNumberFormatter setMaximumFractionDigits:0];
    
    NSNumberFormatter *speedNumberFormatter = [[NSNumberFormatter alloc] init];
    [speedNumberFormatter setMaximumFractionDigits:1];
    
    NSString *overallDistance = [distanceNumberFormatter stringFromNumber:[trackInfo valueForKey:@"overallDistance"]];
    NSString *averageSpeed = [speedNumberFormatter stringFromNumber:[trackInfo valueForKey:@"averageSpeed"]];
    
    
    UIColor *textColor;
    if ([track.ts compare:track.lts] == NSOrderedAscending) {
        textColor = [UIColor blackColor];
        cell.tag = 1;
    } else {
        textColor = [UIColor grayColor];
    }
    cell.textLabel.textColor = textColor;
    cell.detailTextLabel.textColor = textColor;
    
    NSString *keyString;
    if (track.locations.count == 0) {
        keyString = @"0POINTS";
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@ %@%@ %@", overallDistance, NSLocalizedString(@"M", @""), averageSpeed, NSLocalizedString(@"KM/H", @""), NSLocalizedString(keyString, @"")];
    } else {
        int testNumber = track.locations.count % 100;
        if (testNumber >= 11 && testNumber <= 19) {
            keyString = @"5POINTS";
        } else {
            int switchNumber = testNumber % 10;
            switch (switchNumber) {
                case 1:
                    keyString = @"1POINTS";
                    break;
                case 2:
                case 3:
                case 4:
                    keyString = @"2POINTS";
                    break;
                default:
                    keyString = @"5POINTS";
                    break;
            }
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@ %@%@ %d %@", overallDistance, NSLocalizedString(@"M", @""), averageSpeed, NSLocalizedString(@"KM/H", @""), track.locations.count, NSLocalizedString(keyString, @"")];
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ — %@", [startDateFormatter stringFromDate:track.startTime], [finishDateFormatter stringFromDate:track.finishTime]];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if ([self currentTrack].locations.count != 0) {
            return UITableViewCellEditingStyleDelete;
        } else {
            return UITableViewCellEditingStyleNone;
        }
    } else {
        BOOL localAccessToSettings = [[[self.currentSession.settingsController currentSettingsForGroup:@"general"] valueForKey:@"localAccessToSettings"] integerValue];
        if (!localAccessToSettings && [tableView cellForRowAtIndexPath:indexPath].tag == 0) {
            return UITableViewCellEditingStyleNone;
        } else {
            return UITableViewCellEditingStyleDelete;
        }
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0 && indexPath.row == 0 && self.currentTrack.locations.count != 0) {
            [self.currentSession.locationTracker startNewTrack];
        } else {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
            STGTTrack *track = (STGTTrack *)[[sectionInfo objects] objectAtIndex:indexPath.row];
            [self.currentSession.locationTracker deleteTrack:track];
        }
    }
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger trackNumber = 0;
    for (int i = 0; i < indexPath.section; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:i];
        trackNumber = trackNumber + [sectionInfo numberOfObjects];
    }
    trackNumber = trackNumber + indexPath.row;
    //    self.selectedTrackNumber = trackNumber;
    //    self.locationsArray = [self locationsArrayForTrack:trackNumber];
    return indexPath;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return NSLocalizedString(@"ADD NEW TRACK", @"");
    } else {
        return nil;
    }
}

@end

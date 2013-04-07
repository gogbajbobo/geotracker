//
//  STLogger.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/6/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STLogger.h"
#import "STManagedDocument.h"
#import "STGTLogMessage.h"

@interface STLogger() <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) STManagedDocument *document;
@property (strong, nonatomic) NSFetchedResultsController *resultsController;

@end


@implementation STLogger

- (void)setSession:(id<STSession>)session {
    _session = session;
    self.document = (STManagedDocument *)[(id <STSession>)session document];
}

- (void)setDocument:(STManagedDocument *)document {
    
    _document = document;
    
    self.resultsController = nil;
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    } else {
        
    }
    
}

- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTLogMessage"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:NO selector:@selector(compare:)]];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

- (void)saveLogMessageWithText:(NSString *)text type:(NSString *)type {
    STGTLogMessage *logMessage = (STGTLogMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTLogMessage" inManagedObjectContext:self.document.managedObjectContext];
    logMessage.text = text;
    logMessage.type = type;
    NSLog(@"%@", text);
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            NSLog(@"save logMessage success");
        }
    }];

}


#pragma mark - Table view data source

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
    return [sectionInfo name];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
    [startDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [startDateFormatter setTimeStyle:NSDateFormatterMediumStyle];

    cell.textLabel.text = [[self.resultsController.fetchedObjects objectAtIndex:indexPath.row] text];
    
    cell.detailTextLabel.text = [startDateFormatter stringFromDate:[[self.resultsController.fetchedObjects objectAtIndex:indexPath.row] cts]];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        if (self.currentTrack.locations.count != 0) {
//            return UITableViewCellEditingStyleDelete;
//        } else {
            return UITableViewCellEditingStyleNone;
//        }
//    } else {
//        if (![self.settings.localAccessToSettings boolValue] && [tableView cellForRowAtIndexPath:indexPath].tag == 0) {
//            return UITableViewCellEditingStyleNone;
//        } else {
//            return UITableViewCellEditingStyleDelete;
//        }
//    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        if (indexPath.section == 0 && indexPath.row == 0 && self.currentTrack.locations.count != 0) {
//            [self startNewTrack];
//        } else {
//            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
//            STGTTrack *track = (STGTTrack *)[[sectionInfo objects] objectAtIndex:indexPath.row];
//            [self deleteTrack:track];
//        }
//    }
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSInteger trackNumber = 0;
//    for (int i = 0; i < indexPath.section; i++) {
//        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:i];
//        trackNumber = trackNumber + [sectionInfo numberOfObjects];
//    }
//    trackNumber = trackNumber + indexPath.row;
//    self.selectedTrackNumber = trackNumber;
//    self.locationsArray = [self locationsArrayForTrack:trackNumber];
    return indexPath;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        return NSLocalizedString(@"ADD NEW TRACK", @"");
//    } else {
        return nil;
//    }
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
    
    if (type == NSFetchedResultsChangeDelete) {
        
        //        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
        //        NSLog(@"NSFetchedResultsChangeInsert");
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        //        NSLog(@"NSFetchedResultsChangeUpdate");
        
    }
    
}


@end
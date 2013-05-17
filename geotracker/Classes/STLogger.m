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
@property (nonatomic) BOOL lastMessageWasError;

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
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"dayAsString" cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

- (void)saveLogMessageWithText:(NSString *)text type:(NSString *)type {
    STGTLogMessage *logMessage = (STGTLogMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTLogMessage" inManagedObjectContext:self.document.managedObjectContext];
    logMessage.text = text;
    logMessage.type = type;

    if ([type isEqualToString:@"error"]) {
        if ([text rangeOfString:@"syncer" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerErrorLogMessageRecieved" object:self];
            self.lastMessageWasError = YES;
        }
    } else {
        if ([text rangeOfString:@"syncer" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            if (self.lastMessageWasError) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerErrorLogMessageGone" object:self];
            }
        }
    }

    NSLog(@"%@", text);
    [self.document saveDocument:^(BOOL success) {
//        NSLog(@"save logMessage %@", text);
        if (success) {
//            NSLog(@"save logMessage success");
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
    static NSString *cellIdentifier = @"logCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
    [startDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [startDateFormatter setTimeStyle:NSDateFormatterMediumStyle];

    STGTLogMessage *logMessage = [self.resultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = logMessage.text;
    if ([logMessage.type isEqualToString:@"error"]) {
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.detailTextLabel.text = [startDateFormatter stringFromDate:logMessage.cts];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewCellEditingStyleNone;

}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {

    return nil;

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
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        //        NSLog(@"NSFetchedResultsChangeUpdate");

    }
    
}


@end

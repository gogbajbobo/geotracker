//
//  STGTTrackController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/5/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTTrackController.h"
#import "STGTTrack.h"
#import "STGTLocation.h"

@interface STGTTrackController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation STGTTrackController

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
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTTrack"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO selector:@selector(compare:)]];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"dayAsString" cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

- (STGTTrack *)currentTrack {
    return (STGTTrack *)[self.resultsController.fetchedObjects objectAtIndex:0];
}

- (NSDictionary *)currentTrackInfo {
    
    NSDictionary *currentTrackInfo;
    
    CLLocationDistance overallDistance = 0.0;
    NSTimeInterval trackOverallTime = 0.0;
    CLLocationSpeed averageSpeed = 0.0;
    
    STGTLocation *previousLocation;
    for (STGTLocation *location in [[self currentTrack] locations]) {
        if (!previousLocation) {
            previousLocation = location;
        } else {
            CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:[previousLocation.latitude doubleValue] longitude:[previousLocation.longitude doubleValue]];
            CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[location.latitude doubleValue] longitude:[location.longitude doubleValue]];
            overallDistance = overallDistance + fabs([loc1 distanceFromLocation:loc2]);
        }
    }
    
    trackOverallTime = [[self currentTrack].finishTime timeIntervalSinceDate:[self currentTrack].startTime];
    
    if (trackOverallTime != 0) {
        averageSpeed = fabs(3.6 * overallDistance / trackOverallTime);
    }
    
    currentTrackInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithDouble:overallDistance], @"overallDistance",
                        [NSNumber numberWithDouble:averageSpeed], @"averageSpeed",
                        [[self currentTrack] startTime], @"startTime",
                        nil];
    
    
    return currentTrackInfo;
    
}

- (NSDictionary *)summaryInfo {
    
    NSDictionary *summaryInfo;
    CLLocationDistance overallDistance = 0.0;
    NSTimeInterval trackOverallTime = 0.0;
    CLLocationSpeed averageSpeed = 0.0;

    for (STGTTrack *track in self.resultsController.fetchedObjects) {
        
        STGTLocation *previousLocation;
        for (STGTLocation *location in track.locations) {
            if (!previousLocation) {
                previousLocation = location;
            } else {
                CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:[previousLocation.latitude doubleValue] longitude:[previousLocation.longitude doubleValue]];
                CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[location.latitude doubleValue] longitude:[location.longitude doubleValue]];
                overallDistance = overallDistance + fabs([loc1 distanceFromLocation:loc2]);
            }
        }
        
        trackOverallTime = trackOverallTime + [track.finishTime timeIntervalSinceDate:track.startTime];
    }

    if (trackOverallTime != 0) {
        averageSpeed = fabs(3.6 * overallDistance / trackOverallTime);
    }

    summaryInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithDouble:overallDistance], @"overallDistance",
                    [NSNumber numberWithDouble:averageSpeed], @"averageSpeed",
                    [NSNumber numberWithInt:self.resultsController.fetchedObjects.count], @"numberOfTracks",
                    nil];
    
    
    return summaryInfo;

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

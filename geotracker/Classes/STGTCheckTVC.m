//
//  STHTCheckTVC.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/16/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTCheckTVC.h"
#import <CoreData/CoreData.h>
#import "STGTLocation.h"

@interface STGTCheckTVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSMutableDictionary *overallTimes;
@property (nonatomic, strong) NSMutableDictionary *overallDistances;

@end

@implementation STGTCheckTVC


- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTLocation"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.track == %@", self.track];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

- (void)performFetch {
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    } else {
        
    }
}





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
    self.overallDistances = [NSMutableDictionary dictionary];
    self.overallTimes = [NSMutableDictionary dictionary];
    [self performFetch];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"checkCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    for (UIView *subviews in cell.contentView.subviews) {
//        if ([subviews isKindOfClass:[UILabel class]]) {
//            [subviews removeFromSuperview];
//        }
//    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    STGTLocation *location = (STGTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 40, 24)];
    
    if (indexPath.row == 0) {
        firstLabel.text = @"t";
    } else {
        STGTLocation *previousLocation = (STGTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row-1];
        NSTimeInterval timeInterval = -[previousLocation.timestamp timeIntervalSinceDate:location.timestamp];
        firstLabel.text = [NSString stringWithFormat:@"%.2f", timeInterval];
    }
    
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 50, 24)];
    if (indexPath.row == 0) {
        secondLabel.text = @"ot";
    } else {
        
        secondLabel.text = [NSString stringWithFormat:@"%.2f", [self overallTimeFor:indexPath]];
    }

    UILabel *thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 40, 24)];
    if (indexPath.row == 0) {
        thirdLabel.text = @"d";
    } else {
        STGTLocation *previousLocation = (STGTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row-1];
        CLLocation *loc = [self locationFromLocationObject:location];
        CLLocation *prevLoc = [self locationFromLocationObject:previousLocation];
        CLLocationDistance distance = [loc distanceFromLocation:prevLoc];
        thirdLabel.text = [NSString stringWithFormat:@"%.2f", distance];
    }

    UILabel *fourthLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, 50, 24)];
    if (indexPath.row == 0) {
        fourthLabel.text = @"od";
    } else {
        fourthLabel.text = [NSString stringWithFormat:@"%.2f", [self overallDistanceFor:indexPath]];
    }
    
    UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 10, 80, 24)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    timestampLabel.text = [dateFormatter stringFromDate:location.timestamp];
    
    UILabel *accuracyLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 10, 20, 24)];
    accuracyLabel.text = [NSString stringWithFormat:@"%@", location.horizontalAccuracy];

    UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 10, 30, 24)];
    double speed = [location.speed doubleValue] *3.6;
//    double speed = [location.course doubleValue];
    speedLabel.text = [NSString stringWithFormat:@"%.1f", speed];

    firstLabel.font = font;
    secondLabel.font = font;
    thirdLabel.font = font;
    fourthLabel.font = font;
    timestampLabel.font = font;
    accuracyLabel.font = font;
    speedLabel.font = font;
    
    [cell.contentView addSubview:firstLabel];
    [cell.contentView addSubview:secondLabel];
    [cell.contentView addSubview:thirdLabel];
    [cell.contentView addSubview:fourthLabel];
    [cell.contentView addSubview:timestampLabel];
    [cell.contentView addSubview:accuracyLabel];
    [cell.contentView addSubview:speedLabel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (NSTimeInterval)overallTimeFor:(NSIndexPath *)indexPath {
    NSTimeInterval overallTime = 0;
    if (indexPath.row != 0) {
        NSNumber *result = [self.overallTimes valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        if (!result) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
            STGTLocation *location = (STGTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row];
            STGTLocation *previousLocation = (STGTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row-1];
            NSTimeInterval timeInterval = [location.timestamp timeIntervalSinceDate:previousLocation.timestamp];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            NSTimeInterval previousTime = [self overallTimeFor:previousIndexPath];
            overallTime = previousTime + timeInterval;
            [self.overallTimes setValue:[NSNumber numberWithDouble:overallTime] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        } else {
            overallTime = [result doubleValue];
        }
    }
    return overallTime;
}


- (CLLocationDistance)overallDistanceFor:(NSIndexPath *)indexPath {
    CLLocationDistance overallDistance = 0;
    if (indexPath.row != 0) {
        NSNumber *result = [self.overallDistances valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        if (!result) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
            STGTLocation *location = (STGTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row];
            STGTLocation *previousLocation = (STGTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row-1];
            CLLocation *loc = [self locationFromLocationObject:location];
            CLLocation *prevLoc = [self locationFromLocationObject:previousLocation];
            CLLocationDistance distance = [loc distanceFromLocation:prevLoc];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            CLLocationDistance previousDistance = [self overallDistanceFor:previousIndexPath];
            overallDistance = previousDistance + distance;
            [self.overallDistances setValue:[NSNumber numberWithDouble:overallDistance] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        } else {
            overallDistance = [result doubleValue];
        }
    }
    return overallDistance;
}

- (CLLocation *)locationFromLocationObject:(STLocation *)locationObject {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locationObject.latitude doubleValue], [locationObject.longitude doubleValue]);
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                         altitude:[locationObject.altitude doubleValue]
                                               horizontalAccuracy:[locationObject.horizontalAccuracy doubleValue]
                                                 verticalAccuracy:[locationObject.verticalAccuracy doubleValue]
                                                           course:[locationObject.course doubleValue]
                                                            speed:[locationObject.speed doubleValue]
                                                        timestamp:locationObject.timestamp];
    return location;
}





/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
//    STHTLocation *location = (STHTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row];
//    NSString *message = [NSString stringWithFormat:@"timestamp %@ \r\n accuracy %@ \r\n", location.timestamp, location.horizontalAccuracy];
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location info" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    [alert show];
//}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"controllerDidChangeContent");
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSLog(@"controller didChangeObject");
    
    if (type == NSFetchedResultsChangeDelete) {
        
        //        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
        //        NSLog(@"NSFetchedResultsChangeInsert");
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        //        NSLog(@"NSFetchedResultsChangeUpdate");
        
    }
    
}


@end

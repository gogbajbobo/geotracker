//
//  STGTTrack.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/2/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STGTDatum.h"

@class STGTLocation;

@interface STGTTrack : STGTDatum

@property (nonatomic, retain) NSDate * finishTime;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSSet *locations;
@end

@interface STGTTrack (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(STGTLocation *)value;
- (void)removeLocationsObject:(STGTLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end

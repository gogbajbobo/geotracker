//
//  STGTInterest.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/29/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STGTInterestImage, STGTSpot;

@interface STGTInterest : STDatum

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) STGTInterestImage *image;
@property (nonatomic, retain) NSSet *spots;
@end

@interface STGTInterest (CoreDataGeneratedAccessors)

- (void)addSpotsObject:(STGTSpot *)value;
- (void)removeSpotsObject:(STGTSpot *)value;
- (void)addSpots:(NSSet *)values;
- (void)removeSpots:(NSSet *)values;

@end

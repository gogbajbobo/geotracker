//
//  STGTNetwork.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/29/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STGTNetworkImage, STGTSpot;

@interface STGTNetwork : STDatum

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) STGTNetworkImage *image;
@property (nonatomic, retain) NSSet *spots;
@end

@interface STGTNetwork (CoreDataGeneratedAccessors)

- (void)addSpotsObject:(STGTSpot *)value;
- (void)removeSpotsObject:(STGTSpot *)value;
- (void)addSpots:(NSSet *)values;
- (void)removeSpots:(NSSet *)values;

@end

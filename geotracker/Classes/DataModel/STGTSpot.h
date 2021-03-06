//
//  STGTSpot.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/29/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STGTInterest, STGTNetwork, STGTSpotImage;

@interface STGTSpot : STDatum

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * avatarXid;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *interests;
@property (nonatomic, retain) NSSet *networks;
@end

@interface STGTSpot (CoreDataGeneratedAccessors)

- (void)addImagesObject:(STGTSpotImage *)value;
- (void)removeImagesObject:(STGTSpotImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addInterestsObject:(STGTInterest *)value;
- (void)removeInterestsObject:(STGTInterest *)value;
- (void)addInterests:(NSSet *)values;
- (void)removeInterests:(NSSet *)values;

- (void)addNetworksObject:(STGTNetwork *)value;
- (void)removeNetworksObject:(STGTNetwork *)value;
- (void)addNetworks:(NSSet *)values;
- (void)removeNetworks:(NSSet *)values;

@end

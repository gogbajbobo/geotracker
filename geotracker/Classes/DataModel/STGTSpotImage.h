//
//  STGTSpotImage.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/24/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STGTImage.h"

@class STGTSpot;

@interface STGTSpotImage : STGTImage

@property (nonatomic, retain) STGTSpot *spot;

@end

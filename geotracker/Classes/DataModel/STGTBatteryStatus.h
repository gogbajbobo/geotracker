//
//  STGTBatteryStatus.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/24/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STGTDatum.h"


@interface STGTBatteryStatus : STGTDatum

@property (nonatomic, retain) NSNumber * batteryLevel;
@property (nonatomic, retain) NSString * batteryState;

@end

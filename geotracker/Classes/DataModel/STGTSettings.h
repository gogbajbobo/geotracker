//
//  STGTSettings.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/13/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STGTDatum.h"


@interface STGTSettings : STGTDatum

@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * value;

@end

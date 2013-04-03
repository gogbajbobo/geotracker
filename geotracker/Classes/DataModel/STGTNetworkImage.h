//
//  STGTNetworkImage.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/2/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STGTImage.h"

@class STGTNetwork;

@interface STGTNetworkImage : STGTImage

@property (nonatomic, retain) STGTNetwork *network;

@end

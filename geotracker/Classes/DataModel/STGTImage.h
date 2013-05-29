//
//  STGTImage.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/29/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"


@interface STGTImage : STDatum

@property (nonatomic, retain) NSData * imageData;

@end

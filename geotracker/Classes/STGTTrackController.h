//
//  STGTTrackController.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/5/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "STManagedDocument.h"

@interface STGTTrackController : NSObject

@property (strong, nonatomic) STManagedDocument *document;
@property (strong, nonatomic) NSDictionary *currentTrackInfo;
@property (strong, nonatomic) NSDictionary *summaryInfo;

@end

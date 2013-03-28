//
//  STGTTracker.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "STGTSessionManagement.h"
#import "STGTManagedDocument.h"

@interface STGTTracker : NSObject

@property (strong, nonatomic) STGTManagedDocument *document;
@property (nonatomic, strong) id <STGTSession> session;

- (void)startTracking;
- (void)stopTracking;


@end

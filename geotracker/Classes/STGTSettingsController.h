//
//  STGTSettingsController.h
//  geotracking
//
//  Created by Maxim Grigoriev on 1/24/13.
//  Copyright (c) 2013 Maxim V. Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "STGTSessionManagement.h"

@interface STGTSettingsController : NSObject

+ (NSDictionary *)defaultSettings;

- (void)updateSettingsWith:(NSDictionary *)newSettings;

@property (nonatomic, strong) id <STGTSession> session;
@property (nonatomic, strong) NSArray *currentSettings;

@end

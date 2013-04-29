//
//  STGTMapController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTMapController.h"
#import "STGTSettingsController.h"
#import <MapKit/MapKit.h>
#import <YandexMapKit/YandexMapKit.h>

@implementation STGTMapController

//- (id)init {
//    self = [super init];
//    if (self) {
//        [self customInit];
//    }
//    return self;
//}
//
//- (void)customInit {
//
//}

- (void)setCurrentSession:(STSession *)currentSession {
    
    _currentSession = currentSession;
    
    self.mapVC = [[UIViewController alloc] init];

    NSString *mapProvider = [[_currentSession.settingsController currentSettingsForGroup:@"map"] valueForKey:@"mapProvider"];
    if ([mapProvider isEqualToString:[NSString stringWithFormat:@"%d", mapYandex]]) {
        self.mapVC.view = [[YMKMapView alloc] init];
    } else if ([mapProvider isEqualToString:[NSString stringWithFormat:@"%d", mapApple]]) {
        self.mapVC.view = [[MKMapView alloc] init];
    } else {
    }

}

@end

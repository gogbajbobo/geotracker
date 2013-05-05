//
//  YMKMapView+custom.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <YandexMapKit/YandexMapKit.h>
#import "Protocols/STMapViewControllable.h"

@interface YMKMapView (custom) <STMapViewControllable>

- (void)showsUserLocation:(BOOL)showsUserLocation;
- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;

@end

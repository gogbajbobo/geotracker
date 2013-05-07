//
//  MKMapView+custom.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Protocols/STMapViewControllable.h"

@interface MKMapView (custom) <STMapViewControllable, MKMapViewDelegate>

- (void)showsUserLocation:(BOOL)showsUserLocation;
- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count title:(NSString *)title;

@end

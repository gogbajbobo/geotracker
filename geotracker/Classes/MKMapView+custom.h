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

- (CLLocationCoordinate2D) currentUserLocation;
- (void)showsUserLocation:(BOOL)showsUserLocation;
- (void)scaleMapToRegion:(MKCoordinateRegion)region;

- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count title:(NSString *)title;
- (void)removePathWithTitle:(NSString *)pathTitle;


@end

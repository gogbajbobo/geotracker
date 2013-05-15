//
//  YMKMapView+custom.m
//  geotracker
//
//  Created by Maxim Grigoriev on 5/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "YMKMapView+custom.h"

@implementation YMKMapView (custom)

- (void)showsUserLocation:(BOOL)showsUserLocation {
    self.showsUserLocation = showsUserLocation;
}

- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count title:(NSString *)title {
    
}

- (CLLocationCoordinate2D) currentUserLocation {
    return self.userLocation.location.coordinate;
}

- (void)scaleMapToRegion:(MKCoordinateRegion)region {
    
}

@end

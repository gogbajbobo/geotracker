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

- (CLLocationCoordinate2D) currentUserLocation {
    return self.userLocation.location.coordinate;
}

- (void)scaleMapToRegion:(MKCoordinateRegion)region {
    
    YMKMapRegionSize span = {region.span.latitudeDelta, region.span.longitudeDelta};
    YMKMapRegion YRegion = YMKMapRegionMake(region.center, span);
    
    [self setRegion:YRegion animated:YES];
}

- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count title:(NSString *)title {
    
}

- (void)removePathWithTitle:(NSString *)pathTitle {
    
}

@end

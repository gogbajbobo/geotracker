//
//  STMapViewControllable.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol STMapViewControllable <NSObject>

- (CLLocationCoordinate2D) currentUserLocation;
- (void)showsUserLocation:(BOOL)showsUserLocation;
- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count title:(NSString *)title;
- (void)scaleMapToRegion:(MKCoordinateRegion)region;

@end

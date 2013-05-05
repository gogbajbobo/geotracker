//
//  STMapViewControllable.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STMapViewControllable <NSObject>

- (void)showsUserLocation:(BOOL)showsUserLocation;

- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;

@end

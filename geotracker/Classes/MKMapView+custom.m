//
//  MKMapView+custom.m
//  geotracker
//
//  Created by Maxim Grigoriev on 5/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "MKMapView+custom.h"

@implementation MKMapView (custom)

- (id)init {
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)showsUserLocation:(BOOL)showsUserLocation {
    self.showsUserLocation = showsUserLocation;
}

- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count {

    MKPolyline *pathLine = [MKPolyline polylineWithCoordinates:coordinates count:count];
    pathLine.title = @"allTracks";
    [self addOverlay:(id<MKOverlay>)pathLine];

}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineView *pathView = [[MKPolylineView alloc] initWithPolyline:overlay];
    if ([overlay.title isEqualToString:@"currentTrack"]) {
        pathView.strokeColor = [UIColor blueColor];
        pathView.lineWidth = 4.0;
    } else if ([overlay.title isEqualToString:@"allTracks"]) {
        pathView.strokeColor = [UIColor grayColor];
        pathView.lineWidth = 2.0;
    } else if ([overlay.title isEqualToString:@"route"]) {
        pathView.strokeColor = [UIColor greenColor];
        pathView.lineWidth = 6.0;
    }
    return pathView;
    
}

@end

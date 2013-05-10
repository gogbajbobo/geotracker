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

- (CLLocationCoordinate2D) currentUserLocation {
    return self.userLocation.location.coordinate;
}

- (void)showsUserLocation:(BOOL)showsUserLocation {
    self.showsUserLocation = showsUserLocation;
}

- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count title:(NSString *)title {

    MKPolyline *pathLine = [MKPolyline polylineWithCoordinates:coordinates count:count];
    pathLine.title = title;
    if ([title isEqualToString:@"track"]) {
        [self insertOverlay:(id<MKOverlay>)pathLine atIndex:self.overlays.count];
        
    } else if ([title isEqualToString:@"selectedTrack"]) {
        MKPolyline *startLine = [self startLineForSegmentFrom:coordinates[0] to:coordinates[1]];
        [self insertOverlay:(id<MKOverlay>)pathLine atIndex:self.overlays.count];
        [self insertOverlay:(id<MKOverlay>)startLine atIndex:self.overlays.count];
        
    } else if ([title isEqualToString:@"allTracks"]) {
        [self insertOverlay:(id<MKOverlay>)pathLine atIndex:0];
    }

}

- (MKPolyline *)startLineForSegmentFrom:(CLLocationCoordinate2D)firstPoint to:(CLLocationCoordinate2D)secondPoint {
    
    double d = 0.001;
    double k = (secondPoint.latitude - firstPoint.latitude) / (secondPoint.longitude - firstPoint.longitude);
    double x = d / (2 * sqrt(pow(k,2) + 1));
    double y = k * x;
    
    NSLog(@"d %f, k %f, x %f, y %f", d, k, x, y);
    
    CLLocationCoordinate2D coordinates[2];
    coordinates[0] = CLLocationCoordinate2DMake(firstPoint.latitude - x, firstPoint.longitude - y);
    coordinates[1] = CLLocationCoordinate2DMake(firstPoint.latitude + x, firstPoint.longitude + y);
    
    MKPolyline *startLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
    startLine.title = @"startLine";
    
    return startLine;

}

- (void)scaleMapToRegion:(MKCoordinateRegion)region {
    [self setRegion:region animated:YES];
}


#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineView *pathView = [[MKPolylineView alloc] initWithPolyline:overlay];
    if ([overlay.title isEqualToString:@"track"]) {
        pathView.strokeColor = [UIColor yellowColor];
        pathView.lineWidth = 4.0;
    } else if ([overlay.title isEqualToString:@"selectedTrack"]) {
        pathView.strokeColor = [UIColor blueColor];
        pathView.lineWidth = 4.0;
    } else if ([overlay.title isEqualToString:@"startLine"]) {
        pathView.strokeColor = [UIColor redColor];
        pathView.lineWidth = 8.0;
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

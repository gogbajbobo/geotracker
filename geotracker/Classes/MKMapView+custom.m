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

- (void)removePathWithTitle:(NSString *)pathTitle {

    [self removeOverlayWithTitle:pathTitle];
    
    if ([pathTitle isEqualToString:@"selectedTrack"]) {
        
        [self removeOverlayWithTitle:@"startLine"];
        [self removeOverlayWithTitle:@"finishPoint"];

    }
}

- (void)removeOverlayWithTitle:(NSString *)title {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title == %@", title];
    id <MKOverlay> overlayToRemove = (id <MKOverlay>)[[self.overlays filteredArrayUsingPredicate:predicate] lastObject];
    [self removeOverlay:overlayToRemove];

}

- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count title:(NSString *)title {

    MKPolyline *pathLine = [MKPolyline polylineWithCoordinates:coordinates count:count];
    pathLine.title = title;
    if ([title isEqualToString:@"track"]) {
        [self insertOverlay:(id <MKOverlay>)pathLine atIndex:self.overlays.count];
        
    } else if ([title isEqualToString:@"selectedTrack"]) {
        [self insertOverlay:(id <MKOverlay>)pathLine atIndex:self.overlays.count];

        MKPolyline *startLine = [self startLineForSegmentFrom:coordinates[0] to:coordinates[1]];
        [self insertOverlay:(id <MKOverlay>)startLine atIndex:self.overlays.count];

        MKCircle *finishPoint = [self finishPointFor:coordinates[count-1]];
        [self insertOverlay:(id <MKOverlay>)finishPoint atIndex:self.overlays.count];
        
    } else if ([title isEqualToString:@"allTracks"]) {
        [self insertOverlay:(id <MKOverlay>)pathLine atIndex:0];
    }

}

- (MKPolyline *)startLineForSegmentFrom:(CLLocationCoordinate2D)firstPoint to:(CLLocationCoordinate2D)secondPoint {
    
    MKMapPoint fpoint = MKMapPointForCoordinate(firstPoint);
    MKMapPoint spoint = MKMapPointForCoordinate(secondPoint);
    
    MKMapSize size = self.visibleMapRect.size;
    double minSize = size.height < size.width ? size.height : size.width;
        
    double d = minSize / 20;
    double k = (spoint.x - fpoint.x) / (spoint.y - fpoint.y);
    double x = d / (2 * sqrt(pow(k,2) + 1));
    double y = k * x;
    
    CLLocationCoordinate2D coordinates[2];
    
    MKMapPoint points[2];
    points[0] = MKMapPointMake(fpoint.x - x, fpoint.y + y);
    points[1] = MKMapPointMake(fpoint.x + x, fpoint.y - y);
    
    coordinates[0] = CLLocationCoordinate2DMake(firstPoint.latitude - x, firstPoint.longitude - y);
    coordinates[1] = CLLocationCoordinate2DMake(firstPoint.latitude + x, firstPoint.longitude + y);
    
    MKPolyline *startLine = [MKPolyline polylineWithPoints:points count:2];
    startLine.title = @"startLine";
    
    return startLine;

}

- (MKCircle *)finishPointFor:(CLLocationCoordinate2D)coordinate {

    MKMapSize size = self.visibleMapRect.size;
    double minSize = size.height < size.width ? size.height : size.width;
    
    MKMapPoint fp = {0, 0};
    MKMapPoint sp = {0, minSize};
    CLLocationDistance radius = MKMetersBetweenMapPoints(fp, sp) / 8;
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:radius];
    circle.title = @"finishPoint";
    
    return circle;
    
}


- (void)scaleMapToRegion:(MKCoordinateRegion)region {
    [self setRegion:region animated:YES];
}


#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    MKOverlayView *overlayView;
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *pathView = [[MKPolylineView alloc] initWithPolyline:overlay];
        if ([overlay.title isEqualToString:@"track"]) {
            pathView.strokeColor = [UIColor yellowColor];
            pathView.lineWidth = 4.0;
        } else if ([overlay.title isEqualToString:@"selectedTrack"]) {
            pathView.strokeColor = [UIColor blueColor];
            pathView.lineWidth = 4.0;
        } else if ([overlay.title isEqualToString:@"startLine"]) {
            pathView.strokeColor = [UIColor blueColor];
            pathView.lineWidth = 8.0;
        } else if ([overlay.title isEqualToString:@"allTracks"]) {
            pathView.strokeColor = [UIColor grayColor];
            pathView.lineWidth = 2.0;
        } else if ([overlay.title isEqualToString:@"route"]) {
            pathView.strokeColor = [UIColor greenColor];
            pathView.lineWidth = 6.0;
        }
        overlayView = pathView;
        
    } else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        if ([overlay.title isEqualToString:@"finishPoint"]) {
            circleView.strokeColor = [UIColor blueColor];
            circleView.fillColor = [UIColor blueColor];
            circleView.lineWidth = 8.0;
        }
        overlayView = circleView;
        
    }
    
    return overlayView;
    
}

@end

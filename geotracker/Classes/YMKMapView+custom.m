//
//  YMKMapView+custom.m
//  geotracker
//
//  Created by Maxim Grigoriev on 5/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "YMKMapView+custom.h"
#import "YandexMapKitRoute.h"
#import "STYMKRouteView.h"

@interface YMKMapView()

@property (nonatomic, strong) STYMKRouteView *routeView;

@end


@implementation YMKMapView (custom)

//@dynamic routeView;

- (STYMKRouteView *)routeView {
    
//    NSLog(@"self.frame %f %f %f %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.height, self.frame.size.width);
    return [[STYMKRouteView alloc] initWithFrame:self.frame];

}

- (void)setRouteView:(STYMKRouteView *)routeView {
    
}

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
    
//    self.routeView = [[STYMKRouteView alloc] initWithFrame:self.frame];
    
//    NSLog(@"self.subviews %@", self.subviews);
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            
//            self.routeView.YXScrollView = (UIScrollView <UIScrollViewDelegate> *)subview;
//
//            [self.routeView.YXScrollView insertSubview:self.routeView atIndex:1];
            
//            [subview insertSubview:self.routeView atIndex:0];
            [subview insertSubview:self.routeView aboveSubview:[subview.subviews objectAtIndex:subview.subviews.count-1]];
            
            NSLog(@"UIScrollView %@", subview);
            NSLog(@"self.routeView.YXScrollView %@", self.routeView.YXScrollView);
            NSLog(@"self.routeView.subviews %@", self.routeView.subviews);
            
            
//            [subview insertSubview:self.routeView atIndex:0];
//
//            [subview addSubview:self.routeView];

            CGRect frame = self.routeView.frame;
            frame.origin = [(UIScrollView *)subview contentOffset];
            self.routeView.frame=frame;

            [self.routeView setNeedsDisplay];
//            [subview setNeedsDisplay];
            NSLog(@"subview %@", subview.subviews);

        }
    }
    
}

- (void)drawPathWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count title:(NSString *)title {
    
//    [YandexMapKitRoute showRouteOnMap:self From:coordinates[0] To:coordinates[(int)rint(count/2)]];
}

- (void)removePathWithTitle:(NSString *)pathTitle {
    
}

@end

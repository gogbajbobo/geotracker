//
//  STYMKRouteView.m
//  geotracker
//
//  Created by Maxim Grigoriev on 6/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STYMKRouteView.h"

@implementation STYMKRouteView

@synthesize YXScrollView = _YXScrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:NO];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    NSLog(@"drawRect");
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, 0);
    CGContextScaleCTM(context, 1.0, -1.0);
    //Width of route line
    CGContextSetLineWidth(context, 5.0);
    //Color of route line
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor);
    
    //Move to first position of route
    CGContextMoveToPoint(context, 20, -20);
    CGContextAddLineToPoint(context, 100, -100);
    CGContextAddLineToPoint(context, -100, -100);
    CGContextAddLineToPoint(context, -100, 100);
    CGContextAddLineToPoint(context, 100, 100);
    
    CGContextStrokePath(context);
}


@end

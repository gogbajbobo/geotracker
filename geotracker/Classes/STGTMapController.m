//
//  STGTMapController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTMapController.h"

@implementation STGTMapController

- (id)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    self.mapVC = [[UIViewController alloc] init];
}

@end

//
//  STGTRoundedCornerView.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTRoundedCornerView.h"

@implementation STGTRoundedCornerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self customInit];
    }
    NSLog(@"self %@", self);
    return self;
}

- (void)customInit {

}

- (void)customDraw {
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self customDraw];
}

@end

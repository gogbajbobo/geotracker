//
//  STGTMapViewController.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/2/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSession.h"
#import "STGTTrack.h"

@interface STGTMapViewController : UIViewController

@property (nonatomic, strong) STSession *currentSession;
@property (nonatomic, strong) STGTTrack *selectedTrack;

@end

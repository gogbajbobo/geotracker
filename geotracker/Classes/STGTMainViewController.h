//
//  STGTMainViewController.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STGTTrackController.h"
#import "STSession.h"

@interface STGTMainViewController : UIViewController

@property (nonatomic, strong) STGTTrackController *trackController;
@property (nonatomic, strong) STSession *currentSession;

@end

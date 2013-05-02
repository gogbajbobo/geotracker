//
//  STGTMapViewController.h
//  geotracker
//
//  Created by Maxim Grigoriev on 5/2/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSession.h"

@interface STGTMapViewController : UIViewController

@property (nonatomic, strong) STSession *currentSession;

@end

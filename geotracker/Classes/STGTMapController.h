//
//  STGTMapController.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSession.h"

@interface STGTMapController : NSObject

@property (nonatomic, strong) UIViewController *mapVC;
@property (nonatomic, strong) STSession *currentSession;

@end

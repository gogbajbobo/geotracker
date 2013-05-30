//
//  STHTCheckTVC.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/16/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STGTTrack.h"
#import <STManagedTracker/STSessionManager.h>

@interface STGTCheckTVC : UITableViewController

@property (nonatomic, strong) STGTTrack *track;
@property (nonatomic, strong) STSession *session;

@end

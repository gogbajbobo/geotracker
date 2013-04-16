//
//  STGTSettingsTableViewController.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/13/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSessionManagement.h"

@interface STGTSettingsTableViewController : UITableViewController

@property (nonatomic, strong) id <STSession> session;

@end


@interface STGTSettingsTableViewCell : UITableViewCell

@property (nonatomic, strong) UISlider *slider;

@end
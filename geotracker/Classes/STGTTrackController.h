//
//  STGTTrackController.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/5/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "STGTTrack.h"
#import "STSession.h"

@interface STGTTrackController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary *currentTrackInfo;
@property (strong, nonatomic) NSDictionary *summaryInfo;
@property (strong, nonatomic) NSDictionary *todaySummaryInfo;
@property (nonatomic, strong) STSession *currentSession;
@property (nonatomic, strong) UITableView *tableView;

- (NSDictionary *)infoForTrack:(STGTTrack *)track;
- (STGTTrack *)currentTrack;

@end

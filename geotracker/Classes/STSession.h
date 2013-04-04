//
//  STGTSession.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSessionManagement.h"
#import "STSessionManager.h"
#import "STManagedDocument.h"
#import "STSyncer.h"
#import "STGTLocationTracker.h"
#import "STGTBatteryTracker.h"
#import "STGTSettings.h"
#import "STGTSettingsController.h"

@interface STSession : NSObject <STSession>

@property (strong, nonatomic) STManagedDocument *document;
@property (strong, nonatomic) STSyncer *syncer;
@property (strong, nonatomic) STGTLocationTracker *locationTracker;
@property (strong, nonatomic) STGTBatteryTracker *batteryTracker;
@property (weak, nonatomic) id <STSessionManager> manager;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *status;
@property (nonatomic, strong) id <STRequestAuthenticatable> authDelegate;
@property (nonatomic, strong) STGTSettingsController *settingsController;

+ (STSession *)initWithUID:(NSString *)uid authDelegate:(id <STRequestAuthenticatable>)authDelegate;
+ (STSession *)initWithUID:(NSString *)uid authDelegate:(id <STRequestAuthenticatable>)authDelegate settings:(NSDictionary *)settings;
- (void)completeSession;
- (void)dismissSession;
- (void)settingsLoadComplete;

@end

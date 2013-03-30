//
//  STGTSession.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STGTSessionManagement.h"
#import "STGTSessionManager.h"
#import "STGTManagedDocument.h"
#import "STGTSyncer.h"
#import "STGTTracker.h"
#import "STGTSettings.h"
#import "STGTSettingsController.h"

@interface STGTSession : NSObject <STGTSession>

@property (strong, nonatomic) STGTManagedDocument *document;
@property (strong, nonatomic) STGTSyncer *syncer;
@property (strong, nonatomic) STGTTracker *tracker;
@property (weak, nonatomic) id <STGTSessionManager> manager;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *status;
@property (nonatomic, strong) id <STGTRequestAuthenticatable> authDelegate;
@property (nonatomic, strong) STGTSettingsController *settingsController;

+ (STGTSession *)initWithUID:(NSString *)uid authDelegate:(id <STGTRequestAuthenticatable>)authDelegate;
+ (STGTSession *)initWithUID:(NSString *)uid authDelegate:(id <STGTRequestAuthenticatable>)authDelegate settings:(NSDictionary *)settings;
- (void)completeSession;


@end

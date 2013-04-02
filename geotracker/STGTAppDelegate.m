//
//  STGTAppDelegate.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTAppDelegate.h"
#import "STGTSessionManager.h"

@implementation STGTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[STGTSessionManager sharedManager] startSessionForUID:@"1" authDelegate:nil settings:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", YES], @"trackerAutoStart", @"10.0", @"trackerStartTime", @"16.9", @"trackerFinishTime", nil]];

//    [[STGTSessionManager sharedManager] startSessionForUID:@"2" authDelegate:nil settings:[NSDictionary dictionaryWithObjectsAndKeys:@"10", @"requiredAccuracy", nil]];
//    [[STGTSessionManager sharedManager] stopSessionForUID:@"2"];
//    [[STGTSessionManager sharedManager] cleanCompletedSessions];
    
//    NSLog(@"state1 %d", UIDocumentStateNormal);
//    NSLog(@"state2 %d", UIDocumentStateClosed);
//    NSLog(@"state3 %d", UIDocumentStateInConflict);
//    NSLog(@"state4 %d", UIDocumentStateSavingError);
//    NSLog(@"state5 %d", UIDocumentStateEditingDisabled);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

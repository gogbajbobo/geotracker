//
//  STGTAppDelegate.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTAppDelegate.h"
#import <STManagedTracker/STSessionManager.h>
#import "STGTAuthBasic.h"
#import <UDPushAuth/UDAuthTokenRetriever.h>
#import "STGTLocationTracker.h"
#import "STGTSettingsController.h"

@implementation STGTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[STGTAuthBasic sharedOAuth] checkToken];
    
    self.pushNotificatonCenter = [UDPushNotificationCenter sharedPushNotificationCenter];
    self.authCodeRetriever = (UDPushAuthCodeRetriever *)[(UDAuthTokenRetriever *)[[STGTAuthBasic sharedOAuth] tokenRetriever] codeDelegate];
    self.reachability = [Reachability reachabilityWithHostname:[[STGTAuthBasic sharedOAuth] reachabilityServer]];
    self.reachability.reachableOnWWAN = YES;
    [self.reachability startNotifier];

    

    NSDictionary *sessionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"1", @"batteryTrackerAutoStart",
                                     @"8.0", @"batteryTrackerStartTime",
                                     @"20.0", @"batteryTrackerFinishTime",
                                     @"0", @"locationTrackerAutoStart",
                                     @"8.0", @"locationTrackerStartTime",
                                     @"20.0", @"locationTrackerFinishTime",
                                     @"10", @"desiredAccuracy",
                                     @"10", @"requiredAccuracy",
                                     @"20", @"distanceFilter",
                                     @"20", @"timeFilter",
                                     @"180", @"trackDetectionTime",
                                     @"1", @"localAccessToSettings",
                                     @"200", @"fetchLimit",
                                     @"https://system.unact.ru/utils/chest2json.php", @"syncServerURI",
                                     @"STGTDataModel", @"dataModelName",
                                     nil];
    
    NSDictionary *trackers = [NSDictionary dictionaryWithObjectsAndKeys:
                              [[STGTLocationTracker alloc] init], @"locationTracker",
                              [[STGTSettingsController alloc] init], @"settingsController",
                              nil];
    
    [[STSessionManager sharedManager] startSessionForUID:@"1" authDelegate:[STGTAuthBasic sharedOAuth] trackers:trackers settings:sessionSettings];

    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
#if DEBUG
    NSLog(@"Device token: %@", deviceToken);
#endif
    [self.authCodeRetriever registerDeviceWithPushToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
#if DEBUG
    NSLog(@"Failed to get token, error: %@", error);
#endif
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self.pushNotificatonCenter processPushNotification:userInfo];
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

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[STSessionManager sharedManager] cleanCompletedSessions];
}

@end

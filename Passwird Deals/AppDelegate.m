//
//  AppDelegate.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "Constants.h"
#import "Appirater.h"
#import "ASIFormDataRequest.h"
#import "Flurry.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        [application setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    
    // Performance caching settings 
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];

    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
//    not currently using this, but could in the future
//    if (launchOptions != nil) {
//		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//		if (dictionary != nil) {
//			NSLog(@"Launched from push notification: %@", dictionary);
//		}
//    }
    
    // Settings defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO],  @"showExpiredDeals",
                                     @"",  @"deviceToken",
                                     nil];
    [defaults registerDefaults:defaultSettings];
    
    [Flurry startSession:@"DJTGVD43HJ7XV96WYCQD"];
    
    [Appirater setAppId:PASSWIRD_APP_ID];
    [Appirater setDaysUntilPrompt:15];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater appLaunched:YES];
//    [Appirater setDebug:YES];
    
    defaults = nil;
    defaultSettings = nil;
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
	NSLog(@"My token is: %@", deviceToken);
    
	NSString *formattedToken = [deviceToken description];
	formattedToken = [formattedToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	formattedToken = [formattedToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types == UIRemoteNotificationTypeNone) {
        [AppDelegate postUnregisterDeviceToken:formattedToken];
        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"deviceToken"];
    } else {
        [AppDelegate postRegisterDeviceToken:formattedToken];
        [[NSUserDefaults standardUserDefaults] setObject:formattedToken forKey:@"deviceToken"];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
	NSLog(@"Received notification: %@", userInfo);
    
    if (application.applicationState == UIApplicationStateActive) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Deal Alert"
                                                            message:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedPushNotification" object:nil userInfo:userInfo];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [AppDelegate postResetBadgeCount];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    //clear UIWebView cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

+ (void)postResetBadgeCount {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
    if ((deviceToken != nil) && (![deviceToken isEqual: @""])) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ResetBadgeCount", PASSWIRD_API_URL]];
        
        NSLog(@"token to reset: '%@'", deviceToken);
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:deviceToken forKey:@"token"];
        [request setDelegate:self];
        [request startAsynchronous];
        
        deviceToken = nil;
    }
}

+ (void)postRegisterDeviceToken:(NSString *)formattedToken {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/RegisterDeviceToken", PASSWIRD_API_URL]];
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:@"PasswirdDeals" forKey:@"app"];
	[request setPostValue:formattedToken forKey:@"token"];
	[request setDelegate:self];
    
	[request startAsynchronous];
}

+ (void)postUnregisterDeviceToken:(NSString *)formattedToken {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/UnregisterDeviceToken", PASSWIRD_API_URL]];
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:@"PasswirdDeals" forKey:@"app"];
	[request setPostValue:formattedToken forKey:@"token"];
	[request setDelegate:self];
    
	[request startAsynchronous];
}

@end
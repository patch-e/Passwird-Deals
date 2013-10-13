//
//  AppDelegate.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "Extensions.h"
#import "Constants.h"
#import "Appirater.h"
#import "AFNetworking.h"
#import "Flurry.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //override point for customization after application launch.
    [self customizeAppearance];
    
    //iPad controller settings
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        self.navigationController = navigationController;
    } else {
        self.navigationController = (UINavigationController *)self.window.rootViewController;
    }
    
    //performance caching settings 
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];

    //let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //handle notification tap while app isn't running
    if (launchOptions != nil) {
		NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (userInfo != nil) {
			NSLog(@"Launched from push notification: %@", userInfo);
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                //set the detailId from the received push, connect and download the deal
                DetailViewController *detailViewController = (DetailViewController *)self.navigationController.topViewController;
                [detailViewController setDetailId:[(NSNumber*)[userInfo objectForKey:@"id"] intValue]];
            } else {
                //construct a detail view controller, set the detailId from the received push, and push the controller on the stack
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                
                DetailViewController* detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"Detail"];
                [detailViewController setDetailId:[(NSNumber*)[userInfo objectForKey:@"id"] intValue]];
                
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
		}
    }
    
    //settings defaults
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

+ (AppDelegate*)delegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
	NSLog(@"My token is: %@", deviceToken);
    
	NSString *formattedToken = [deviceToken description];
	formattedToken = [formattedToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	formattedToken = [formattedToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types == UIRemoteNotificationTypeNone) {
        [AppDelegate postUnregisterDeviceToken:formattedToken];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"deviceToken"];
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
        //if app is active on screen, just show alert view of deal headline
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Deal Alert"
                                                            message:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    } else {
        //if app is running, but in the background fire this notification (handled in master and search) to display the deal from the push
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedPushNotification" object:nil userInfo:userInfo];
    }
}

#pragma mark - Notification post operations

+ (void)postOperationWithPath:(NSString*)postPath parameters:(NSDictionary*)params {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:PASSWIRD_API_URL]];
    
    [httpClient postPath:postPath
              parameters:params
                 success:^(AFHTTPRequestOperation *loginOperation, id responseObject) {
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     
                     //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                     //NSLog(@"Request Successful, response '%@'", responseStr);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                 }];
}

+ (void)postResetBadgeCount {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
    if ((deviceToken != nil) && (![deviceToken isEqual: @""])) {        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                deviceToken, @"token",
                                nil];
        [AppDelegate postOperationWithPath:@"/ResetBadgeCount" parameters:params];
    }
}

+ (void)postRegisterDeviceToken:(NSString *)formattedToken {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"PasswirdDeals", @"app",
                            formattedToken, @"token",
                            nil];
    [AppDelegate postOperationWithPath:@"/RegisterDeviceToken" parameters:params];
}

+ (void)postUnregisterDeviceToken:(NSString *)formattedToken {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"PasswirdDeals", @"app",
                            formattedToken, @"token",
                            nil];
    [AppDelegate postOperationWithPath:@"/UnregisterDeviceToken" parameters:params];
}

#pragma mark - Customizations

- (void)customizeAppearance {
    // status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //custom appearance settings for UIKit items
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor pdDarkGrayColor]];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor pdLightGrayColor]];
//    [[UINavigationBar appearanceWhenContainedIn:[SKStoreProductViewController class], nil] setTintColor:[UIColor pdDarkGrayColor]];
    
//    [[UIToolbar appearance] setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setTintColor:[UIColor pdDarkGrayColor]];
    [[UIToolbar appearance] setBackgroundColor:[UIColor pdLightGrayColor]];
    
//    [[UISearchBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UISearchBar appearance] setTintColor:[UIColor pdDarkGrayColor]];
    [[UISearchBar appearance] setBackgroundColor:[UIColor pdLightGrayColor]];
    
//    [[UIActionSheet appearance] setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
}

@end
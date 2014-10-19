//
//  AppDelegate.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "Appirater.h"
#import "AFNetworking.h"
#import <Crashlytics/Crashlytics.h>

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
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    #else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    #endif
    
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
    
    [Appirater setAppId:PASSWIRD_APP_ID];
    [Appirater setDaysUntilPrompt:15];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater appLaunched:YES];
//    [Appirater setDebug:YES];
    
    [Crashlytics startWithAPIKey:@"7e5579f671abccb0156cc1a6de1201f981ef170c"];
    
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
    
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", PASSWIRD_API_URL, postPath];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:postUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //custom appearance settings for UIKit items
    [[UINavigationBar appearance] setTintColor:[UIColor pdHeaderTintColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor pdHeaderBarTintColor]];

    [[UIToolbar appearance] setTintColor:[UIColor pdHeaderTintColor]];
    [[UIToolbar appearance] setBarTintColor:[UIColor pdHeaderBarTintColor]];
    
    [[UISearchBar appearance] setTintColor:[UIColor pdHeaderTintColor]];
    [[UISearchBar appearance] setBarTintColor:[UIColor pdTitleTextColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor pdHeaderTintColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    self.window.backgroundColor = [UIColor pdTitleTextColor];
}

@end
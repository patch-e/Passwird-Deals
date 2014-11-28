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
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
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
                
                DetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"Detail"];
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
    
    if ([application respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *types = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (types == UIUserNotificationTypeNone) {
            [AppDelegate postUnregisterDeviceToken:formattedToken];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"deviceToken"];
        } else {
            [AppDelegate postRegisterDeviceToken:formattedToken];
            [[NSUserDefaults standardUserDefaults] setObject:formattedToken forKey:@"deviceToken"];
        }
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types == UIRemoteNotificationTypeNone) {
            [AppDelegate postUnregisterDeviceToken:formattedToken];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"deviceToken"];
        } else {
            [AppDelegate postRegisterDeviceToken:formattedToken];
            [[NSUserDefaults standardUserDefaults] setObject:formattedToken forKey:@"deviceToken"];
        }
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

+ (BOOL)setApplicationIconBadgeNumber:(NSInteger)badgeNumber {
    BOOL badgePermission = YES;
    
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application respondsToSelector:@selector(currentUserNotificationSettings)]) {
        if ([AppDelegate checkNotificationType:UIUserNotificationTypeBadge]) {
            NSLog(@"badge number changed to %ld", (long)badgeNumber);
            [application setApplicationIconBadgeNumber:badgeNumber];
        } else {
            NSLog(@"access denied for UIUserNotificationTypeBadge");
            badgePermission = NO;
        }
    } else {
        [application setApplicationIconBadgeNumber:badgeNumber];
    }
    
    return badgePermission;
}

+ (BOOL)checkNotificationType:(UIUserNotificationType)type {
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    return (currentSettings.types & type);
}

#pragma mark - Notification post operations

+ (void)postOperationWithPath:(NSString*)postPath parameters:(NSDictionary*)params {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", PASSWIRD_API_URL, postPath];
    NSLog(@"POSTing to: %@", postUrl);
    NSLog(@"with params: %@", params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager POST:postUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSLog(@"Request Successful, response '%@'", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

+ (void)postResetBadgeCount {
    BOOL badgePermission = [AppDelegate setApplicationIconBadgeNumber:0];
    
    if (badgePermission) {
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
        if ((deviceToken != nil) && (![deviceToken isEqual: @""])) {        
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    deviceToken, @"token",
                                    nil];
            [AppDelegate postOperationWithPath:@"/ResetBadgeCount" parameters:params];
        }
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
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    [[UIToolbar appearance] setTintColor:[UIColor pdHeaderTintColor]];
    [[UIToolbar appearance] setBarTintColor:[UIColor pdHeaderBarTintColor]];
    
    [[UISearchBar appearance] setTintColor:[UIColor pdHeaderTintColor]];
    [[UISearchBar appearance] setBarTintColor:[UIColor pdTitleTextColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor pdHeaderTintColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    self.window.backgroundColor = [UIColor pdTitleTextColor];
}

@end
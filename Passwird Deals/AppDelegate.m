//
//  AppDelegate.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "AFNetworking.h"

@import Firebase;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //override point for customization after application launch.
    [FIRApp configure];
    
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
    
    defaults = nil;
    defaultSettings = nil;
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [AppDelegate postResetBadgeCount];
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
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Deal Alert"
                                              message:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction cancelActionWithController:self.window.rootViewController]];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
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
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:postUrl parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"Request Successful, response '%@'", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
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

@end

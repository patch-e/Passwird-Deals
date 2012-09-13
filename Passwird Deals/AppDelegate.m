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

#import "Flurry.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize showExpiredDeals = _hideExpiredDeals;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    
    [self loadSettings];

    [Flurry startSession:@"DJTGVD43HJ7XV96WYCQD"];
    
    [Appirater setAppId:@"517165629"];
    [Appirater setDaysUntilPrompt:15];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
//    [Appirater setDebug:YES];
    [Appirater appLaunched:YES];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

-(void)loadSettings 
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.showExpiredDeals = [prefs boolForKey:@"showExpiredDeals"];
    
    NSLog(@"pref-showExpiredDeals: %d", self.showExpiredDeals);
}

@end
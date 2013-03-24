//
//  MasterViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "MasterViewController.h"

#import "AppDelegate.h"

#import "Constants.h"
#import "Extensions.h"
#import "MBProgressHUD.h"
#import "Flurry.h"

@implementation MasterViewController

#pragma mark - Managing the asynchronous data download

- (void)createConnectionWithHUD:(BOOL)showHUD {
    if ( showHUD ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:@"Loading"];
    }
    
    //build the connection for async data downloading, 20 second timeout
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/passwird?e=%d", PASSWIRD_API_URL, [[NSUserDefaults standardUserDefaults] boolForKey:@"showExpiredDeals"]]];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    //on good connection, fill responseData, delegate will fire connection:didReceiveData:
    if ( connection ) {
        [self setResponseData:[[NSMutableData alloc] init]];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"connection failed");
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [super connectionDidFinishLoading:connection];
    
    [self.searchButton setEnabled:YES];
    [AppDelegate postResetBadgeCount];
}

#pragma mark - Managing PullToRefresh

- (void)refresh {
    [Flurry logEvent:FLURRY_REFRESH];
    [self createConnectionWithHUD:NO];
}

#pragma mark - Managing the About modal view

- (void)showAboutModal:(id)sender {
    [self performSegueWithIdentifier: @"About" sender: self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logPageView];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [super createRefreshControls];
    [super createInfoBarButtonItem];
    
    [self createConnectionWithHUD:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPushNotification:)
                                                 name:@"receivedPushNotification"
                                               object:nil];
}

- (void)receivedPushNotification:(NSNotification*)aNotification {
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [self createConnectionWithHUD:YES];
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)viewDidUnload {
    [self setSearchButton:nil];
    [super viewDidUnload];
}

@end
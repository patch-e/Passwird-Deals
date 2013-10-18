//
//  MasterViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "MasterViewController.h"

#import "AppDelegate.h"

#import "MBProgressHUD.h"
#import "Flurry.h"

@implementation MasterViewController

#pragma mark - Managing the asynchronous data download

- (void)createConnectionWithHUD:(BOOL)showHUD {
    if ( showHUD ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
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

    [self.settingsButton setEnabled:YES];
    [self.searchButton setEnabled:YES];

    [AppDelegate postResetBadgeCount];
}

#pragma mark - Managing the refresh control

- (void)refresh {
    [Flurry logEvent:FLURRY_REFRESH];
    [self createConnectionWithHUD:NO];
}

#pragma mark - Managing the About modal view

- (void)showAboutModal:(id)sender {
    [self performSegueWithIdentifier:@"Settings" sender:self];
}

#pragma mark - View lifecycle

- (void)receivedPushNotification:(NSNotification *)aNotification {
    //always clear any modal that may be showing
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            //pop back to root, clear the current detail item, set the detailId from the received push, connect and download the deal
            [self.detailViewController.navigationController popToRootViewControllerAnimated:YES];
            [self.detailViewController setDetailItem:nil];
            [self.detailViewController setDetailId:[(NSNumber*)[aNotification.userInfo objectForKey:@"id"] intValue]];
            [self.detailViewController createConnectionWithHUD:YES];
            
            //deselect the current indexPath
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        } else {
            //construct a detail view controller, set the detailId from the received push, and push the controller on the stack
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            
            DetailViewController* detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"Detail"];
            [detailViewController setDetailId:[(NSNumber*)[aNotification.userInfo objectForKey:@"id"] intValue]];
            
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logPageView];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [super createRefreshControls];
    
    [self createConnectionWithHUD:YES];
    
    //register to handle push notifications when running in background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPushNotification:)
                                                 name:@"receivedPushNotification"
                                               object:nil];
}

- (void)viewDidUnload {
    [self setSettingsButton:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
}

@end
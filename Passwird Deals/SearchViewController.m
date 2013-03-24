//
//  SearchViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 4/17/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "SearchViewController.h"

#import "Constants.h"
#import "Extensions.h"
#import "MBProgressHUD.h"
#import "Flurry.h"

@implementation SearchViewController

#pragma mark - Managing the asynchronous data download

- (void)createConnectionWithHUD:(BOOL)showHUD {
    if ( showHUD ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:@"Searching"];
    }
    
    //build the connection for async data downloading, 20 second timeout
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/passwirdsearch?q=%@&e=%d", PASSWIRD_API_URL, [self.searchBar.text urlEncode], [[NSUserDefaults standardUserDefaults] boolForKey:@"showExpiredDeals"]]];
    
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

#pragma mark - Managing the search bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self.view endEditing:YES];
    
    [self setSections:nil];
    [self.tableView reloadData]; 
    
    [self createConnectionWithHUD:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
    [self.searchBar resignFirstResponder];    
}

#pragma mark - Managing PullToRefresh

- (void)refresh {
    [Flurry logEvent:FLURRY_REFRESH];
    [self createConnectionWithHUD:NO];
    
    [self.searchBar resignFirstResponder];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logPageView];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[self.navigationController.splitViewController.viewControllers lastObject] popViewControllerAnimated:YES];
    }
    
    [self setDetailViewController:(DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController]];
    
    //set the keyboard appearance of the search bar
    for (UIView *searchBarSubview in [self.searchBar subviews]) {
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
            }
            @catch (NSException *e) {
                //ignore exception
            }
        }
    }
    
    [super createRefreshControls];
    
    [self.searchBar becomeFirstResponder];
    [self.searchBar setDelegate:self];
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
}

@end
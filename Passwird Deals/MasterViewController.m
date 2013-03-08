//
//  MasterViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"

#import "DealCell.h"
#import "DealData.h"

#import "Extensions.h"
#import "MBProgressHUD.h"
#import "GTMNSString+HTML.h"
#import "UIImageView+WebCache.h"
#import "Flurry.h"
#import "ASIFormDataRequest.h"
#import "ISRefreshControl.h"

@implementation MasterViewController

#pragma mark - Managing the table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.sections allKeys] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[UIColor colorWithRed:202.0/255.0 green:13.0/255.0 blue:38.0/255.0 alpha:0.90]];
    
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, tableView.bounds.size.width, 20)];
    [labelView setBackgroundColor:[UIColor clearColor]];
    [labelView setFont:[UIFont boldSystemFontOfSize:15]];
    [labelView setTextColor:[UIColor whiteColor]];
    [labelView setShadowColor:[UIColor darkGrayColor]];
    [labelView setShadowOffset:CGSizeMake(0, 1)];
    [labelView setText:[[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section] substringFromIndex:1]];

    [headerView addSubview:labelView];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section]] count];
}

- (DealCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set the deal into the DealCell
    DealCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DealCell"];
    
    DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    [cell.textLabel setText:deal.headline];
    [cell.imageView setImageWithURL:deal.imageURL
                   placeholderImage:[UIImage imageNamed:@"icon.png"]];
    
    if ( !deal.isExpired )
        [cell.detailTextLabel setText:nil];
    else
        [cell.detailTextLabel setText:@"(expired)"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //hide view via alpha, and animate in over 1 sec
        [self.detailViewController.webView setAlpha:0];
        [UIView animateWithDuration:0.8 animations:^() {
            [self.detailViewController.webView setAlpha:1];
        }];
        //enable the share button if it isn't already
        [self.detailViewController.shareButton setEnabled:YES];
        
        DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:self.tableView.indexPathForSelectedRow.section]] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        [self.detailViewController setDetailItem:deal];
    }
}

#pragma mark - Managing the asynchronous data download

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                options:kNilOptions
                                                  error:&error];
    
    NSDictionary *dealsDictionary = result;
    NSArray *dealsArray = [dealsDictionary objectForKey:@"deals"];
    NSMutableArray *deals = [NSMutableArray array];
    [self setSections:[NSMutableDictionary dictionary]];
    
    BOOL sectionExists;
    NSInteger sectionCount = 0;
    // Loop through the array of JSON deals and create Deal objects added to a mutable array
    for (id aDeal in dealsArray) {
        NSString *jsonDateString = [aDeal objectForKey:@"datePosted"];
        NSInteger dateOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
        NSDate *datePosted = [[NSDate dateWithTimeIntervalSince1970:[[jsonDateString substringWithRange:NSMakeRange(6, 10)] intValue]]dateByAddingTimeInterval:dateOffset]; 
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMMM d yyyy"];
        NSString *stringFromDate = [formatter stringFromDate:[datePosted dateByAddingTimeInterval:60*60*24*1]];
        
        sectionExists = NO;
        for (NSString *str in [self.sections allKeys]) {
            if ([str isEqualToString:[NSString stringWithFormat:@"%d%@", sectionCount, stringFromDate]])
                sectionExists = YES;
        }
        if (!sectionExists) {
            sectionCount++;
            [self.sections setValue:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%d%@", sectionCount, stringFromDate]];
        }
        
        NSURL *imageURL = [NSURL URLWithString:[aDeal objectForKey:@"image"]];
        DealData *deal = 
        [[DealData alloc] initWithHeadline:[[aDeal valueForKey:@"headline"] gtm_stringByUnescapingFromHTML]
                                      body:[aDeal valueForKey:@"body"]
                                  imageURL:imageURL
                                 isExpired:[[aDeal valueForKey:@"isExpired"] boolValue]
                                datePosted:datePosted];
        
        [deals addObject:deal];
        [[self.sections objectForKey:[NSString stringWithFormat:@"%d%@", sectionCount, stringFromDate]] addObject:deal];
    };
    
    // Set the created mutable array to the controller's property
    [self setDeals:deals];
    [self.tableView reloadData];
    [self.searchButton setEnabled:YES];

    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];

    //send the finished message to the current pull-to-refresh control
    [self.refreshControl endRefreshing];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"connection error");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"Could not connect to the remote server at this time."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];

    //send the finished message to the current pull-to-refresh control
    [self.refreshControl endRefreshing];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connection success");
    [AppDelegate postResetBadgeCount];
}

- (void)fetchAndParseDataIntoTableView:(BOOL)showHUD {
    if ( showHUD ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [hud setLabelText:@"Loading"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [hud setDimBackground:YES];
        }
    }
    
    //build the connection for async data downloading, 20 second timeout
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.mccrager.com/passwird?e=%d", [[NSUserDefaults standardUserDefaults] boolForKey:@"showExpiredDeals"]]];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];                                
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    //on good connection, fill responseData, delegate will fire connection:didReceiveData:
    if ( connection ) {
        [self setResponseData:[[NSMutableData alloc] init]];
    } else {
        NSLog(@"connection failed");  
    }    
}

#pragma mark - Managing PullToRefresh

- (void)refresh {
    [Flurry logEvent:@"Pull to Refresh"];
    [self fetchAndParseDataIntoTableView:NO];
}

#pragma mark - Managing the About modal view

- (void)showAboutModal:(id)sender {
    [self performSegueWithIdentifier: @"About" sender: self];
}

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass selected deal to detail controller
    if ([segue.identifier isEqualToString:@"Detail"]) {
        [self setDetailViewController:segue.destinationViewController];
        
        DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] 
                                                       sortedArrayUsingSelector:@selector(compare:)] 
                                                      objectAtIndex:self.tableView.indexPathForSelectedRow.section]] 
                          objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        [self.detailViewController setDetailItem:deal];
    }
}
        
- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logPageView];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //ISRefreshControl logic for iOS6 style pull to refresh for both iOS5 and 6
    UIColor *bgColor = [UIColor colorWithRed:(171.0/255.0) green:(171.0/255.0) blue:(171.0/255.0) alpha:1.0];
    self.refreshControl = (id)[[ISRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor darkGrayColor]];
    [self.refreshControl setBackgroundColor:bgColor];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    
    //create a colored background view to place behind the refresh control
    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    UIView *bgView = [[UIView alloc] initWithFrame:frame];
    [bgView setBackgroundColor: bgColor];
    [self.tableView insertSubview:bgView atIndex:0];
    
    //create the info button and replace the info button on the storyboard, this
    //button will use that modal segue linked from the replaced info button
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infoButton setTintColor:[UIColor darkGrayColor]];
    [infoButton setFrame:CGRectMake(-10, -10, 56, 56)];
    [infoButton addTarget:self 
                   action:@selector(showAboutModal:) 
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setLeftBarButtonItem:infoBarButtonItem];
    
    [self fetchAndParseDataIntoTableView:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPushNotification:)
                                                 name:@"receivedPushNotification"
                                               object:nil];
}

- (void)receivedPushNotification:(NSNotification*)aNotification {
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [self fetchAndParseDataIntoTableView:YES];
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)viewDidUnload {
    [self setSearchButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
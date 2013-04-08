//
//  PDTableViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/22/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "PDTableViewController.h"

#import "DealCell.h"

#import "Extensions.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "GTMNSString+HTML.h"
#import "ISRefreshControl.h"

@implementation PDTableViewController

#pragma mark - Managing the table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.sections allKeys] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[UIColor pdRedColor]];
    
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, tableView.bounds.size.width, 20)];
    [labelView setBackgroundColor:[UIColor clearColor]];
    [labelView setFont:[UIFont boldSystemFontOfSize:15]];
    [labelView setTextColor:[UIColor whiteColor]];
    [labelView setShadowColor:[UIColor darkGrayColor]];
    [labelView setShadowOffset:CGSizeMake(0, 1)];
    [labelView setText:[[[[self.sections allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]] objectAtIndex:section] substringFromIndex:9]];
    
    [headerView addSubview:labelView];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]] objectAtIndex:section]] count];
}

- (DealCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set the deal into the DealCell
    DealCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DealCell"];
    
    DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:deal.headline];
    [cell.imageView setImageWithURL:deal.imageURL
                   placeholderImage:[UIImage imageNamed:@"icon-precomposed.png"]];
    
    if ( !deal.isExpired )
        [cell.detailTextLabel setText:nil];
    else
        [cell.detailTextLabel setText:@"(expired)"];
    
    UIView *selectedBgView = [[UIView alloc] init];
    [selectedBgView setBackgroundColor:[UIColor pdBlueColor]];
    [cell setSelectedBackgroundView:selectedBgView];
    
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
        
        DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]] objectAtIndex:self.tableView.indexPathForSelectedRow.section]] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        [self.detailViewController setDetailItem:deal];
    }
}

#pragma mark - Managing the asynchronous data download

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"connection error");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                        message:ERROR_MESSAGE
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //send the finished message to the current pull-to-refresh control
    [self.refreshControl endRefreshing];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"connection success");
    
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                options:kNilOptions
                                                  error:&error];
    
    NSDictionary *dealsDictionary = result;
    NSArray *dealsArray = [dealsDictionary objectForKey:@"deals"];
    
    [self setSections:[NSMutableDictionary dictionary]];
    
    BOOL sectionExists;
    NSDateFormatter *longFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *shortFormat = [[NSDateFormatter alloc] init];
    [longFormat setDateFormat:@"EEEE, MMMM d yyyy"];
    [shortFormat setDateFormat:@"MMddyyyy"];
    
    // Loop through the array of JSON deals and create Deal objects added to a mutable array
    for (id aDeal in dealsArray) {
        NSString *jsonDateString = [aDeal objectForKey:@"datePosted"];
        NSInteger dateOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
        NSDate *datePosted = [[NSDate dateWithTimeIntervalSince1970:[[jsonDateString substringWithRange:NSMakeRange(6, 10)] intValue]]dateByAddingTimeInterval:dateOffset];
        
        NSString *stringFromLongDate = [longFormat stringFromDate:[datePosted dateByAddingTimeInterval:60*60*24*1]];
        NSString *stringFromShortDate = [shortFormat stringFromDate:[datePosted dateByAddingTimeInterval:60*60*24*1]];
        NSString *joinedDates = [NSString stringWithFormat:@"%@,%@", stringFromShortDate, stringFromLongDate];
        
        sectionExists = NO;
        for (NSString *str in [self.sections allKeys]) {
            if ([str isEqualToString:joinedDates])
                sectionExists = YES;
        }
        if (!sectionExists) {
            [self.sections setValue:[NSMutableArray array] forKey:joinedDates];
        }
        
        DealData *deal =
        [[DealData alloc] initWithHeadline:[[aDeal valueForKey:@"headline"] gtm_stringByUnescapingFromHTML]
                                      body:[aDeal valueForKey:@"body"]
                                  imageURL:[NSURL URLWithString:[aDeal objectForKey:@"image"]]
                                 isExpired:[[aDeal valueForKey:@"isExpired"] boolValue]
                                datePosted:datePosted];

        [[self.sections objectForKey:joinedDates] addObject:deal];
        
        //clear up
        jsonDateString = nil;
        stringFromLongDate = nil;
        stringFromShortDate = nil;
        joinedDates = nil;
        datePosted = nil;
        deal = nil;
    };
    
    [self.tableView reloadData];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //send the finished message to the current pull-to-refresh control
    [self.refreshControl endRefreshing];
    
    dealsDictionary = nil;
    dealsArray = nil;
    longFormat = nil;
    shortFormat = nil;
}

#pragma mark - Control creation

- (void)createRefreshControls {
    //ISRefreshControl logic for iOS6 style pull to refresh for both iOS5 and 6
    UIColor *bgColor = [UIColor pdLightGrayColor];
    self.refreshControl = (id)[[ISRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor pdDarkGrayColor]];
    [self.refreshControl setBackgroundColor:bgColor];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    
    //create a colored background view to place behind the refresh control
    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    UIView *bgView = [[UIView alloc] initWithFrame:frame];
    [bgView setBackgroundColor: bgColor];
    [bgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.tableView insertSubview:bgView atIndex:0];
}

- (void)createInfoBarButtonItem {
    //create the info button and replace the info button on the storyboard, this
    //button will use that modal segue linked from the replaced info button
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton setTintColor:[UIColor pdLightGrayColor]];
    [infoButton setFrame:CGRectMake(0, 0, 44, 44)];
    [infoButton addTarget:self
                   action:@selector(showAboutModal:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setLeftBarButtonItem:infoBarButtonItem];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [self setSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compare:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass selected deal to detail controller
    if ([segue.identifier isEqualToString:@"Detail"]) {
        [self setDetailViewController:segue.destinationViewController];
        
        DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]] objectAtIndex:self.tableView.indexPathForSelectedRow.section]] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        [self.detailViewController setDetailItem:deal];
    }
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
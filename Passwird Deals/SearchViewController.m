//
//  SearchViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 4/17/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "DetailViewController.h"

#import "DealCell.h"
#import "DealData.h"
#import "Extensions.h"
#import "MBProgressHUD.h"
#import "GTMNSString+HTML.h"
#import "UIImageView+WebCache.h"
#import "Flurry.h"

@implementation SearchViewController

@synthesize detailViewController = _detailViewController;
@synthesize searchBar = _searchBar;
@synthesize deals = _deals;
@synthesize sections = _sections;

#pragma mark - Managing the table view

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 85;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.sections allKeys] count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
//{
//    return [[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[UIColor colorWithRed:202.0/255.0 green:13.0/255.0 blue:38.0/255.0 alpha:0.90]];
    
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, tableView.bounds.size.width, 20)];
    [labelView setBackgroundColor:[UIColor clearColor]];
    [labelView setFont:[UIFont boldSystemFontOfSize:15]];
    [labelView setTextColor:[UIColor whiteColor]];
    [labelView setShadowColor:[UIColor darkGrayColor]];
    [labelView setShadowOffset:CGSizeMake(0, 1)];
    [labelView setText:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section]];
    
    [headerView addSubview:labelView];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section]] count];
}

- (DealCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set the deal into the DealCell
    DealCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DealCell"];
    
    //DealData *deal = [self.deals objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //hide view via alpha, and animate in over 1 sec
        [self.detailViewController.webView setAlpha:0];
        [UIView animateWithDuration:0.8 animations:^() {
            [self.detailViewController.webView setAlpha:1];
        }];        
        
        DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)]                          objectAtIndex:self.tableView.indexPathForSelectedRow.section]] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        self.detailViewController.detailItem = deal;
    }
}

- (void)fetchAndParseDataIntoTableView 
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Loading";
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Build dictionary from JSON at URL
        NSLog(@"Search input: %@", self.searchBar.text);
        
        NSDictionary *searchInputDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                               self.searchBar.text,
                                               @"Query",
                                               nil];
        [Flurry logEvent:@"Search" withParameters:searchInputDictionary];
        searchInputDictionary = nil;
        
        //get expired deals setting from app delegate
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSDictionary* dealsDictionary = [NSDictionary dictionaryWithContentsOfJSONURLString:[NSString stringWithFormat:@"http://mccrager.com/api/passwirdsearch?q=%@&e=%d", [self.searchBar.text urlEncode], appDelegate.showExpiredDeals]];
        
        NSArray* dealsArray = [dealsDictionary objectForKey:@"deals"];
        NSMutableArray *deals = [NSMutableArray array];
        self.sections = [NSMutableDictionary dictionary];
        
        [self.sections setValue:[NSMutableArray array] forKey:@"Search Results"];
        // Loop through the array of JSON deals and create Deal objects added to a mutable array
        for (id aDeal in dealsArray) {
            NSString *jsonDateString = [aDeal objectForKey:@"datePosted"];
            NSInteger dateOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
            NSDate *datePosted = [[NSDate dateWithTimeIntervalSince1970:[[jsonDateString substringWithRange:NSMakeRange(6, 10)] intValue]]dateByAddingTimeInterval:dateOffset]; 
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMMM d yyyy"];
            
            NSURL *imageURL = [NSURL URLWithString:[aDeal objectForKey:@"image"]];
            DealData *deal = 
            [[DealData alloc] initWithHeadline:[[aDeal valueForKey:@"headline"] gtm_stringByUnescapingFromHTML]
                                          body:[aDeal valueForKey:@"body"]
                                      imageURL:imageURL
                                     isExpired:[[aDeal valueForKey:@"isExpired"] boolValue]
                                    datePosted:datePosted];
            
            [deals addObject:deal];
            [[self.sections objectForKey:@"Search Results"] addObject:deal];
        };
        
        // Set the created mutable array to the controller's property
        self.deals = deals;
        [self.tableView reloadData];
        
        if ( [self.tableView numberOfRowsInSection:0] == 0 )
        {
            NSLog(@"%d", [self.tableView numberOfRowsInSection:0]);
            [self.sections setObject: [self.sections objectForKey: @"Search Results"] forKey: @"No Results Found"];
            [self.sections removeObjectForKey: @"Search Results"];
        }
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    });    
}

#pragma mark - Managing the search bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [self.view endEditing:YES];
    
    self.deals = nil;
    self.sections = nil;
    [self.tableView reloadData]; 
    
    [self fetchAndParseDataIntoTableView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar 
{
    [self.searchBar resignFirstResponder];    
}

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass selected deal to detail controller
    if ([segue.identifier isEqualToString:@"Detail"]) {
        //DetailViewController *detailController = segue.destinationViewController;
        self.detailViewController = segue.destinationViewController;
        
        //DealData *deal = [self.deals objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] 
                                                       sortedArrayUsingSelector:@selector(compare:)] 
                                                      objectAtIndex:self.tableView.indexPathForSelectedRow.section]] 
                          objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        self.detailViewController.detailItem = deal;   
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.tableView setRowHeight:85.f];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logPageView];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // Set the keyboard appearance of the search bar
    for (UIView *searchBarSubview in [self.searchBar subviews]) {
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
            }
            @catch (NSException * e) {
                // ignore exception
            }
        }
    }
    
    [self.searchBar becomeFirstResponder];
    self.searchBar.delegate = self;
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
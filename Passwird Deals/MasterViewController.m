//
//  MasterViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "DealData.h"
#import "Extensions.h"
#import "MBProgressHUD.h"
#import "GTMNSString+HTML.h"
#import "UIImageView+WebCache.h"

#import "PullToRefreshView.h"

@implementation MasterViewController

@synthesize refreshButton = _refreshButton;
@synthesize searchButton = _searchButton;
@synthesize deals = _deals;
@synthesize sections = _sections;
PullToRefreshView *pull;

#pragma mark - Managing the table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.sections allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section] substringFromIndex:1];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set the deal into the DealCell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DealCell"];
    
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

- (IBAction)refresh:(id)sender {
    self.deals = nil;
    self.sections = nil;
    [self.tableView reloadData];
    [self.refreshButton setEnabled:NO];
    [self.searchButton setEnabled:NO];
    [self fetchAndParseDataIntoTableView:YES];
}

- (void)fetchAndParseDataIntoTableView:(BOOL)showHUD {
    if ( showHUD ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Loading";
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Build dictionary from JSON at URL
        NSDictionary* dealsDictionary = [NSDictionary dictionaryWithContentsOfJSONURLString:@"http://mccrager.com/api/passwird"];  
        if ( dealsDictionary == nil ) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                message:@"Could not connect to the remote server at this time."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
            [alertView show];            
        } else {
            NSArray* dealsArray = [dealsDictionary objectForKey:@"deals"];
            NSMutableArray *deals = [NSMutableArray array];
            self.sections = [NSMutableDictionary dictionary];
            
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
                for (NSString *str in [self.sections allKeys])
                {
                    if ([str isEqualToString:[NSString stringWithFormat:@"%d%@", sectionCount, stringFromDate]])
                        sectionExists = YES;
                }
                if (!sectionExists) {
                    sectionCount++;
                    [self.sections setValue:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%d%@", sectionCount, stringFromDate]];
                }
                
                NSURL *imageURL = [NSURL URLWithString:[aDeal objectForKey:@"image"]];
                DealData *deal = 
                [[DealData alloc] init:[[aDeal valueForKey:@"headline"] gtm_stringByUnescapingFromHTML]
                                  body:[aDeal valueForKey:@"body"]
                              imageURL:imageURL
                             imageData:nil
                             isExpired:[[aDeal valueForKey:@"isExpired"] boolValue]
                            datePosted:datePosted];
                
                [deals addObject:deal];
                [[self.sections objectForKey:[NSString stringWithFormat:@"%d%@", sectionCount, stringFromDate]] addObject:deal];
            };
            
            // Set the created mutable array to the controller's property
            self.deals = deals;
            [self.tableView reloadData];
            self.refreshButton.enabled = YES;
            self.searchButton.enabled = YES;
        }
        if ( showHUD )
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        [pull finishedLoading];
    });    
}

#pragma mark - Managing PullToRefresh

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self fetchAndParseDataIntoTableView:NO];
}

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass selected deal to detail controller
    if ([segue.identifier isEqualToString:@"Detail"]) {
        DetailViewController *detailController = segue.destinationViewController;
        
        //DealData *deal = [self.deals objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] 
                                                       sortedArrayUsingSelector:@selector(compare:)] 
                                                      objectAtIndex:self.tableView.indexPathForSelectedRow.section]] 
                          objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        detailController.detailItem = deal;   
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] 
                                    animated:NO 
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];
    
    [self fetchAndParseDataIntoTableView:YES];
}

- (void)viewDidUnload
{
    [self setRefreshButton:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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
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

@synthesize searchButton = _searchButton;
@synthesize responseData = _responseData;
@synthesize deals = _deals;
@synthesize sections = _sections;
PullToRefreshView *pull;

#pragma mark - Managing the table view

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}

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

#pragma mark - Managing the asyncronous data download

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
    
    NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                options:kNilOptions error:&error];    
    
    NSDictionary* dealsDictionary = result;  
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
    self.searchButton.enabled = YES;
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [pull finishedLoading];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection error");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"Could not connect to the remote server at this time."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [pull finishedLoading];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connection success");
}

- (void)fetchAndParseDataIntoTableView:(BOOL)showHUD {
    if ( showHUD ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Loading";
    }
    
    //build the connection for async data downloading, 10 second timeout
    NSURL *url = [NSURL URLWithString:@"http://mccrager.com/api/passwird"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];                                
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    //on good connection, fill responseData, delegate will fire connection:didReceiveData:
    if ( connection ) {
        self.responseData = [[NSMutableData alloc] init];
    } else {
        NSLog(@"connection failed");  
    }    
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
    [self setSearchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setRowHeight:85.f];
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
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

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize refreshButton = _refreshButton;
@synthesize deals = _deals;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Managing the table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.deals count];
}

// Set the deal into the DealCell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DealCell"];
    
    DealData *deal = [self.deals objectAtIndex:indexPath.row];
    
    cell.textLabel.text = deal.headline;
    cell.imageView.image = deal.image;
    if ( !deal.isExpired )
        cell.detailTextLabel.text = nil;
    else
        cell.detailTextLabel.text = @"(expired)";
    
    return cell;
}

// Pass selected deal to detail controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *detailController = segue.destinationViewController;
    DealData *deal = [self.deals objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    detailController.detailItem = deal;
}

- (IBAction)refresh:(id)sender {
    self.deals = nil;
    [self.tableView reloadData];    
    self.refreshButton.enabled = NO;
    [self fetchAndParseDataIntoTableView];
}

- (void)fetchAndParseDataIntoTableView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Build dictionary from JSON at URL
        NSDictionary* dealsDictionary = [NSDictionary dictionaryWithContentsOfJSONURLString:@"http://mccrager.com/api/passwird"];    
        NSArray* dealsArray = [dealsDictionary objectForKey:@"deals"];
        NSMutableArray *deals = [NSMutableArray array];
        // Loop through the array of JSON deals and create Deal objects added to a mutable array
        for (id aDeal in dealsArray) {
            NSURL *imageURL = [NSURL URLWithString:[aDeal objectForKey:@"image"]];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
            UIImage *thumb = [image makeThumbnailOfSize:CGSizeMake(50,50)];
            NSNumber *isExpired = [aDeal valueForKey:@"isExpired"];
            NSString *headline = [[aDeal valueForKey:@"headline"] gtm_stringByUnescapingFromHTML];

            
            DealData *deal = 
            [[DealData alloc] init:headline
                              body:[aDeal valueForKey:@"body"]
                             image:thumb
                          imageURL:imageURL
                         isExpired:[isExpired boolValue]];
            [deals addObject:deal];
        }
        // Set the created mutable array to the controller's property
        self.deals = deals;
        [self.tableView reloadData];
        self.refreshButton.enabled = YES;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    [self fetchAndParseDataIntoTableView];
}

- (void)viewDidUnload
{
    [self setRefreshButton:nil];
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
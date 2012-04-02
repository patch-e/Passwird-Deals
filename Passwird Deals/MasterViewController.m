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
#import "NSDictionaryExtension.h"
#import "UIImageExtension.h"
#import "NSStringExtension.h"

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    // Build dictionary from JSON at URL
    NSDictionary* dealsDictionary = [NSDictionary dictionaryWithContentsOfJSONURLString:@"http://mccrager.com/api/passwird"];    
    NSArray* dealsArray = [dealsDictionary objectForKey:@"deals"];
    NSMutableArray *deals = [NSMutableArray array];
    // Loop through the array of JSON deals and create Deal objects added to a mutable array
    for (id aDeal in dealsArray) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[aDeal objectForKey:@"image"]]]];
        UIImage *thumb = [image makeThumbnailOfSize:CGSizeMake(50,50)];
        NSNumber *isExpired = [aDeal valueForKey:@"isExpired"];
        NSString *headline = [[aDeal valueForKey:@"headline"] gtm_stringByUnescapingFromHTML];
        
        DealData *deal = 
        [[DealData alloc] initWithTitle:headline
                                   body:[aDeal valueForKey:@"body"]
                                  image:thumb
                              isExpired:[isExpired boolValue]];
        [deals addObject:deal];
    }
    // Set the created mutable array to the controller's property
    self.deals = deals;
    self.title = @"Passwird Deals";
}

- (void)viewDidUnload
{
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
    [self.tableView reloadData];
    NSLog(@"here");
}

@end
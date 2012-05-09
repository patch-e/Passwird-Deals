//
//  SearchViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 4/17/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailViewController.h"

#import "DealData.h"
#import "Extensions.h"
#import "MBProgressHUD.h"
#import "GTMNSString+HTML.h"
#import "UIImageView+WebCache.h"

@implementation SearchViewController

@synthesize searchBar;
@synthesize doneButton;
@synthesize deals = _deals;
@synthesize sections = _sections;

#pragma mark - Managing the detail item

//- (void)setDetailItem:(id)newDetailItem
//{
//
//}

#pragma mark - Managing the search view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.sections allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section]] count];
}

// Set the deal into the DealCell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

// Pass selected deal to detail controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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

- (IBAction)done:(id)sender 
{
    [searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [searchBar resignFirstResponder];
    
    self.deals = nil;
    self.sections = nil;
    [self.tableView reloadData]; 
    [self fetchAndParseDataIntoTableView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
    [searchBar becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion: nil];
}


- (void)fetchAndParseDataIntoTableView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Build dictionary from JSON at URL
        NSLog(@"Search input: %@", searchBar.text);
        NSDictionary* dealsDictionary = [NSDictionary dictionaryWithContentsOfJSONURLString:[NSString stringWithFormat:@"http://mccrager.com/api/passwirdsearch?q=%@", searchBar.text]];
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
            
            DealData *deal = 
            [[DealData alloc] init:[[aDeal valueForKey:@"headline"] gtm_stringByUnescapingFromHTML]
                              body:[aDeal valueForKey:@"body"]
                          imageURL:[NSURL URLWithString:[aDeal objectForKey:@"image"]]
                         isExpired:[[aDeal valueForKey:@"isExpired"] boolValue]
                        datePosted:datePosted];
            
            [deals addObject:deal];
            [[self.sections objectForKey:@"Search Results"] addObject:deal];
        };
        
        // Set the created mutable array to the controller's property
        self.deals = deals;
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] 
                                    animated:NO 
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    [searchBar becomeFirstResponder];
    searchBar.delegate = self;
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
//
//  PDTableViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/22/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "PDTableViewController.h"

#import "PDTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "GTMNSString+HTML.h"

@implementation PDTableViewController

#pragma mark - Managing the table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.sections allKeys] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    [headerView setBackgroundColor:[UIColor pdSectionBackgroundColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    [label setTextColor:[UIColor pdSectionTextColor]];
    [label setText:[[[[self.sections allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]] objectAtIndex:section] substringFromIndex:9]];
    [headerView addSubview:label];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]] objectAtIndex:section]] count];
}

- (PDTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // set the deal into the PDTableViewCell
    PDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DealCell"];
    DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    // set values
    [cell.textLabel setText:deal.headline];
    [cell.imageView sd_setImageWithURL:deal.imageURL
                      placeholderImage:[UIImage imageNamed:@"icon-precomposed.png"]];
    if (!deal.isExpired) {
        [cell.imageView setAlpha:1.0f];
        [cell.textLabel setTextColor:[UIColor pdTextColor]];
        [cell setHasBanner:NO];
    } else {
        [cell.imageView setAlpha:0.5f];
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
        [cell setHasBanner:YES];
    }
    
    // set the selection view
    UIView *selectedBgView = [[UIView alloc] init];
    [selectedBgView setBackgroundColor:[UIColor pdTitleTextStrokeColor]];
    [cell setSelectedBackgroundView:selectedBgView];
    [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.detailViewController.navigationController popToRootViewControllerAnimated:YES];
        
        //hide view via alpha, and animate in over 1 sec
        [self.detailViewController.wkWebView setAlpha:0];
        [UIView animateWithDuration:0.8 animations:^() {
            [self.detailViewController.wkWebView setAlpha:1];
        }];
        //enable the action buttons
        [self.detailViewController.shareButton setEnabled:YES];
        [self.detailViewController.reportButton setEnabled:YES];
        
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
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:ERROR_TITLE
                                          message:ERROR_MESSAGE
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction cancelActionWithController:self]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
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
    
    int index = 10000000;
    // Loop through the array of JSON deals and create Deal objects added to a mutable array
    for (id aDeal in dealsArray) {
        NSString *jsonDateString = [aDeal objectForKey:@"datePosted"];
        NSInteger dateOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
        NSDate *datePosted = [[NSDate dateWithTimeIntervalSince1970:[[jsonDateString substringWithRange:NSMakeRange(6, 10)] intValue]]dateByAddingTimeInterval:dateOffset];
    
        NSString *stringFromLongDate = [longFormat stringFromDate:[datePosted dateByAddingTimeInterval:60*60*24*1]];
        NSString *joinedSectionKey = [NSString stringWithFormat:@"%d,%@", index, stringFromLongDate];
        
        sectionExists = NO;
        for (NSString *str in [self.sections allKeys]) {
            if ([str isEqualToString:joinedSectionKey]) {
                sectionExists = YES;
            }
        }
        
        if (!sectionExists) {
            index++;
            joinedSectionKey = [NSString stringWithFormat:@"%d,%@", index, stringFromLongDate];
            [self.sections setValue:[NSMutableArray array] forKey:joinedSectionKey];
        }
        
        DealData *deal =
        [[DealData alloc] initWithHeadline:[[aDeal valueForKey:@"headline"] gtm_stringByUnescapingFromHTML]
                                      body:[aDeal valueForKey:@"body"]
                                  imageURL:[NSURL URLWithString:[aDeal objectForKey:@"image"]]
                                 isExpired:[[aDeal valueForKey:@"isExpired"] boolValue]
                                datePosted:datePosted
                                    dealId:[aDeal valueForKey:@"id"]
                                      slug:[aDeal valueForKey:@"slug"]
                                 sHeadline:[aDeal valueForKey:@"sHeadline"]];

        [[self.sections objectForKey:joinedSectionKey] addObject:deal];
        
        //clean up
        jsonDateString = nil;
        stringFromLongDate = nil;
        joinedSectionKey = nil;
        datePosted = nil;
        deal = nil;
    };
    
    [self.tableView reloadData];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    //send the finished message to the current pull-to-refresh control
    [self.refreshControl endRefreshing];
    
    dealsDictionary = nil;
    dealsArray = nil;
    longFormat = nil;
    shortFormat = nil;
}

#pragma mark - Control creation

- (void)createRefreshControls {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor lightGrayColor]];
    
    SEL refreshSelector = NSSelectorFromString(@"refresh");
    [self.refreshControl addTarget:self
                            action:refreshSelector
                  forControlEvents:UIControlEventValueChanged];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(compare:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass selected deal to detail controller
    if ([segue.identifier isEqualToString:@"Detail"]) {
        [self setDetailViewController:segue.destinationViewController];
        
        DealData *deal = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]] objectAtIndex:self.tableView.indexPathForSelectedRow.section]] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        [self.detailViewController setDetailItem:deal];
    }
}

#pragma mark - Misc

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end

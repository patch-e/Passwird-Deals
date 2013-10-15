//
//  PDTableViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/22/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "DetailViewController.h"

@interface PDTableViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSSortDescriptor *sortDescriptor;

- (void)createRefreshControls;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
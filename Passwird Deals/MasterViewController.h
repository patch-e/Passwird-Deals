//
//  MasterViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "PullToRefreshView.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <PullToRefreshViewDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSMutableArray *deals;
@property (strong, nonatomic) NSMutableDictionary *sections;

@end
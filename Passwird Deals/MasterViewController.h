//
//  MasterViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PullToRefreshView.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <PullToRefreshViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;

@property (strong) NSMutableData *responseData;
@property (strong) NSMutableArray *deals;
@property (strong) NSMutableDictionary *sections;

@end
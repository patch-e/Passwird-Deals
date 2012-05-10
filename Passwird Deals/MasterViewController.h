//
//  MasterViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;

@property (strong) NSMutableArray *deals;
@property (strong) NSMutableDictionary *sections;

- (IBAction)refresh:(id)sender;

@end
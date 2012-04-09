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

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (strong) NSMutableArray *deals;

- (IBAction)refresh:(id)sender;

@end
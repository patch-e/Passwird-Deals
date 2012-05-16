//
//  SearchViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 4/17/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface SearchViewController : UITableViewController <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong) NSMutableArray *deals;
@property (strong) NSMutableDictionary *sections;

@end
//
//  SearchViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 4/17/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

@class DetailViewController;

@interface SearchViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSMutableArray *deals;
@property (strong, nonatomic) NSMutableDictionary *sections;

@end
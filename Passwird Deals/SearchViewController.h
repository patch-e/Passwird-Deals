//
//  SearchViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 4/17/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "PDTableViewController.h"

@class DetailViewController;

@interface SearchViewController : PDTableViewController <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
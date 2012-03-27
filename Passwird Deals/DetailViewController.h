//
//  DetailViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DealData;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) DealData * detailItem;

@property (weak, nonatomic) IBOutlet UILabel *headlineField;
@property (weak, nonatomic) IBOutlet UILabel *bodyField;

@end
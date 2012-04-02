//
//  DetailViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DealData;

@interface DetailViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) DealData * detailItem;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;

-(IBAction)goBack:(id)sender;
-(IBAction)goForward:(id)sender;

@end
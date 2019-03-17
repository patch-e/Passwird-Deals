//
//  DetailViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "PDViewController.h"

#import "DealData.h"

@import MessageUI;
@import SafariServices;

@interface DetailViewController : PDViewController <WKNavigationDelegate, UISplitViewControllerDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *wkWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reportButton;

@property (strong, nonatomic) DealData *detailItem;
@property (strong, nonatomic) NSURL *selectedURL;
@property (strong, nonatomic) NSMutableData *responseData;
@property (assign, nonatomic) NSUInteger detailId;

- (IBAction)showActionSheet:(id)sender;
- (IBAction)reportExpired:(id)sender;

- (void)configureView;
- (void)createConnectionWithHUD:(BOOL)showHUD;

@end

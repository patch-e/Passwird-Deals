//
//  WebViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 5/8/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "PDViewController.h"

#import "DealData.h"

#import <MessageUI/MessageUI.h>

@interface WebViewController : PDViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;

@property (strong, nonatomic) DealData *detailItem;
@property (strong, nonatomic) NSURL *pushedURL;

@property (weak, nonatomic) UIActionSheet *actionSheet;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)showActionSheet:(id)sender;

@end
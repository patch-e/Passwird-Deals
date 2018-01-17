//
//  DetailViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "PDViewController.h"

#import "DealData.h"

#import <MessageUI/MessageUI.h>
#import <SafariServices/SafariServices.h>

@interface DetailViewController : PDViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UISplitViewControllerDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (strong, nonatomic) DealData *detailItem;
@property (strong, nonatomic) NSURL *selectedURL;
@property (strong, nonatomic) NSMutableData *responseData;
@property (assign, nonatomic) NSUInteger detailId;

@property (weak, nonatomic) UIActionSheet *actionSheet;

- (IBAction)showActionSheet:(id)sender;

- (void)configureView;
- (void)createConnectionWithHUD:(BOOL)showHUD;

@end

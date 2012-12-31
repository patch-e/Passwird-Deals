//
//  DetailViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@class DealData;

@interface DetailViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (strong, nonatomic) DealData *detailItem;
@property (strong, nonatomic) NSURL *selectedURL;

@property (weak, nonatomic) UIActionSheet *actionSheet;

- (IBAction)showActionSheet:(id)sender;

@end
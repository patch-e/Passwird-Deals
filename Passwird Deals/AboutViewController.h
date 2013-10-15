//
//  AboutViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 5/30/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "PDNavigationBar.h"

#import "THLabel.h"

#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>

@interface AboutViewController : UIViewController <UIScrollViewDelegate, MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet PDNavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UISwitch *expiredSwitch;
@property (weak, nonatomic) IBOutlet THLabel *appNameLabel;

- (IBAction)saveSettings:(id)sender;
- (IBAction)dismissView:(id)sender;
- (IBAction)donateLink:(id)sender;
- (IBAction)emailLink:(id)sender;
- (IBAction)rateLink:(id)sender;
- (IBAction)githubLink:(id)sender;

@end
//
//  SettingsViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 5/30/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "PDViewController.h"
#import "PDNavigationBar.h"

#import "THLabel.h"

#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>

@interface SettingsViewController : PDViewController <UIScrollViewDelegate, MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *expiredSwitch;
@property (weak, nonatomic) IBOutlet THLabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *donateButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *githubButton;

- (IBAction)saveSettings:(id)sender;
- (IBAction)dismissView:(id)sender;
- (IBAction)donateLink:(id)sender;
- (IBAction)emailLink:(id)sender;
- (IBAction)rateLink:(id)sender;
- (IBAction)githubLink:(id)sender;

@end
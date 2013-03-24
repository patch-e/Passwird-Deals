//
//  AboutViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 5/30/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>

@interface AboutViewController : UIViewController <UIScrollViewDelegate, MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UISwitch *expiredSwitch;
@property (weak, nonatomic) IBOutlet UILabel *legalLabel;

- (IBAction)saveSettings:(id)sender;
- (IBAction)dismissView:(id)sender;
- (IBAction)donateLink:(id)sender;
- (IBAction)emailLink:(id)sender;
- (IBAction)rateLink:(id)sender;
- (IBAction)githubLink:(id)sender;
- (IBAction)passwirdLink:(id)sender;

@end
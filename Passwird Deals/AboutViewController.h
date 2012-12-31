//
//  AboutViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 5/30/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface AboutViewController : UIViewController <UIScrollViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UISwitch *expiredSwitch;

- (IBAction)saveSettings:(id)sender;
- (IBAction)dismissView:(id)sender;
- (IBAction)donateLink:(id)sender;
- (IBAction)emailLink:(id)sender;
- (IBAction)rateLink:(id)sender;
- (IBAction)twitterLink:(id)sender;
- (IBAction)passwirdLink:(id)sender;

@end
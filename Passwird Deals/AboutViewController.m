//
//  AboutViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 5/30/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "AppDelegate.h"
#import "AboutViewController.h"

@implementation AboutViewController

@synthesize scrollView = _scrollView;
@synthesize doneButton = _doneButton;
@synthesize expiredSwitch = _expiredSwitch;

NSString *aboutEmailAddress = @"p.crager@gmail.com";
NSString *aboutPasswirdURL = @"http://passwird.com";
NSString *aboutTwitterURL = @"http://twitter.com/mccrager";
NSString *aboutReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=517165629";
NSString *aboutDonateURL = @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=p.crager@gmail.com&item_name=Passwird+Deals+app+donation&currency_code=USD";

#pragma mark - Managing the buttons

- (IBAction)saveSettings:(id)sender {
    //get expired deals setting from app delegate
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.showExpiredDeals = self.expiredSwitch.on;
        
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setBool:appDelegate.showExpiredDeals forKey:@"hideExpiredDeals"];
    [prefs synchronize];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Settings"
                                                        message:@"Expired deals setting will be applied during the next refresh or search."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

- (IBAction)donateLink:(id)sender {
    NSURL *url = [NSURL URLWithString:aboutDonateURL];
    [[UIApplication sharedApplication] openURL:url];    
}

- (IBAction)emailLink:(id)sender {
    [self openMail];
}

- (IBAction)rateLink:(id)sender {
    NSURL *url = [NSURL URLWithString:aboutReviewURL];
    [[UIApplication sharedApplication] openURL:url];  
}

- (IBAction)twitterLink:(id)sender {
    NSURL *url = [NSURL URLWithString:aboutTwitterURL];
    [[UIApplication sharedApplication] openURL:url];  
}

- (IBAction)passwirdLink:(id)sender {
    NSURL *url = [NSURL URLWithString:aboutPasswirdURL];
    [[UIApplication sharedApplication] openURL:url];  
}

- (void)openMail {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setToRecipients:[NSArray arrayWithObject:aboutEmailAddress]];
        [mailer setSubject:@"Passwird Deals app feedback"];
        
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"Your device doesn't support composing of emails."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Managing the scroll view

- (void)calculateAndSetScrollViewHeight {
    CGFloat scrollViewHeight = 0.0f;
    for (UIView *view in self.scrollView.subviews){
        if (scrollViewHeight < view.frame.origin.y + view.frame.size.height) scrollViewHeight = view.frame.origin.y + view.frame.size.height;
    }
    [self.scrollView setContentSize:CGSizeMake(0, scrollViewHeight)];
}

#pragma mark - View lifecycle

- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self calculateAndSetScrollViewHeight];
    
    //get expired deals setting from app delegate
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self.expiredSwitch setOn:appDelegate.showExpiredDeals];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setDoneButton:nil];
    [self setExpiredSwitch:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self calculateAndSetScrollViewHeight];
    
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end

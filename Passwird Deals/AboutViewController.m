//
//  AboutViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 5/30/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "AboutViewController.h"

#import "Constants.h"
#import "MBProgressHUD.h"
#import "Flurry.h"

@implementation AboutViewController

#pragma mark - Managing the buttons

- (IBAction)saveSettings:(id)sender {
    [Flurry logEvent:FLURRY_SAVE];
    
    [[NSUserDefaults standardUserDefaults] setBool:self.expiredSwitch.on forKey:@"showExpiredDeals"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ABOUT_SETTINGS_TITLE
                                                        message:ABOUT_SETTINGS_MESSAGE
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

- (IBAction)donateLink:(id)sender {
    [Flurry logEvent:FLURRY_DONATE_BUTTON];
    
    NSURL *url = [NSURL URLWithString:ABOUT_DONATE_URL];
    [[UIApplication sharedApplication] openURL:url];
    
    url = nil;
}

- (IBAction)emailLink:(id)sender {
    [Flurry logEvent:FLURRY_EMAIL_BUTTON];
    [self openMail];
}

- (IBAction)rateLink:(id)sender {
    [Flurry logEvent:FLURRY_RATE_BUTTON];
    
    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && [SKStoreProductViewController class]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:@"Loading"];
        
        NSDictionary *appParameters = [NSDictionary dictionaryWithObject:PASSWIRD_APP_ID
                                                                  forKey:SKStoreProductParameterITunesItemIdentifier];
        
        SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
        [productViewController setDelegate:self];
        [productViewController loadProductWithParameters:appParameters
                                         completionBlock:^(BOOL result, NSError *error) {
                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             if (result) {
                                                 [self presentViewController:productViewController animated:YES completion:^{}];
                                             }
                                         }];
    } else {
        NSURL *url = [NSURL URLWithString:ABOUT_REVIEW_URL];
        [[UIApplication sharedApplication] openURL:url];
        
        url = nil;
    }
}

- (IBAction)githubLink:(id)sender {
    [Flurry logEvent:FLURRY_TWITTER_BUTTON];
    
    NSURL *url = [NSURL URLWithString:ABOUT_GITHUB_URL];
    [[UIApplication sharedApplication] openURL:url];
    
    url = nil;
}

- (IBAction)passwirdLink:(id)sender {
    [Flurry logEvent:FLURRY_PASSWIRD_BUTTON];
    
    NSURL *url = [NSURL URLWithString:ABOUT_PASSWIRD_URL];
    [[UIApplication sharedApplication] openURL:url];
    
    url = nil;
}

- (void)openMail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        [mailer setMailComposeDelegate:self];
        [mailer.navigationBar setTintColor:[UIColor darkGrayColor]];
        [mailer setToRecipients:[NSArray arrayWithObject:ABOUT_EMAIL_ADDRESS]];
        [mailer setSubject:EMAIL_SUBJECT_FEEDBACK];
        
        [self presentModalViewController:mailer animated:YES];
        
        mailer = nil;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:ERROR_MAIL_SUPPORT
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
    if (result) {
        //error occured sending mail
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:ERROR_MAIL_SEND
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    } else {
        // Remove the mail view
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Managing the StoreKit view

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Managing the scroll view

- (void)calculateAndSetScrollViewHeight {
    CGFloat scrollViewHeight = 0.0f;
    for (UIView *view in self.scrollView.subviews){
        if (scrollViewHeight < view.frame.origin.y + view.frame.size.height)
            scrollViewHeight = view.frame.origin.y + view.frame.size.height;
    }
    [self.scrollView setContentSize:CGSizeMake(0, scrollViewHeight)];
}

#pragma mark - View lifecycle

- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.legalLabel sizeToFit];
    [self calculateAndSetScrollViewHeight];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)viewWillLayoutSubviews {
    [self.legalLabel sizeToFit];
    [self calculateAndSetScrollViewHeight];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
        [self.legalLabel setTextAlignment:NSTextAlignmentLeft];
        [self.legalLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logPageView];
    
    //get expired deals setting from user defaults
    [self.expiredSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"showExpiredDeals"]];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setDoneButton:nil];
    [self setExpiredSwitch:nil];
    [self setLegalLabel:nil];
    [super viewDidUnload];
}

@end
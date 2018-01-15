//
//  AboutViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 5/30/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "SettingsViewController.h"

#import "StringTemplate.h"
#import "MBProgressHUD.h"

@implementation SettingsViewController

#pragma mark - Managing the buttons

- (IBAction)saveSettings:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.expiredSwitch.on forKey:@"showExpiredDeals"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:SETTINGS_TITLE
                                          message:SETTINGS_MESSAGE
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction cancelActionWithController:self]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)donateLink:(id)sender {
    NSURL *url = [NSURL URLWithString:SETTINGS_DONATE_URL];
    [[UIApplication sharedApplication] openURL:url];
    
    url = nil;
}

- (IBAction)emailLink:(id)sender {
    [self openMail];
}

- (IBAction)rateLink:(id)sender {
    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && [SKStoreProductViewController class]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Loading";
        hud.contentColor = [UIColor whiteColor];
        hud.bezelView.color = [UIColor pdHudColor];
        
        NSDictionary *appParameters = [NSDictionary dictionaryWithObject:PASSWIRD_APP_ID
                                                                  forKey:SKStoreProductParameterITunesItemIdentifier];
        
        SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
        [productViewController.navigationController.navigationBar setBarTintColor:[UIColor pdHeaderBarTintColor]];
        [productViewController.navigationController.navigationBar setTintColor:[UIColor pdHeaderTintColor]];
        [productViewController.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor pdTitleTextColor], NSForegroundColorAttributeName, nil]];
        
        [productViewController setDelegate:self];
        [productViewController loadProductWithParameters:appParameters
                                         completionBlock:^(BOOL result, NSError *error) {
                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             NSLog(result ? @"YES" : @"NO");
                                             if (result) {
                                                 NSLog(@"%@", productViewController);
                                                 [self presentViewController:productViewController animated:YES completion:nil];
                                             }
                                         }];
    } else {
        NSURL *url = [NSURL URLWithString:SETTINGS_REVIEW_URL];
        [[UIApplication sharedApplication] openURL:url];
        
        url = nil;
    }
}

- (IBAction)githubLink:(id)sender {
    NSURL *url = [NSURL URLWithString:SETTINGS_GITHUB_URL];
    [[UIApplication sharedApplication] openURL:url];
    
    url = nil;
}

- (IBAction)passwirdLink:(id)sender {
    NSURL *url = [NSURL URLWithString:PASSWIRD_URL];
    [[UIApplication sharedApplication] openURL:url];
    
    url = nil;
}

- (void)openMail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [MFMailComposeViewController initMFMailComposeViewControllerWithDelegate:self];
        
        [mailer setToRecipients:[NSArray arrayWithObject:SETTINGS_EMAIL_ADDRESS]];
        [mailer setSubject:EMAIL_SUBJECT_FEEDBACK];
        
        [self presentViewController:mailer animated:YES completion:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
        
        mailer = nil;
    } else {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:ERROR_TITLE
                                              message:ERROR_MAIL_SUPPORT
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction cancelActionWithController:self]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
    if (error) {
        //error occured sending mail
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:ERROR_TITLE
                                              message:ERROR_MAIL_SEND
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction cancelActionWithController:self]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        // Remove the mail view
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Managing the StoreKit view

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Managing the scroll view

- (void)calculateAndSetScrollViewHeight {
    CGFloat scrollViewHeight = 0.0f;
    for (UIView *view in self.scrollView.subviews) {
        if (scrollViewHeight < view.frame.origin.y + view.frame.size.height)
            scrollViewHeight = view.frame.origin.y + view.frame.size.height;
    }
    [self.scrollView setContentSize:CGSizeMake(0, scrollViewHeight)];
}

#pragma mark - View lifecycle

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self calculateAndSetScrollViewHeight];
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.appNameLabel setFont:[UIFont fontWithName:@"Arial Black" size:24.0]];
    [self.appNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.appNameLabel setTextColor:[UIColor pdTitleTextColor]];
    
    // THLabel specific properties
    [self.appNameLabel setStrokeColor:[UIColor pdTitleTextStrokeColor]];
	[self.appNameLabel setStrokeSize:2.5f];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //get expired deals setting from user defaults
    [self.expiredSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"showExpiredDeals"]];
    
    self.donateButton.layer.cornerRadius = 5;
    self.donateButton.layer.borderWidth = 1;
    self.donateButton.layer.borderColor = [UIColor pdHeaderTintColor].CGColor;
    
    self.feedbackButton.layer.cornerRadius = 5;
    self.feedbackButton.layer.borderWidth = 1;
    self.feedbackButton.layer.borderColor = [UIColor pdHeaderTintColor].CGColor;
    
    self.rateButton.layer.cornerRadius = 5;
    self.rateButton.layer.borderWidth = 1;
    self.rateButton.layer.borderColor = [UIColor pdHeaderTintColor].CGColor;
    
    self.githubButton.layer.cornerRadius = 5;
    self.githubButton.layer.borderWidth = 1;
    self.githubButton.layer.borderColor = [UIColor pdHeaderTintColor].CGColor;
    
    [self calculateAndSetScrollViewHeight];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setExpiredSwitch:nil];
    [self setAppNameLabel:nil];
    [self setFeedbackButton:nil];
    [self setRateButton:nil];
    [self setGithubButton:nil];
    [super viewDidUnload];
}

@end

//
//  WebViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "WebViewController.h"

#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

#import "Flurry.h"

#import "DealData.h"

@implementation WebViewController

#pragma mark - Managing the action sheet

- (void)openMail {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        [mailer setMailComposeDelegate:self];
        [mailer.navigationBar setTintColor:[UIColor darkGrayColor]];
        [mailer setSubject:@"Check out this deal on passwird.com"];

        NSString *emailBody = [NSString stringWithFormat:@"<html><body><strong>%@</strong><div>%@</div></body></html>", self.detailItem.headline, self.detailItem.body];
        [mailer setMessageBody:emailBody isHTML:YES];
        
        [self presentModalViewController:mailer animated:YES];
        
        mailer = nil;
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

- (void)copyURL {
    NSURL *currentURL = [self.webView.request URL];
    [[UIPasteboard generalPasteboard] setString: [currentURL absoluteString]];
}

- (void)openInSafari {
    NSURL *currentURL = [self.webView.request URL];
    [[UIApplication sharedApplication] openURL:currentURL];
}

- (void)tweetDeal {
    NSError *error;
    NSStringEncoding encoding;
    NSString *tweetFilePath = [[NSBundle mainBundle] pathForResource: @"Tweet" 
                                                              ofType: @"txt"];
    NSString *tweetString = [NSString stringWithContentsOfFile:tweetFilePath 
                                                  usedEncoding:&encoding 
                                                         error:&error];
    NSString *tweet = [NSString stringWithFormat:tweetString, self.detailItem.headline];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *share = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [share setInitialText:tweet];
            [self presentViewController:share animated:YES completion:nil];
            
            return;
        }
    }
    else {
#endif
        if ([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:tweet];            
            [self presentModalViewController:tweetSheet animated:YES];
            
            tweetSheet = nil;
            return;
        }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    }
#endif
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup in Settings."                                                          
                                                       delegate:self                                              
                                              cancelButtonTitle:@"OK"                                                   
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)postToFacebook {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    NSError *error;
    NSStringEncoding encoding;
    NSString *facebookFilePath = [[NSBundle mainBundle] pathForResource: @"Facebook"
                                                                 ofType: @"txt"];
    NSString *facebookString = [NSString stringWithContentsOfFile:facebookFilePath
                                                     usedEncoding:&encoding 
                                                            error:&error];
    NSString *facebook = [NSString stringWithFormat:facebookString, self.detailItem.headline];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *share = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [share setInitialText:facebook];
        
        [self presentViewController:share animated:YES completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't post to Facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup in Settings."                                                          
                                                           delegate:self                                              
                                                  cancelButtonTitle:@"OK"                                                   
                                                  otherButtonTitles:nil];
        [alertView show];
    }
#endif
}

- (IBAction)showActionSheet:(id)sender {
    [Flurry logEvent:@"Action Sheet"];
    
    if (self.actionSheet == nil) {
        UIActionSheet *sheet;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options" 
                                                delegate:self 
                                       cancelButtonTitle:@"Cancel" 
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Post to Facebook", @"Tweet Deal", @"Email Deal", @"Copy URL", @"Open in Safari", nil];
        }
        else {
            sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Tweet Deal", @"Email Deal", @"Copy URL", @"Open in Safari", nil];
        }
        
        [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [sheet showFromBarButtonItem:sender animated:YES];
        }
        else {
            [sheet showInView:self.view];
        }
        
        [self setActionSheet:sheet];
    } else {
        [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        switch (buttonIndex) {
            case 0:
                [Flurry logEvent:@"Post to Facebook"];
                [self postToFacebook];
                break;
            case 1:
                [Flurry logEvent:@"Tweet Deal"];
                [self tweetDeal];
                break;
            case 2:
                [Flurry logEvent:@"Email Deal"];
                [self openMail];
                break;
            case 3:
                [Flurry logEvent:@"Copy URL"];
                [self copyURL];
                break;
            case 4:
                [Flurry logEvent:@"Open in Safari"];
                [self openInSafari];
                break;
            default:
                //NSLog(@"Cancel Button Clicked");
                break;
        }
    }
    else {
        switch (buttonIndex) {
            case 0:
                [Flurry logEvent:@"Tweet Deal"];
                [self tweetDeal];
                break;
            case 1:
                [Flurry logEvent:@"Email Deal"];
                [self openMail];
                break;
            case 2:
                [Flurry logEvent:@"Copy URL"];
                [self copyURL];
                break;
            case 3:
                [Flurry logEvent:@"Open in Safari"];
                [self openInSafari];
                break;
            default:
                //NSLog(@"Cancel Button Clicked");
                break;
        }
    }
}

#pragma mark - Managing the web view

- (IBAction)goBack:(id)sender {
    [self.webView goBack]; 
}

- (IBAction)goForward:(id)sender {
    [self.webView goForward]; 
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    
    if ([self.webView canGoBack])
        [self.backButton setEnabled:YES];
    else
        [self.backButton setEnabled:NO];  
    
    if ([self.webView canGoForward])
        [self.forwardButton setEnabled:YES];   
    else
        [self.forwardButton setEnabled:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logPageView];
    
    NSLog(@"Pushed URL: %@", self.pushedURL);
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.pushedURL]];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setActionSheet:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
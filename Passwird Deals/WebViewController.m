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

#import "DealData.h"

@implementation WebViewController

@synthesize detailItem = _detailItem;
@synthesize pushedURL = _passedURL;
@synthesize webView = _webView;
@synthesize activityIndicator = _activityIndicator;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;

#pragma mark - Managing the action sheet

- (void)openMail {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"Check out this deal on passwird.com"];

        NSString *emailBody = [NSString stringWithFormat:@"<html><body><h3>%@</h3><div>%@</div></body></html>", self.detailItem.headline, self.detailItem.body];
        [mailer setMessageBody:emailBody isHTML:YES];
        
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
    
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
//        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
//            SLComposeViewController *share = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//            [share setInitialText:tweet];
//            [self presentViewController:share animated:YES completion:nil];
//            
//            return;
//        }
//    }
//    else {
//#endif
        if ([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:tweet];
            [self presentModalViewController:tweetSheet animated:YES];
            
            return;
        }
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
//    }
//#endif
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup in Settings."                                                          
                                                       delegate:self                                              
                                              cancelButtonTitle:@"OK"                                                   
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)postToFacebook {
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
//    NSError *error;
//    NSStringEncoding encoding;
//    NSString *facebookFilePath = [[NSBundle mainBundle] pathForResource: @"Facebook"
//                                                                 ofType: @"txt"];
//    NSString *facebookString = [NSString stringWithContentsOfFile:facebookFilePath
//                                                     usedEncoding:&encoding 
//                                                            error:&error];
//    NSString *facebook = [NSString stringWithFormat:facebookString, self.detailItem.headline];
//    
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
//        SLComposeViewController *share = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        
//        [share setInitialText:facebook];
//        
//        [self presentViewController:share animated:YES completion:nil];
//    }
//    else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
//                                                            message:@"You can't post to Facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup in Settings."                                                          
//                                                           delegate:self                                              
//                                                  cancelButtonTitle:@"OK"                                                   
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//#endif
}

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *sheet;
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
//        sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options" 
//                                            delegate:self 
//                                   cancelButtonTitle:@"Cancel" 
//                              destructiveButtonTitle:nil
//                                   otherButtonTitles:@"Post to Facebook", @"Tweet Deal", @"Email Deal", @"Open in Safari", nil];
//    }
//    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options"
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Tweet Deal", @"Email Deal", @"Open in Safari", nil];
//    }
    
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
//        switch (buttonIndex) {
//            case 0:
//                [self postToFacebook];
//                break;
//            case 1:
//                [self tweetDeal];
//                break;
//            case 2:
//                [self openMail];
//                break;
//            case 3:
//                [self openInSafari];
//                break;
//            default:
//                //NSLog(@"Cancel Button Clicked");
//                break;
//        }
//    }
//    else {
        switch (buttonIndex) {
            case 0:
                [self tweetDeal];
                break;
            case 1:
                [self openMail];
                break;
            case 2:
                [self openInSafari];
                break;
            default:
                //NSLog(@"Cancel Button Clicked");
                break;
        }
//    }
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

    NSLog(@"Pushed URL: %@", self.pushedURL);
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.pushedURL]];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [super viewDidUnload];
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
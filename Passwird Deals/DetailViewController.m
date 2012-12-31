//
//  DetailViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "DetailViewController.h"
#import "WebViewController.h"

#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

#import "Flurry.h"

#import "DealData.h"

@interface DetailViewController ()

- (void)configureView;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

#pragma mark - Managing the action sheet

- (void)openMail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        [mailer setMailComposeDelegate:self];
        [mailer.navigationBar setTintColor:[UIColor darkGrayColor]];
        [mailer setSubject:@"Check out this deal on passwird.com"];
        
        NSString *emailBody = [NSString stringWithFormat:@"<html><body><p>&nbsp;</p><strong>%@</strong><br/><br/><div>%@</div></body></html>", self.detailItem.headline, self.detailItem.body];
        [mailer setMessageBody:emailBody isHTML:YES];
        
        [self presentModalViewController:mailer animated:YES];
    }
    else {
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

- (void)tweetDeal {
    NSError *error;
    NSStringEncoding encoding;
    NSString *tweetFilePath = [[NSBundle mainBundle] pathForResource: @"Tweet" 
                                                              ofType: @"txt"];
    NSString *tweetString = [NSString stringWithContentsOfFile:tweetFilePath 
                                                  usedEncoding:&encoding 
                                                         error:&error];
    NSString *tweet = [NSString stringWithFormat:tweetString, self.detailItem.headline];

    if ([SLComposeViewController class]) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *share = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [share setInitialText:tweet];
            [self presentViewController:share animated:YES completion:nil];
            
            return;
        }
    } else {
        if ([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:tweet];
            
            [self presentModalViewController:tweetSheet animated:YES];
            
            tweetSheet = nil;
            return;
        }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup in Settings."                                                          
                                                       delegate:self                                              
                                              cancelButtonTitle:@"OK"                                                   
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)postToFacebook {
    if ([SLComposeViewController class]) {
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
    }
}

- (IBAction)showActionSheet:(id)sender {
    [Flurry logEvent:@"Action Sheet"];
 
    if (self.actionSheet == nil) {
        UIActionSheet *sheet;

        if ([SLComposeViewController class]) {
            sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options"
                                                delegate:self 
                                       cancelButtonTitle:@"Cancel" 
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Post to Facebook", @"Tweet Deal", @"Email Deal", nil];
        }
        else {
            sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options"
                                                delegate:self 
                                       cancelButtonTitle:@"Cancel" 
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Tweet Deal", @"Email Deal", nil];
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
    if ([SLComposeViewController class]) {
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
            default:
                //NSLog(@"Cancel Button Clicked");
                break;
        }
    }
}

#pragma mark - Managing the web view

- (BOOL)webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {    
    if( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        self.selectedURL = request.URL;
        [self performSegueWithIdentifier: @"Web" sender: self];
        return NO;
    } 
    return YES; 
}

- (void)loadDealIntoWebView {    
    // Update the user interface for the detail item.
    if (self.detailItem) {
        [self.navigationItem setTitle:@"Deal"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMMM d yyyy"];
        NSString *dateAsString = [formatter stringFromDate:[self.detailItem.datePosted dateByAddingTimeInterval:60*60*24*1]];
        
        NSError *error;
        NSStringEncoding encoding;
        NSString *dealHtmlFilePath = [[NSBundle mainBundle] pathForResource: @"Deal" 
                                                                     ofType: @"html"];
        NSString *dealHtmlString = [NSString stringWithContentsOfFile:dealHtmlFilePath 
                                                   usedEncoding:&encoding 
                                                          error:&error];
        
        NSString *html = [NSString stringWithFormat:dealHtmlString, 
                            dateAsString, 
                            self.detailItem.headline, 
                            (self.detailItem.isExpired ? @"(expired)" : @""), 
                            self.detailItem.imageURL, 
                            self.detailItem.body];
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        [self.webView loadHTMLString:html baseURL:baseURL];
    }
}

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass selected URL and deal to web controller
    WebViewController *webController = segue.destinationViewController;
    webController.pushedURL = self.selectedURL;
    webController.detailItem = self.detailItem;
}

- (void)configureView {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self loadDealIntoWebView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logPageView];
    
    [self configureView];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setShareButton:nil];
    [self setActionSheet:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Managing the split view

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

@end
//
//  WebViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "WebViewController.h"

#import "Constants.h"
#import "MBProgressHUD.h"
#import "Flurry.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation WebViewController

#pragma mark - Managing the action sheet

- (void)copyURL {
    NSURL *currentURL = [self.webView.request URL];
    [[UIPasteboard generalPasteboard] setString: [currentURL absoluteString]];
    
    //show copied HUD message for 2 seconds
    NSTimeInterval theTimeInterval = 2;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:@"URL Copied!"];
    [hud hide:YES afterDelay:theTimeInterval];
}

- (void)openInSafari {
    NSURL *currentURL = [self.webView.request URL];
    [[UIApplication sharedApplication] openURL:currentURL];
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
            [sheet showInView:self.parentViewController.view];
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
                [Flurry logEvent:FLURRY_FACEBOOK];
                [self postToFacebookWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            case 1:
                [Flurry logEvent:FLURRY_TWITTER];
                [self tweetDealWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            case 2:
                [Flurry logEvent:FLURRY_EMAIL];
                [self openMailWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            case 3:
                [Flurry logEvent:FLURRY_COPY];
                [self copyURL];
                break;
            case 4:
                [Flurry logEvent:FLURRY_SAFARI];
                [self openInSafari];
                break;
            default: //cancel button
                break;
        }
    }
    else {
        switch (buttonIndex) {
            case 0:
                [Flurry logEvent:FLURRY_TWITTER];
                [self tweetDealWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            case 1:
                [Flurry logEvent:FLURRY_EMAIL];
                [self openMailWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            case 2:
                [Flurry logEvent:FLURRY_COPY];
                [self copyURL];
                break;
            case 3:
                [Flurry logEvent:FLURRY_SAFARI];
                [self openInSafari];
                break;
            default: //cancel button
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

- (IBAction)refresh:(id)sender {
    [self.webView reload];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - View lifecycle

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logPageView];
    
    NSLog(@"Pushed URL: %@", self.pushedURL);
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.pushedURL]];
    
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 44.0, 0)];
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44.0, 0)];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setActionSheet:nil];
    [super viewDidUnload];
}

@end
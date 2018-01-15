//
//  WebViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "WebViewController.h"

#import "MBProgressHUD.h"

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
    [hud hideAnimated:YES afterDelay:theTimeInterval];
    hud.label.text = @"URL Copied!";
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.color = [UIColor pdHudColor];
}

- (void)openInSafari {
    NSURL *currentURL = [self.webView.request URL];
    [[UIApplication sharedApplication] openURL:currentURL];
}

- (IBAction)showActionSheet:(id)sender {
    if (self.actionSheet == nil) {
        UIActionSheet *sheet;
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options"
                                            delegate:self 
                                   cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Post to Facebook", @"Tweet Deal", @"Email Deal", @"Copy URL", @"Open in Safari", @"Report Expired", nil];
        
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
    switch (buttonIndex) {
        case 0:
            [super postToFacebookWithDeal:self.detailItem];
            break;
        case 1:
            [super tweetDealWithDeal:self.detailItem];
            break;
        case 2:
            [super openMailWithDeal:self.detailItem];
            break;
        case 3:
            [self copyURL];
            break;
        case 4:
            [self openInSafari];
            break;
        case 5:
            [super reportExpiredWithDeal:self.detailItem];
            break;
        default: //cancel button
            break;
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

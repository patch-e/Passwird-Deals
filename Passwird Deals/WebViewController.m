//
//  WebViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "WebViewController.h"

#import <Twitter/Twitter.h>

#import "DealData.h"

@implementation WebViewController

@synthesize detailItem = _detailItem;
@synthesize pushedURL = _passedURL;
@synthesize webView = _webView;
@synthesize activityIndicator = _activityIndicator;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Managing the action sheet

- (void)openInSafari {
    NSURL *currentURL = [self.webView.request URL];
    [[UIApplication sharedApplication] openURL:currentURL];
}

- (void)tweetDeal {
    if ([TWTweetComposeViewController canSendTweet])
    {
        NSError *error;
        NSStringEncoding encoding;
        NSString *tweetFilePath = [[NSBundle mainBundle] pathForResource: @"Tweet" 
                                                                  ofType: @"txt"];
        NSString *tweetString = [NSString stringWithContentsOfFile:tweetFilePath 
                                                      usedEncoding:&encoding 
                                                             error:&error];
        NSString *tweet = [NSString stringWithFormat:tweetString, self.detailItem.headline];
        
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:tweet];
        [self presentModalViewController:tweetSheet animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup in Settings." 
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *sheet;
    

    sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tweet Deal", @"Open in Safari", nil];
    [sheet setTag:1];
    
    [sheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (buttonIndex) {
        case 0:
            [self tweetDeal];
            break;
        case 1:
            [self openInSafari];
            break;
        default:
            //NSLog(@"Cancel Button Clicked");
            break;
    }
}

#pragma mark - Managing the web view

-(IBAction)goBack:(id)sender {
    [self.webView goBack]; 
}

-(IBAction)goForward:(id)sender {
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
	// Do any additional setup after loading the view, typically from a nib.
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
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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

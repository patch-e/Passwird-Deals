//
//  DetailViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "DetailViewController.h"

#import <Twitter/Twitter.h>

#import "DealData.h"
#import "MBProgressHUD.h"

@interface DetailViewController ()

- (void)configureView;

@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize webView = _webView;
@synthesize activityIndicator = _activityIndicator;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

#pragma mark - Managing the web view

-(IBAction)goBack:(id)sender {
    [self.webView goBack]; 
}

-(IBAction)goForward:(id)sender {
    [self.webView goForward]; 
}

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
        UIAlertView *alertView =
            [[UIAlertView alloc]
             initWithTitle:@"Sorry"
             message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup in Settings."                                                          
             delegate:self                                              
             cancelButtonTitle:@"OK"                                                   
             otherButtonTitles:nil];
        [alertView show];
    }
}

-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *sheet;
    
    if ( [[[self.webView.request URL] absoluteString] isEqualToString:@"about:blank"] ) {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tweet Deal", nil];
        [sheet setTag:0];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Deal Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Back to Deal", @"Tweet Deal", @"Open in Safari", nil];
        [sheet setTag:1];
    }
    
    [sheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(actionSheet.tag) {
        case 0:
            switch (buttonIndex) {
                case 0:
                    [self tweetDeal];
                    break;
                default:
                    //NSLog(@"Cancel Button Clicked");
                    break;
            }
            break;
        case 1:
            switch (buttonIndex) {
                case 0:
                    [self loadDealIntoWebView];                    
                    break;
                case 1:
                    [self tweetDeal];
                    break;
                case 2:
                    [self openInSafari];
                    break;
                default:
                    //NSLog(@"Cancel Button Clicked");
                    break;
            }
            break;
    }
}

-(void)loadDealIntoWebView {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM d yyyy"];
    NSString *dateAsString = [formatter stringFromDate:[self.detailItem.datePosted dateByAddingTimeInterval:60*60*24*1]];
    
    // Update the user interface for the detail item.
    if (self.detailItem) {
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

        [self.webView loadHTMLString:html baseURL:nil];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    
    if ( [[[self.webView.request URL] absoluteString] isEqualToString:@"about:blank"] ) {
        [self.backButton setEnabled:NO];
        [self.forwardButton setEnabled:NO];
    }
    else {
        if ([self.webView canGoBack])
            [self.backButton setEnabled:YES];
        else
            [self.backButton setEnabled:NO];  
        
        if ([self.webView canGoForward])
            [self.forwardButton setEnabled:YES];   
        else
            [self.forwardButton setEnabled:NO];      
    }
}

#pragma mark - View lifecycle

- (void)configureView
{
    [self loadDealIntoWebView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
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

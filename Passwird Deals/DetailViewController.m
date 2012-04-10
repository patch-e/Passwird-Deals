//
//  DetailViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "DetailViewController.h"

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
@synthesize safariButton = _safariButton;
@synthesize dealButton = _dealButton;

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

-(IBAction)loadDeal:(id)sender {
    [self loadDealIntoWebView];
}

- (IBAction)openInSafari:(id)sender {
    NSURL *currentURL = [self.webView.request URL];
    [[UIApplication sharedApplication] openURL:currentURL];
}

-(void)loadDealIntoWebView {
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    NSString *dateString = [dateFormatter stringFromDate:self.detailItem.datePosted];
    
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        NSString *html = [NSString stringWithFormat:
                          @"<html>"
                          "<head>"
                          "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\" />"
                          "<style type=\"text/css\">"
                          "body {"
                          "background-color: #ababab;"
                          "font-family: Helvetica;"
                          "padding-bottom: 5px;"
                          "}"
                          
                          "a {"
                          "color: #004875;"
                          "-webkit-tap-highlight-color: rgba(255, 0, 0, 0.5);"
                          "}"
                          
                          ".headline {"
                          "margin: 0px;"      
                          "padding: 0px 10px;"
                          "font-size: 18px;"
                          "color: #000;"
                          "text-overflow: inherit;"
                          "white-space: normal;"
                          "overflow: visible;"
                          "}"
                          
                          ".body {"
                          "background-color: #fff;"
                          "border: 1px solid #ADAAAD;"
                          "margin: 10px 5px 10px 5px;"
                          "padding: 8px;"
                          "font-size: 16px;"
                          "-webkit-border-radius: 8px;"
                          "-webkit-box-shadow: 5px 5px 5px rgba(0, 0, 0, 0.5);"
                          "}"
                          
                          ".date { float: right; margin-left: 5px; }"
                          ".expired { color: #f90602; }"
                          ".center { text-align: center; }"

                          "</style>"
                          "</head>"
                          "<body>"
                          "<small class=\"date\">%@</small>"
                          "<h1 class=\"headline\">%@ <span class=\"expired\">%@</span></h1>"
                          "<div class=\"body center\"><img src=\"%@\"/></div>"
                          "<div class=\"body\">%@</div>"
                          "</body>"
                          "</html>", dateString, self.detailItem.headline, (self.detailItem.isExpired ? @"(expired)" : @""), self.detailItem.imageURL, self.detailItem.body];
        
        [self.webView loadHTMLString:html baseURL:nil];
    }
}

#pragma mark - View lifecycle

- (void)configureView
{
    [self loadDealIntoWebView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    
    if ( [[[self.webView.request URL] absoluteString] isEqualToString:@"about:blank"] ) {
        self.dealButton.enabled = NO; 
        self.safariButton.enabled = NO;    
        self.backButton.enabled = NO;
        self.forwardButton.enabled = NO;
    }
    else {
        self.dealButton.enabled = YES; 
        self.safariButton.enabled = YES;
        
        if ([self.webView canGoBack])
            self.backButton.enabled = YES;
        else
            self.backButton.enabled = NO;  
        
        if ([self.webView canGoForward])
            self.forwardButton.enabled = YES;   
        else
            self.forwardButton.enabled = NO;      
    }
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
    [self setSafariButton:nil];
    [self setDealButton:nil];
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

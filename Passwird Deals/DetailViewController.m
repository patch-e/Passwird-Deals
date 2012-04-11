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
    NSString *dateAsString = [dateFormatter stringFromDate:self.detailItem.datePosted];
    
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
        [self.dealButton setEnabled:NO]; 
        [self.safariButton setEnabled:NO];    
        [self.backButton setEnabled:NO];
        [self.forwardButton setEnabled:NO];
    }
    else {
        [self.dealButton setEnabled:YES]; 
        [self.safariButton setEnabled:YES];
        
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

//
//  DetailViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "DetailViewController.h"

#import "DealData.h"

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

#pragma mark - View lifecycle

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSString *html = [NSString stringWithFormat:
                          @"<html>"
                          "<head>"
                          "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\" />"
                          "<style type=\"text/css\">"
                          "body {"
                          "background-color: #C5CCD3;"
                          "font-family: Helvetica;"
                          "}"
                          ".headline {"
                          "margin: 0px;"      
                          "padding: 0px 15px;"
                          "font-size: 18px;"
                          "color: #4C566C;"
                          "text-shadow: white 0px 1px 0px;"      
                          "text-overflow: inherit;"
                          "white-space: normal;"
                          "overflow: visible;"
                          
                          "}"
                          ".body {"
                          "background-color: white;"
                          "border: 1px solid #ADAAAD;"
                          "margin: 7px 9px 60px 9px;"
                          "padding: 8px;"
                          "font-size: 16px;"
                          "-webkit-border-radius: 8px;"
                          "-webkit-box-shadow: 5px 5px 5px rgba(0, 0, 0, 0.5);"
                          "}"
                          ".expired {"
                          "color: #ff0000;"
                          "}"
                          "</style>"
                          "</head>"
                          "<body>"
                          "<h1 class=\"headline\">%@ <span class=\"expired\">%@</span></h1>"
                          "<div class=\"body\">%@</div>"
                          "</body>"
                          "</html>", self.detailItem.headline, (self.detailItem.isExpired ? @"(expired)" : @""), self.detailItem.body];
        
        [self.webView loadHTMLString:html baseURL:nil];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    
    if ([self.webView canGoBack]) {
        self.backButton.enabled = YES;
    }
    else {
        self.backButton.enabled = NO;        
    }
    
    if ([self.webView canGoForward]) {
        self.forwardButton.enabled = YES;
    }
    else {
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

//
//  DetailViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "DetailViewController.h"

#import "MBProgressHUD.h"
#import "GTMNSString+HTML.h"
#import "AppleSafariActivity.h"
#import "GoogleChromeActivity.h"

@implementation DetailViewController

#pragma mark - Managing the asynchronous data download

- (void)createConnectionWithHUD:(BOOL)showHUD {
    if ( showHUD ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Loading";
        hud.contentColor = [UIColor whiteColor];
        hud.bezelView.color = [UIColor pdHudColor];
    }
    
    //build the connection for async data downloading, 20 second timeout
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/passwirddeal?id=%lu", PASSWIRD_API_URL, (unsigned long)self.detailId]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    //on good connection, fill responseData, delegate will fire connection:didReceiveData:
    if ( connection ) {
        [self setResponseData:[[NSMutableData alloc] init]];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"connection failed");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"connection error");

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:ERROR_TITLE
                                          message:ERROR_MESSAGE
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction cancelActionWithController:self]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"connection success");
    
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                options:kNilOptions
                                                  error:&error];
    
    NSDictionary *dealsDictionary = result;
    NSArray *dealsArray = [dealsDictionary objectForKey:@"deals"];
        
    // Loop through the array of JSON deals and create Deal objects added to a mutable array
    for (id aDeal in dealsArray) {
        NSString *jsonDateString = [aDeal objectForKey:@"datePosted"];
        NSInteger dateOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
        NSDate *datePosted = [[NSDate dateWithTimeIntervalSince1970:[[jsonDateString substringWithRange:NSMakeRange(6, 10)] intValue]]dateByAddingTimeInterval:dateOffset];
        
        DealData *deal =
        [[DealData alloc] initWithHeadline:[[aDeal valueForKey:@"headline"] gtm_stringByUnescapingFromHTML]
                                      body:[aDeal valueForKey:@"body"]
                                  imageURL:[NSURL URLWithString:[aDeal objectForKey:@"image"]]
                                 isExpired:[[aDeal valueForKey:@"isExpired"] boolValue]
                                datePosted:datePosted
                                    dealId:[aDeal valueForKey:@"id"]
                                      slug:[aDeal valueForKey:@"slug"]
                                 sHeadline:[aDeal valueForKey:@"sHeadline"]];
        
        [self setDetailItem:deal];
        
        //clean up
        jsonDateString = nil;
        datePosted = nil;
        deal = nil;
    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //hide view via alpha, and animate in over 1 sec
        [self.wkWebView setAlpha:0];
        [UIView animateWithDuration:0.8 animations:^() {
            [self.wkWebView setAlpha:1];
        }];
        //enable the action buttons
        [self.shareButton setEnabled:YES];
        [self.reportButton setEnabled:YES];
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    dealsDictionary = nil;
    dealsArray = nil;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        //update the view
        [self configureView];
    }
}

#pragma mark - Managing the activity controller

- (IBAction)showActivity:(id)sender {
    //load custom activities
    AppleSafariActivity *safariActivity = [[AppleSafariActivity alloc] init];
    GoogleChromeActivity *chromeActivity = [[GoogleChromeActivity alloc] init];
    
    NSArray *activityItems = @[[self.detailItem getURL]];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:activityItems
                                                        applicationActivities:@[safariActivity, chromeActivity]];
    
    [activityViewController.popoverPresentationController setBarButtonItem:sender];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)reportExpired:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Report Expired?"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self reportExpiredWithDeal:self.detailItem];
                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [alertController.popoverPresentationController setBarButtonItem:sender];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Managing the web view

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == UIWebViewNavigationTypeLinkClicked) {
        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:navigationAction.request.URL];
        [svc setDelegate:self];
        [svc setPreferredBarTintColor:[UIColor pdHeaderBarTintColor]];
        [svc setPreferredControlTintColor:[UIColor pdHeaderTintColor]];
        
        [self presentViewController:svc animated:YES completion:nil];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)loadDealIntoWebView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        [self.navigationItem setTitle:@"deal"];
        [self.navigationController.navigationBar layoutSubviews];
        
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

        UIFont *headline = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        UIFont *date = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        UIFont *expired = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        UIFont *body = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        
        NSString *html = [NSString stringWithFormat:dealHtmlString,
                          [NSString stringWithFormat: @"%.0f", headline.pointSize+5],
                          [NSString stringWithFormat: @"%.0f", date.pointSize],
                          [NSString stringWithFormat: @"%.0f", expired.pointSize],
                          [NSString stringWithFormat: @"%.0f", body.pointSize],
                          dateAsString,
                          self.detailItem.headline,
                          (self.detailItem.isExpired ? @"expired" : @"hide"),
                          self.detailItem.imageURL,
                          self.detailItem.body];
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        [self.wkWebView loadHTMLString:html baseURL:baseURL];
    }
}

#pragma mark - View lifecycle

- (void)configureView {
    [self loadDealIntoWebView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.detailItem == nil && self.detailId > 0) {
        [self createConnectionWithHUD:YES];
    } else {
        [self configureView];
    }
    
    [self.wkWebView setNavigationDelegate:self];
    [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
}

@end

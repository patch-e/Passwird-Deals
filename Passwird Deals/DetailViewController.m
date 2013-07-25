//
//  DetailViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "DetailViewController.h"
#import "WebViewController.h"

#import "Constants.h"
#import "MBProgressHUD.h"
#import "GTMNSString+HTML.h"
#import "Flurry.h"

#import <Twitter/Twitter.h>

@implementation DetailViewController

#pragma mark - Managing the asynchronous data download

- (void)createConnectionWithHUD:(BOOL)showHUD {
    if ( showHUD ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:@"Loading"];
    }
    
    //build the connection for async data downloading, 20 second timeout
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/passwirddeal?id=%d", PASSWIRD_API_URL, self.detailId]];
    
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                        message:ERROR_MESSAGE
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
    
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
                                datePosted:datePosted];
        
        [self setDetailItem:deal];
        
        //clean up
        jsonDateString = nil;
        datePosted = nil;
        deal = nil;
    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //hide view via alpha, and animate in over 1 sec
        [self.webView setAlpha:0];
        [UIView animateWithDuration:0.8 animations:^() {
            [self.webView setAlpha:1];
        }];
        //enable the share button if it isn't already
        [self.shareButton setEnabled:YES];
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

#pragma mark - Managing the action sheet

- (IBAction)showActionSheet:(id)sender {
    [Flurry logEvent:FLURRY_ACTION];
 
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
                [super postToFacebookWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            case 1:
                [Flurry logEvent:FLURRY_TWITTER];
                [super tweetDealWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            case 2:
                [Flurry logEvent:FLURRY_EMAIL];
                [super openMailWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            default: //cancel button
                break;
        }
    }
    else {
        switch (buttonIndex) {
            case 0:
                [Flurry logEvent:FLURRY_TWITTER];
                [super tweetDealWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            case 1:
                [Flurry logEvent:FLURRY_EMAIL];
                [super openMailWithHeadline:self.detailItem.headline body:self.detailItem.body];
                break;
            default: //cancel button
                break;
        }
    }
}

#pragma mark - Managing the web view

- (BOOL)webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {    
    if( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [self setSelectedURL:request.URL];
        [self performSegueWithIdentifier:@"Web" sender:self];
        return NO;
    } 
    return YES; 
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

#pragma mark - Managing the split view

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass selected URL and deal to web controller
    WebViewController *webController = segue.destinationViewController;
    [webController setPushedURL:self.selectedURL];
    [webController setDetailItem:self.detailItem];
}

- (void)configureView {
    [self loadDealIntoWebView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logPageView];
    
    if (self.detailItem == nil && self.detailId > 0) {
        [self createConnectionWithHUD:YES];
    } else {
        [self configureView];
    }
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setShareButton:nil];
    [self setActionSheet:nil];
    [super viewDidUnload];
}

@end
//
//  PDViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "PDViewController.h"

#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "StringTemplate.h"

@import MessageUI;

@implementation PDViewController

#pragma mark - Managing the action sheet

- (void)openMailWithDeal:(DealData *)deal {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [MFMailComposeViewController initMFMailComposeViewControllerWithDelegate:self];
        [mailer setSubject:EMAIL_SUBJECT_SHARE];
        
        StringTemplate *emailTemplate = [StringTemplate templateWithName:@"Email.txt"];
        [emailTemplate setString:[deal getURL].absoluteString forKey:@"url"];
        [emailTemplate setString:deal.headline forKey:@"headline"];
        [emailTemplate setString:deal.body forKey:@"body"];
        [mailer setMessageBody:emailTemplate.result isHTML:YES];
        
        [self presentViewController:mailer animated:YES completion:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
        
        mailer = nil;
    } else {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:ERROR_TITLE
                                              message:ERROR_MAIL_SUPPORT
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction cancelActionWithController:self]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    if (error) {
        //error occured sending mail
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:ERROR_TITLE
                                              message:ERROR_MAIL_SEND
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction cancelActionWithController:self]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        // Remove the mail view
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)reportExpiredWithDeal:(DealData *)deal {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *postUrl = [NSString stringWithFormat:PASSWIRD_URL_REPORT_EXPIRED, deal.dealId];
    
    NSLog(@"Posting to '%@'", postUrl);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:postUrl parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSLog(@"Request Successful, response '%@'", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        //show thank you HUD message for 2 seconds
        NSTimeInterval theTimeInterval = 2;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setMode:MBProgressHUDModeText];
        [hud hideAnimated:YES afterDelay:theTimeInterval];
        hud.label.text = @"Thanks!";
        hud.contentColor = [UIColor whiteColor];
        hud.bezelView.color = [UIColor pdHudColor];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSLog(@"Request Error, response '%ld'", (long)error.code);
        NSLog(@"Request Error, response.debugDescription '%@'", error.debugDescription);
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Misc

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end

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
#import "Flurry.h"
#import "StringTemplate.h"

#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

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
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
        
        mailer = nil;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:ERROR_MAIL_SUPPORT
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    if (error) {
        //error occured sending mail
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:ERROR_MAIL_SEND
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    } else {
        // Remove the mail view
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tweetDealWithDeal:(DealData *)deal {
    StringTemplate *tweetTemplate = [StringTemplate templateWithName:@"Tweet.txt"];
    [tweetTemplate setString:[deal getURL].absoluteString forKey:@"url"];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *share = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [share setInitialText:tweetTemplate.result];
        [self presentViewController:share animated:YES completion:nil];
        
        return;
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                        message:ERROR_TWITTER
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)postToFacebookWithDeal:(DealData *)deal {
    StringTemplate *facebookTemplate = [StringTemplate templateWithName:@"Facebook.txt"];
    [facebookTemplate setString:[deal getURL].absoluteString forKey:@"url"];
    [facebookTemplate setString:deal.sHeadline forKey:@"sHeadline"];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *share = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [share setInitialText:facebookTemplate.result];
        
        [self presentViewController:share animated:YES completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:ERROR_FACEBOOK
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)markDeadWithDeal:(DealData *)deal {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:PASSWIRD_API_URL]];

    [httpClient postPath:[NSString stringWithFormat:PASSWIRD_URL_MARK_DEAD, deal.dealId]
              parameters:nil
                 success:^(AFHTTPRequestOperation *loginOperation, id responseObject) {
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     
//                     NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                     NSLog(@"Request Successful, response '%@'", responseStr);
                     
                     //show thank you HUD message for 2 seconds
                     NSTimeInterval theTimeInterval = 2;
                     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     [hud setColor:[UIColor pdHudColor]];
                     [hud setMode:MBProgressHUDModeText];
                     [hud setLabelText:@"Thanks!"];
                     [hud hide:YES afterDelay:theTimeInterval];
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     
//                     NSLog(@"Request Error, response '%d'", error.code);
                 }];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
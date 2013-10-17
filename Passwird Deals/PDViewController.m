//
//  PDViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "PDViewController.h"

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
        [emailTemplate setString:PASSWIRD_URL forKey:@"baseUrl"];
        [emailTemplate setString:deal.dealId forKey:@"dealId"];
        [emailTemplate setString:deal.slug forKey:@"slug"];
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
    [tweetTemplate setString:PASSWIRD_URL forKey:@"baseUrl"];
    [tweetTemplate setString:deal.dealId forKey:@"dealId"];
    [tweetTemplate setString:deal.slug forKey:@"slug"];
    
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
    if ([SLComposeViewController class]) {
        StringTemplate *facebookTemplate = [StringTemplate templateWithName:@"Facebook.txt"];
        [facebookTemplate setString:PASSWIRD_URL forKey:@"baseUrl"];
        [facebookTemplate setString:deal.dealId forKey:@"dealId"];
        [facebookTemplate setString:deal.slug forKey:@"slug"];
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
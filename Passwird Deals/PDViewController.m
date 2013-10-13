//
//  PDViewController.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "PDViewController.h"

#import "Constants.h"
#import "Flurry.h"

#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

@implementation PDViewController

#pragma mark - Managing the action sheet

- (void)openMailWithHeadline:(NSString *)headline body:(NSString *)body {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        [mailer setMailComposeDelegate:self];
//        [mailer.navigationBar setTintColor:[UIColor darkGrayColor]];
        [mailer setSubject:EMAIL_SUBJECT_SHARE];
        
        NSString *emailBody = [NSString stringWithFormat:EMAIL_BODY_SHARE, headline, body];
        [mailer setMessageBody:emailBody isHTML:YES];
        
        [self presentViewController:mailer animated:YES completion:nil];
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

- (void)tweetDealWithHeadline:(NSString *)headline body:(NSString *)body {
    NSError *error;
    NSStringEncoding encoding;
    NSString *tweetFilePath = [[NSBundle mainBundle] pathForResource: @"Tweet"
                                                              ofType: @"txt"];
    NSString *tweetString = [NSString stringWithContentsOfFile:tweetFilePath
                                                  usedEncoding:&encoding
                                                         error:&error];
    NSString *tweet = [NSString stringWithFormat:tweetString, headline];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *share = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [share setInitialText:tweet];
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

- (void)postToFacebookWithHeadline:(NSString *)headline body:(NSString *)body {
    if ([SLComposeViewController class]) {
        NSError *error;
        NSStringEncoding encoding;
        NSString *facebookFilePath = [[NSBundle mainBundle] pathForResource: @"Facebook"
                                                                     ofType: @"txt"];
        NSString *facebookString = [NSString stringWithContentsOfFile:facebookFilePath
                                                         usedEncoding:&encoding
                                                                error:&error];
        NSString *facebook = [NSString stringWithFormat:facebookString, headline];
        
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *share = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [share setInitialText:facebook];
            
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
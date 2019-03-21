//
//  Constants.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/21/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - General

NSString *const PASSWIRD_APP_ID = @"517165629";
NSString *const PASSWIRD_API_URL = @"http://api.mccrager.com";
NSString *const PASSWIRD_URL = @"http://www.passwird.com";
NSString *const PASSWIRD_URL_REPORT_EXPIRED = @"http://www.passwird.com/deals/votedown/%@";

#pragma mark - Settings

NSString *const SETTINGS_EMAIL_ADDRESS = @"p.crager@gmail.com";

NSString *const SETTINGS_GITHUB_URL = @"https://github.com/patch-e/Passwird-Deals";
NSString *const SETTINGS_REVIEW_URL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=517165629";
NSString *const SETTINGS_TITLE = @"Settings";
NSString *const SETTINGS_MESSAGE = @"Expired deals setting will be applied during the next refresh or search.";

#pragma mark - Email

NSString *const EMAIL_SUBJECT_SHARE = @"Check out this deal on passwird.com";
NSString *const EMAIL_SUBJECT_FEEDBACK = @"Passwird Deals app feedback";

#pragma mark - Errors

NSString *const ERROR_TITLE = @"Sorry";
NSString *const ERROR_MESSAGE = @"Could not connect to the remote server at this time.";
NSString *const ERROR_MAIL_SUPPORT = @"Your device doesn't support composing of emails.";
NSString *const ERROR_MAIL_SEND = @"An error occured sending mail.";
NSString *const ERROR_TWITTER = @"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup in Settings.";
NSString *const ERROR_FACEBOOK = @"You can't post to Facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup in Settings.";

@end

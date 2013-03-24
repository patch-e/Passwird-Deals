//
//  Constants.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/21/13.
//
//

#import "Constants.h"

@implementation Constants

#pragma mark General

NSString *const PASSWIRD_APP_ID = @"517165629";
NSString *const PASSWIRD_API_URL = @"http://api.mccrager.com";

#pragma mark About

NSString *const ABOUT_EMAIL_ADDRESS = @"p.crager@gmail.com";
NSString *const ABOUT_PASSWIRD_URL = @"http://passwird.com";
NSString *const ABOUT_GITHUB_URL = @"https://github.com/patch-e/Passwird-Deals";
NSString *const ABOUT_REVIEW_URL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=517165629";
NSString *const ABOUT_DONATE_URL = @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=p.crager@gmail.com&item_name=Passwird+Deals+app+donation&currency_code=USD";
NSString *const ABOUT_SETTINGS_TITLE = @"Settings";
NSString *const ABOUT_SETTINGS_MESSAGE = @"Expired deals setting will be applied during the next refresh or search.";

#pragma mark Email

NSString *const EMAIL_SUBJECT_SHARE = @"Check out this deal on passwird.com";
NSString *const EMAIL_BODY_SHARE = @"<html><body><p>&nbsp;</p><strong>%@</strong><br/><br/><div>%@</div></body></html>";
NSString *const EMAIL_SUBJECT_FEEDBACK = @"Passwird Deals app feedback";

#pragma mark Flurry Actions

NSString *const FLURRY_REFRESH = @"Pull to Refresh";
NSString *const FLURRY_ACTION = @"Action Sheet";
NSString *const FLURRY_FACEBOOK = @"Post to Facebook";
NSString *const FLURRY_TWITTER = @"Tweet Deal";
NSString *const FLURRY_EMAIL = @"Email Deal";
NSString *const FLURRY_COPY = @"Copy URL";
NSString *const FLURRY_SAFARI = @"Open in Safari";
NSString *const FLURRY_SAVE = @"Save Settings";
NSString *const FLURRY_DONATE_BUTTON = @"Donate Button";
NSString *const FLURRY_EMAIL_BUTTON = @"Email Button";
NSString *const FLURRY_RATE_BUTTON = @"Rate Button";
NSString *const FLURRY_TWITTER_BUTTON = @"Twitter Button";
NSString *const FLURRY_PASSWIRD_BUTTON = @"Passwird Button";

#pragma mark Errors

NSString *const ERROR_TITLE = @"Sorry";
NSString *const ERROR_MESSAGE = @"Could not connect to the remote server at this time.";
NSString *const ERROR_MAIL_SUPPORT = @"Your device doesn't support composing of emails.";
NSString *const ERROR_MAIL_SEND = @"An error occured sending mail.";
NSString *const ERROR_TWITTER = @"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup in Settings.";
NSString *const ERROR_FACEBOOK = @"You can't post to Facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup in Settings.";

@end
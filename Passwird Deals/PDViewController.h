//
//  PDViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "DealData.h"

#import <MessageUI/MessageUI.h>

@interface PDViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

- (void)openMailWithDeal:(DealData *)deal;
- (void)tweetDealWithDeal:(DealData *)deal;
- (void)postToFacebookWithDeal:(DealData *)deal;
- (void)markDeadWithDeal:(DealData *)deal;

@end
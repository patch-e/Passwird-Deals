//
//  PDViewController.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "DealData.h"

@import MessageUI;

@interface PDViewController : UIViewController <UIActionSheetDelegate>

- (void)reportExpiredWithDeal:(DealData *)deal;

@end

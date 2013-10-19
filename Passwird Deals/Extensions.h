//
//  Extensions.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface UIImage(Extension)

- (UIImage *) makeThumbnailOfSize:(CGSize)size;

@end

@interface NSDictionary(Extension)

+ (NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
- (NSData*)toJSON;

@end

@interface NSString(Extension)

- (NSString *)urlEncode;
+ (NSString *)stringFromResource:(NSString*)resourceName;

@end

@interface UIColor(Extension)

+ (UIColor *)pdHeaderTintColor;
+ (UIColor *)pdHeaderBarTintColor;
+ (UIColor *)pdTitleTextColor;
+ (UIColor *)pdSectionBackgroundColor;
+ (UIColor *)pdSectionTextColor;
+ (UIColor *)pdHudColor;

@end

@interface MFMailComposeViewController(Extension)

+ (MFMailComposeViewController *)initMFMailComposeViewControllerWithDelegate:(id)delegate;

@end
//
//  Extensions.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

@interface UIImage(Extension)

- (UIImage *) makeThumbnailOfSize:(CGSize)size;

@end

@interface NSDictionary(Extension)

+ (NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
- (NSData*)toJSON;

@end

@interface NSString(Extension)

- (NSString *)urlEncode;

@end

@interface UIColor(Extension)

//+ (UIColor *)pdRedColor;
//+ (UIColor *)pdBlueColor;
//+ (UIColor *)pdLightGrayColor;
//+ (UIColor *)pdDarkGrayColor;
//+ (UIColor *)pdOffWhiteColor;

+ (UIColor *)pdHeaderTintColor;
+ (UIColor *)pdHeaderBarTintColor;
+ (UIColor *)pdTitleTextColor;
+ (UIColor *)pdSectionBackgroundColor;
+ (UIColor *)pdSectionTextColor;

@end
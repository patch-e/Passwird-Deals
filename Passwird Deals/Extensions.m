//
//  Extensions.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "Extensions.h"

@implementation UIImage(Extension)

- (UIImage *)makeThumbnailOfSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);  
    
    // draw scaled image into thumbnail context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();        
    
    // pop the context
    UIGraphicsEndImageContext();
    
    if ( newThumbnail == nil ) 
        NSLog(@"could not scale image");
    
    return newThumbnail;
}

@end

@implementation NSDictionary(Extension)

+ (NSDictionary *)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlAddress]];
    
    if (data == nil) {
        return nil;
    }
        
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data 
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    
    return result;
}

- (NSData *)toJSON {
    NSError *error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self 
                                                options:kNilOptions 
                                                  error:&error];
    if (error != nil) return nil;
    
    return result;    
}

@end

@implementation NSString(Extension)

- (NSString *)urlEncode {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge_retained CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 );
}

@end

@implementation UIColor (colors)

//+ (UIColor *)pdRedColor {
//    static UIColor *color = nil;
//    if (!color)
//        color = [[UIColor alloc] initWithRed:(202.0/255.0) green:(13.0/255.0) blue:(38.0/255.0) alpha:0.90];
//    return color;
//}
//
//+ (UIColor *)pdBlueColor {
//    static UIColor *color = nil;
//    if (!color)
//        color = [[UIColor alloc] initWithRed:(0.0/255.0) green:(72.0/255.0) blue:(117.0/255.0) alpha:1.0];
//    return color;
//}
//
//+ (UIColor *)pdLightGrayColor {
//    static UIColor *color = nil;
//    if (!color)
//        color = [[UIColor alloc] initWithRed:(170.0/255.0) green:(170.0/255.0) blue:(170.0/255.0) alpha:1.0];
//    return color;
//}
//
//+ (UIColor *)pdDarkGrayColor {
//    static UIColor *color = nil;
//    if (!color)
//        color = [[UIColor alloc] initWithRed:(85.0/255.0) green:(85.0/255.0) blue:(85.0/255.0) alpha:1.0];
//    return color;
//}
//
//+ (UIColor *)pdOffWhiteColor {
//    static UIColor *color = nil;
//    if (!color)
//        color = [[UIColor alloc] initWithRed:(230.0/255.0) green:(230.0/255.0) blue:(230.0/255.0) alpha:1.0];
//    return color;
//}

+ (UIColor *)pdHeaderTintColor {
    static UIColor *color = nil;
    if (!color)
        color = [[UIColor alloc] initWithRed:(174.0/255.0) green:(19.0/255.0) blue:(18.0/255.0) alpha:1.0];
    return color;
}

+ (UIColor *)pdHeaderBarTintColor {
    static UIColor *color = nil;
    if (!color)
        color = [[UIColor alloc] initWithRed:(18.0/255.0) green:(70.0/255.0) blue:(119.0/255.0) alpha:1.0];
    return color;
}

+ (UIColor *)pdTitleTextColor {
    static UIColor *color = nil;
    if (!color)
        color = [[UIColor alloc] initWithRed:(245.0/255.0) green:(246.0/255.0) blue:(246.0/255.0) alpha:1.0];
    return color;
}

+ (UIColor *)pdSectionBackgroundColor {
    static UIColor *color = nil;
    if (!color)
        color = [[UIColor alloc] initWithRed:(218.0/255.0) green:(239.0/255.0) blue:(255.0/255.0) alpha:0.9];
    return color;
}

+ (UIColor *)pdSectionTextColor {
    static UIColor *color = nil;
    if (!color)
        color = [[UIColor alloc] initWithRed:(174.0/255.0) green:(19.0/255.0) blue:(18.0/255.0) alpha:1.0];
    return color;
}

@end
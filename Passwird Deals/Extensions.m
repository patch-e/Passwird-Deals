//
//  Extensions.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "Extensions.h"

@implementation UIImage(Extension)

- (UIImage *) makeThumbnailOfSize:(CGSize)size;
{
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

+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlAddress]];
    
    if (data == nil) {
        return nil;
    }
        
    __autoreleasing NSError* error = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:data 
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self 
                                                options:kNilOptions 
                                                  error:&error];
    if (error != nil) return nil;
    
    return result;    
}

@end

@implementation NSString(Extension)
-(NSString *)urlEncode {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge_retained CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 );
}
@end
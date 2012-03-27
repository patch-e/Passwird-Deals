//
//  UIImageExtension.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "UIImageExtension.h"

@implementation UIImage(UIImageExtension)

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
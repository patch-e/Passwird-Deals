//
//  Extensions.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/24/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Extension)

- (UIImage *) makeThumbnailOfSize:(CGSize)size;

@end

@interface NSDictionary(Extension)

+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;

@end
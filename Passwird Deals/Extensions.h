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

+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;

@end

@interface NSString(Extension)

-(NSString *)urlEncode;

@end
//
//  NSDictionaryExtension.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/25/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(NSDictionaryExtension)

+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;

@end
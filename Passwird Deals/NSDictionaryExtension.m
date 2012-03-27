//
//  NSDictionaryExtension.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/25/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "NSDictionaryExtension.h"

@implementation NSDictionary(NSDictionaryExtension)

+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlAddress]];
    
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
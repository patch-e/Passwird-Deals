//
//  DealData.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "DealData.h"

@implementation DealData

- (id)init {
    return [self initWithHeadline:@"" 
                             body:@"" 
                         imageURL:nil
                        isExpired:YES 
                       datePosted:nil
                           dealId:@""
                             slug:@""
                        sHeadline:@""];
}

- (id)initWithHeadline:(NSString *)headline
                  body:(NSString *)body
              imageURL:(NSURL *)imageURL
             isExpired:(BOOL)isExpired 
            datePosted:(NSDate *)datePosted
                dealId:(NSString *)dealId
                  slug:(NSString *)slug
             sHeadline:(NSString *)sHeadline{
    if (self = [super init]) {
        [self setHeadline:headline];
        [self setBody:body];
        [self setImageURL:imageURL];
        [self setIsExpired:isExpired];
        [self setDatePosted:datePosted];
        [self setDealId:dealId];
        [self setSlug:slug];
        [self setSHeadline:sHeadline];
    }
    return self;
}

@end
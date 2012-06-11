//
//  DealData.m
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "DealData.h"

@implementation DealData

@synthesize headline = _headline;
@synthesize body = _body;
@synthesize imageURL = _imageURL;
@synthesize isExpired = _isExpired;
@synthesize datePosted = _datePosted;

- (id)init {
    return [self initWithHeadline:@"" 
                             body:@"" 
                         imageURL:nil
                        isExpired:YES 
                       datePosted:nil];
}

- (id)initWithHeadline:(NSString*)headline 
                  body:(NSString*)body 
              imageURL:(NSURL*)imageURL
             isExpired:(BOOL)isExpired 
            datePosted:(NSDate *)datePosted {
    if (self = [super init]) {
        self.headline = headline;
        self.body = body;
        self.imageURL = imageURL;
        self.isExpired = isExpired;
        self.datePosted = datePosted;
    }
    return self;
}

@end
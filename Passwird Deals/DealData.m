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
@synthesize image = _image;
@synthesize imageURL = _imageURL;
@synthesize isExpired = _isExpired;

- (id)init:(NSString*)headline body:(NSString*)body image:(UIImage*)image imageURL:(NSURL*)imageURL isExpired:(BOOL)isExpired {
    if ((self = [super init])) {
        self.headline = headline;
        self.body = body;
        self.image = image;
        self.imageURL = imageURL;
        self.isExpired = isExpired;
    }
    return self;
}

@end
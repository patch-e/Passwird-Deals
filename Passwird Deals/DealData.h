//
//  DealData.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DealData : NSObject

@property (strong) NSString *headline;
@property (strong) NSString *body;
@property (strong) NSURL *imageURL;
@property (assign) BOOL isExpired;
@property (strong) NSDate *datePosted;

- (id)init:(NSString*)headline body:(NSString*)body imageURL:(NSURL*)imageURL isExpired:(BOOL)isExpired datePosted:(NSDate*)datePosted;

@end
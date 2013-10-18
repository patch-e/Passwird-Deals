//
//  DealData.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

@interface DealData : NSObject

@property (strong) NSString *headline;
@property (strong) NSString *body;
@property (strong) NSURL *imageURL;
@property (assign) BOOL isExpired;
@property (strong) NSDate *datePosted;

@property (strong) NSString *dealId;
@property (assign) BOOL legacy;
@property (assign) BOOL hot;
@property (assign) BOOL free;
@property (strong) NSString *price;
@property (strong) NSString *slug;
@property (strong) NSString *sHeadline;
@property (strong) NSString *author;
@property (strong) NSString *expirationDate;
@property (strong) NSArray *images;

- (id)initWithHeadline:(NSString *)headline
                  body:(NSString *)body
              imageURL:(NSURL *)imageURL
             isExpired:(BOOL)isExpired
            datePosted:(NSDate *)datePosted
                dealId:(NSString *)dealId
                  slug:(NSString *)slug
             sHeadline:(NSString *)sHeadline;

- (NSURL *)getURL;

@end
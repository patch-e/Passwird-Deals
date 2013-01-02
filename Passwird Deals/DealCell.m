//
//  DealCell.m
//  Passwird Deals
//
//  Created by Patrick Crager on 12/28/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "DealCell.h"

@implementation DealCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger imageViewSize;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        imageViewSize = 57;
    } else {
        imageViewSize = 72;
    }
    
    NSInteger offset = 13;
    [self.imageView setFrame:CGRectMake(5, offset, imageViewSize, imageViewSize)];
    
    if (self.imageView.image.size.width > 0) {
        [self.textLabel setFrame:CGRectMake(imageViewSize+offset,
                                            self.textLabel.frame.origin.y,
                                            self.textLabel.frame.size.width,
                                            self.textLabel.frame.size.height)];
        [self.detailTextLabel setFrame:CGRectMake(imageViewSize+offset,
                                                  self.detailTextLabel.frame.origin.y,
                                                  self.detailTextLabel.frame.size.width,
                                                  self.detailTextLabel.frame.size.height)];
    }
}

@end
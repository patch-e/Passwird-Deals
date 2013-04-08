//
//  PDTableViewCell.m
//  Passwird Deals
//
//  Created by Patrick Crager on 12/28/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "PDTableViewCell.h"

@implementation PDTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageViewSize;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        imageViewSize = 57.0;
    } else {
        imageViewSize = 72.0;
    }
    
    CGFloat offset = 15.0;
    [self.imageView setFrame:CGRectMake(5.0, offset, imageViewSize, imageViewSize)];
    
    CGFloat textLabelSize = self.frame.size.width - (self.imageView.frame.size.width + offset + 30);

    if (self.imageView.image.size.width > 0) {
        [self.textLabel setFrame:CGRectMake(imageViewSize+offset,
                                            self.textLabel.frame.origin.y,
                                            textLabelSize,
                                            self.textLabel.frame.size.height)];
        [self.detailTextLabel setFrame:CGRectMake(imageViewSize+offset,
                                                  self.detailTextLabel.frame.origin.y,
                                                  self.detailTextLabel.frame.size.width,
                                                  self.detailTextLabel.frame.size.height)];
    }
}

@end
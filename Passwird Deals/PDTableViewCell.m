//
//  PDTableViewCell.m
//  Passwird Deals
//
//  Created by Patrick Crager on 12/28/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

#import "PDTableViewCell.h"

@implementation PDTableViewCell

@synthesize hasBanner;

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

- (void)setHasBanner:(BOOL)value {
    if (value != hasBanner) {
        hasBanner = value;
        
        if (hasBanner) {
            CALayer *banner = [CALayer layer];
            [banner setBackgroundColor:[UIColor pdHeaderTintColor].CGColor];
            [banner setBounds:CGRectMake(0, 0, 90, 15)];
            [banner setAnchorPoint:CGPointMake(0.5, 0)];
            [banner setPosition:CGPointMake(20, 20)];
            [banner setAffineTransform:CGAffineTransformMakeRotation(-45.0 / 180.0 * M_PI)];
            [banner setShadowOffset:CGSizeMake(0, 0)];
            [banner setShadowRadius:5.0];
            [banner setShadowColor:[UIColor pdShadowColor].CGColor];
            [banner setShadowOpacity:1.0];
            
            CATextLayer *label = [[CATextLayer alloc] init];
            [label setFont:@"Helvetica-Bold"];
            [label setFontSize:13];
            [label setFrame:banner.bounds];
            [label setString:@"EXPIRED"];
            [label setAlignmentMode:kCAAlignmentCenter];
            [label setForegroundColor:[[UIColor whiteColor] CGColor]];
            [label setContentsScale:[[UIScreen mainScreen] scale]];
            [banner addSublayer:label];
            
            [self.layer addSublayer:banner];
            self.bannerLayer = banner;
        } else {
            [self.bannerLayer removeFromSuperlayer];
            self.bannerLayer = nil;
        }
    }
}

@end
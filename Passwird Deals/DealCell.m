//
//  DealCell.m
//  Passwird Deals
//
//  Created by Patrick Crager on 12/28/12.
//
//

#import "DealCell.h"

@implementation DealCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger size;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        size = 57;
    } else {
        size = 72;
    }
    self.imageView.frame = CGRectMake(5,13,size,size);
    
    float limgW =  self.imageView.image.size.width;
    if(limgW > 0) {
        self.textLabel.frame = CGRectMake(size+13,
                                          self.textLabel.frame.origin.y,
                                          self.textLabel.frame.size.width,
                                          self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(size+13,
                                                self.detailTextLabel.frame.origin.y,
                                                self.detailTextLabel.frame.size.width,
                                                self.detailTextLabel.frame.size.height);
    }
}

@end
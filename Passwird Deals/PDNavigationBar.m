//
//  PDNavigationBar.m
//  Passwird Deals
//
//  Created by Patrick Crager on 4/6/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "PDNavigationBar.h"

#import "Extensions.h"

@implementation PDNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, self.frame.size.width, self.frame.size.height)];

    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName:@"Amelia" size:24.0]];
    [label setShadowColor:[UIColor pdDarkGrayColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setTextColor:[UIColor pdRedColor]];
    [label setText:self.topItem.title];

    label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.topItem.titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.topItem setTitleView:label];
}

@end
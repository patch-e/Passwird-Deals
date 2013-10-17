//
//  PDNavigationBar.m
//  Passwird Deals
//
//  Created by Patrick Crager on 4/6/13.
//  Copyright (c) 2013 McCrager. All rights reserved.
//

#import "PDNavigationBar.h"

#import "THLabel.h"

@implementation PDNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    
    THLabel *label = [[THLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

    [label setFont:[UIFont fontWithName:@"Arial Black" size:18.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor pdTitleTextColor]];
    [label setText:self.topItem.title];

    // THLabel specific properties
    [label setStrokeColor:[UIColor pdHeaderBarTintColor]];
	[label setStrokeSize:2.5f];
    
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.topItem.titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.topItem setTitleView:label];
}

@end
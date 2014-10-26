//
//  PDTableViewCell.h
//  Passwird Deals
//
//  Created by Patrick Crager on 12/28/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

@interface PDTableViewCell : UITableViewCell

@property (nonatomic) BOOL hasBanner;
@property (weak, nonatomic) CALayer *bannerLayer;

@end
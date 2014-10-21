//
//  AppDelegate.h
//  Passwird Deals
//
//  Created by Patrick Crager on 3/18/12.
//  Copyright (c) 2012 McCrager. All rights reserved.
//

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

+ (AppDelegate*)delegate;
+ (void)postResetBadgeCount;
+ (BOOL)setApplicationIconBadgeNumber:(NSInteger)badgeNumber;

@end

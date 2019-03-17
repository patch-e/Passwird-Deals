//
//  GoogleChromeActivity.h
//  PasswirdDeals
//
//  Created by Patrick Crager on 3/17/19.
//
//

@interface GoogleChromeActivity : UIActivity

@property (nonatomic, strong) NSURL *url;

- (NSString *)activityType;
- (NSString *)activityTitle;
- (UIImage *)activityImage;

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems;
- (void)prepareWithActivityItems:(NSArray *)activityItems;
- (void)performActivity;

@end

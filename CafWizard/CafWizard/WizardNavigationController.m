//
//  NavigationController.m
//  
//
//  Created by Miles Luders on 6/18/15.
//
//

#import "WizardNavigationController.h"
#import "Constants.h"

@implementation WizardNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Basic appearance
    self.navigationBar.translucent = false;    

    //self.navigationBar.topItem.title = @"Menu";
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[Constants NAVBAR_COLOR]];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    
    // Font
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadow.shadowColor = [UIColor clearColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Semibold" size:20.0f],
                                                            NSShadowAttributeName: shadow
                                                            }];
    
    // Back button
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    // Bottom border
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationBar.frame.size.height-1,self.navigationBar.frame.size.width, 2)];
    [navBorder setBackgroundColor:[Constants NAVBAR_COLOR]];
    [navBorder setOpaque:YES];
    [self.navigationBar addSubview:navBorder];
}

@end

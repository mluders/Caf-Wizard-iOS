//
//  MenuController.h
//  CafWizard
//
//  Created by Miles Luders on 8/10/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RatingsController.h"

@interface MenuController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, RatingsControllerDelegate>

@property (weak, nonatomic) id<RatingsControllerDelegate> delegate;


@property (weak, nonatomic) IBOutlet UITableView *itemTable;

@end

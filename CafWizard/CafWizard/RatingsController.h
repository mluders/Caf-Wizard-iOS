//
//  RatingsController.h
//  CafWizard
//
//  Created by Miles Luders on 9/15/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RatingsControllerDelegate
- (void)updateRatingValues:(NSArray*)values withVoteDistribution:(NSArray*)distribution;
@end

@interface RatingsController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dayparts;
@property (nonatomic, strong) NSArray *ratingValues;
@property (nonatomic, strong) NSArray *voteDistribution;
@property (nonatomic, weak) id delegate;


@end

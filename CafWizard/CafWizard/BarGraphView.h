//
//  RatingGraphView.h
//  CafWizard
//
//  Created by Miles Luders on 9/17/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarGraphView : UIView

@property (nonatomic, assign) float percentage;
@property (nonatomic, assign) float red;
@property (nonatomic, assign) float green;
@property (nonatomic, assign) float blue;
@property (nonatomic, retain) UILabel *percentageLabel;

- (void)updatePercentageLabelWithFloat:(float)input;
- (void)setActive;
- (void)setInactive;


@end

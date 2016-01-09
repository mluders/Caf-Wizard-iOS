//
//  RatingGraphView.m
//  CafWizard
//
//  Created by Miles Luders on 9/17/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import "BarGraphView.h"
#import "Constants.h"

@implementation BarGraphView

- (void)drawRect:(CGRect)rect {
    
    // Draw bar graph
    CGRect rectangle = CGRectMake(0, 0, ((self.frame.size.width*(_percentage/1.5)/.5))/1.5, self.frame.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, _red, _green, _blue, 1.0);
    CGContextFillRect(context, rectangle);
    
    // Place the label at the end of bar graph
    _percentageLabel.center = CGPointMake((rectangle.size.width+35), self.frame.size.height*.5);
}

-(void)awakeFromNib {
    // Allocate percentage label one time
    _percentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 62.0f, 30.0f)];
    [_percentageLabel setFont:[UIFont fontWithName:@"ProximaNova-Semibold" size:14.0f]];
    [_percentageLabel setTextColor:[Constants LIGHT_GRAY]];
    [_percentageLabel setText:@"100"];
    [self addSubview:_percentageLabel];
}

- (void)updatePercentageLabelWithFloat:(float)input{
    //_percentageLabel.text = [NSString stringWithFormat:@"%.f%%", input*100];
    
    NSString *voteString;
    if (input == 1) {
        voteString = @"vote";
    }
    else {
        voteString = @"votes";
    }
    _percentageLabel.text = [NSString stringWithFormat:@"%.f %@", input*1, voteString];
}

- (void)setActive {
    [self setBarColorWithRed:0.45 withGreen:0.37 withBlue:0.77];
    [_percentageLabel setTextColor:[Constants NAVBAR_COLOR]];
}

- (void)setInactive {
    [self setBarColorWithRed:196.0/255.0 withGreen:199.0/255.0 withBlue:200.0/255.0];
    [_percentageLabel setTextColor:[UIColor colorWithRed: 196.0/255.0 green: 199.0/255.0 blue: 200.0/255.0 alpha: 0.9]];
}

- (void)setBarColorWithRed:(float)r withGreen:(float)g withBlue:(float)b {
    // Reset color and go
    _red = r;
    _green = g;
    _blue = b;
    [self setNeedsDisplay];
}

@end

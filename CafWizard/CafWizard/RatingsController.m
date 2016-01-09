//
//  RatingsController.m
//  CafWizard
//
//  Created by Miles Luders on 9/15/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import "RatingsController.h"
#import "Reachability.h"
#import "Constants.h"
#import "WizardDB.h"
#import "WizardTime.h"
#import "WizardUser.h"
#import "LoadingView.h"
#import "BarGraphView.h"

@interface RatingsController () {
    int _startingIndex, _selectedIndex, _previousIndex;
}

// Data model
@property (nonatomic, assign) int daypartAsInt;
@property (nonatomic, retain) NSString *daypartAsString;
@property (nonatomic, strong) NSArray *ratingTitles;
@property (nonatomic, strong) NSArray *ratingPercentages;

// UI Elements
@property (weak, nonatomic) IBOutlet UILabel *daypartLabel;
@property (weak, nonatomic) IBOutlet UITableView *itemTable;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) LoadingView *indicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *votingIsClosedLabel;

@end

@implementation RatingsController

#pragma mark - View init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initElements];
        
    // Set daypart label
    [self.daypartLabel setText:[NSString stringWithFormat:@"%@", self.daypartAsString]];
    
    [self getData];
}

- (void)initElements {
    _previousIndex = -1;
    _selectedIndex = -1;
    
    self.descriptionLabel.text = @"What do you think?";
    self.ratingTitles = [[NSArray alloc] initWithObjects:@"Flowing with Milk & Honey", @"Satisfactory", @"Adequate", @"Not Recommended", nil];
    self.indicatorLabel = [[LoadingView alloc] initWithCircleSize:12.0f];
    [self.indicatorLabel showInView:self.view withCenterPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
}

#pragma mark - Data

- (void)getData {
    
    [self updateElementsWithStatus:1];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.daypartAsInt = (int)[WizardTime getCurrentDaypartAsIntWithTimes:self.dayparts];
        self.daypartAsString = [WizardTime getCurrentDaypartAsString:[[self.dayparts objectAtIndex:0]objectForKey:@"distribution"] withInt:self.daypartAsInt];
        self.ratingPercentages = [self calculatePercentagesFromValues:self.ratingValues];
        
        _selectedIndex = [[WizardUser getCurrentVoteForDaypart:self.daypartAsString] intValue];
        
        if (_selectedIndex >= 0) {
            if ([[[self.ratingValues objectAtIndex:_selectedIndex] objectAtIndex:self.daypartAsInt] intValue] == 0) {
                // NSLog(@"boooom");
                _selectedIndex = -1;
            }
        }
        
        _startingIndex = _selectedIndex;
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            // Has dinner ended?
            if (self.daypartAsInt > 2 || self.daypartAsInt < 0) {
                [self updateElementsWithStatus:2];
            }
            else {
                [self updateElementsWithStatus:0];

            }
        });
    });
}

- (void)retryConnection
{
    [self getData];
}

#pragma mark - UI Elements

- (void)updateElementsWithStatus:(int)status {
    switch (status) {
        case 0:
            self.indicatorLabel.hidden = YES;
            [self.indicatorLabel stopAnimating];
            self.descriptionLabel.hidden = NO;
            self.daypartLabel.hidden = NO;
            self.itemTable.hidden = NO;
            self.votingIsClosedLabel.hidden = YES;
            self.daypartLabel.text = self.daypartAsString;
            [self.itemTable reloadData];
            break;
        case 1:
            self.indicatorLabel.hidden = NO;
            self.descriptionLabel.hidden = YES;
            self.daypartLabel.hidden = YES;
            [self.indicatorLabel startAnimating];
            self.itemTable.hidden = YES;
            self.votingIsClosedLabel.hidden = YES;
            break;
        case 2:
            self.indicatorLabel.hidden = YES;
            self.descriptionLabel.hidden = YES;
            self.daypartLabel.hidden = YES;
            [self.indicatorLabel stopAnimating];
            self.itemTable.hidden = YES;
            self.votingIsClosedLabel.hidden = NO;
            break;
    }
}

#pragma mark - Table setup

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemTable.frame.size.height/4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Woot!
    NSString *cellIdentifier = @"ItemCell";
    
    // Dequeue cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row == 0) {
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.itemTable.frame.size.width, 2)];
        separatorLineView.backgroundColor = [Constants TABLE_CELL_BORDER_COLOR];
        [cell.contentView addSubview:separatorLineView];
    }
    
    // Create a custom separator line
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height, self.itemTable.frame.size.width*2, -2)];
    separatorLineView.backgroundColor = [Constants TABLE_CELL_BORDER_COLOR];
    [cell.contentView addSubview:separatorLineView];

    
    
    // Disable cell selection entirely
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Create a graph view!
    BarGraphView *graphView = (BarGraphView*)[cell viewWithTag:201];
    [graphView setInactive];
    [graphView setPercentage:0.0];
    if (self.ratingPercentages.count > 2) {
        [graphView setPercentage:[[self.ratingPercentages objectAtIndex:indexPath.row]floatValue]];
        //[graphView updatePercentageLabelWithFloat:[[self.ratingPercentages objectAtIndex:indexPath.row]floatValue]];
        [graphView updatePercentageLabelWithFloat:[[[self.ratingValues objectAtIndex:indexPath.row]objectAtIndex:self.daypartAsInt]floatValue]];
    }
    [graphView setNeedsDisplay];
    
    // Set title label
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    titleLabel.text = [self.ratingTitles objectAtIndex:indexPath.row];
    titleLabel.textColor = [UIColor colorWithRed: 196.0/255.0 green: 199.0/255.0 blue: 200.0/255.0 alpha: 1.0];
    
    // Check if cell is active => handle accordingly
    if (indexPath.row == _selectedIndex) {
        titleLabel.textColor = [Constants NAVBAR_COLOR];
        [graphView setActive];
    }
    
    return cell;
}

#pragma mark - Voting

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndex == indexPath.row) {
        return;
    }
    else {
        if (_selectedIndex >=0) {
            _previousIndex = _selectedIndex;
            //NSLog(@"previous: %d", _previousIndex);
        }
        _selectedIndex = (int)indexPath.row;
        //NSLog(@"current: %d", _selectedIndex);
        
        // Update local count
        [self updateLocalRatingValues];
        [self updateElementsWithStatus:0];
    }
}

- (NSArray*)calculatePercentagesFromValues:(NSArray*)values {
    NSMutableArray *percentages = [NSMutableArray array];
    
    float sum = 0;
    
    if (self.daypartAsInt >= 0 && self.daypartAsInt < 3) {
        // Calculate the sum
        for (NSArray *value in values) {
            sum += [[value objectAtIndex:self.daypartAsInt] floatValue];
        }
        
        // Find each percentage
        for (NSArray *value in values) {
            float detailed = [[value objectAtIndex:self.daypartAsInt] floatValue]/sum;
            float rounded = roundf(detailed*100.0)/100.0;
            
            if (isnan(rounded)) {
                [percentages addObject:@0];
            }
            else {
                //NSLog(@"rounded: %f", rounded);
                [percentages addObject:[NSNumber numberWithFloat:rounded ]];
            }
            
        }
    }

    
    return [percentages copy];
    return values;
}

- (void)updateLocalRatingValues {
    NSMutableArray *currentRatingValues = [self.ratingValues mutableCopy];
    
    NSMutableArray *selectedVoteDistribution = [currentRatingValues objectAtIndex:_selectedIndex];
    int oldSelected = [[selectedVoteDistribution objectAtIndex:self.daypartAsInt] intValue];
    int newSelected = oldSelected + 1;
    [selectedVoteDistribution replaceObjectAtIndex:self.daypartAsInt withObject:[NSNumber numberWithInt:newSelected]];
    [currentRatingValues replaceObjectAtIndex:_selectedIndex withObject:selectedVoteDistribution];
    
    if (_previousIndex >= 0) {
        NSMutableArray *previousVoteDistribution = [currentRatingValues objectAtIndex:_previousIndex];
        int oldPrevious = [[previousVoteDistribution objectAtIndex:self.daypartAsInt] intValue];
        int newPrevious = oldPrevious - 1;
        if (newPrevious >= 0) {
            [previousVoteDistribution replaceObjectAtIndex:self.daypartAsInt withObject:[NSNumber numberWithInt:newPrevious]];
            [currentRatingValues replaceObjectAtIndex:_previousIndex withObject:previousVoteDistribution];
        }
    }
    
    self.ratingValues = [currentRatingValues copy];
    self.ratingPercentages = [self calculatePercentagesFromValues:self.ratingValues];
}

#pragma mark - IBActions

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Did the vote actually change?
    if (_startingIndex != _selectedIndex) {

        // Update the vote count in parse
        //[WizardDB updateVoteCountForDaypart:self.daypartAsInt withSelectedIndex:_selectedIndex withPreviousIndex:_previousIndex];
        [WizardDB saveRatingValuesToParse:self.ratingValues];
        [WizardUser setCurrentVote:[NSNumber numberWithInt:_selectedIndex] forDaypart:self.daypartAsString];
        
    }
}




@end

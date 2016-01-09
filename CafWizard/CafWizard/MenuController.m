//
//  MenuController.m
//  CafWizard
//
//  Created by Miles Luders on 8/10/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import "MenuController.h"
#import "RatingsController.h"
#import "Constants.h"
#import "WizardDB.h"
#import "WizardTime.h"
#import "Reachability.h"
#import "WizardUI.h"
#import "WizardUser.h"
#import "HMSegmentedControl.h"
#import "LoadingView.h"
#import "CNPPopupController.h"

@interface MenuController () <CNPPopupControllerDelegate> {
    int _currentIndex;
    BOOL _internetIsAvailable;
    BOOL _dataIsLoading;
}

// Data model
@property (nonatomic, strong) NSArray *dayparts;
@property (nonatomic, strong) NSArray *itemsByDaypart;
@property (nonatomic, strong) NSArray *headerDescriptions;
@property (nonatomic, strong) NSArray *ratingValues;
@property (nonatomic, strong) NSArray *voteDistribution;


// UI Elements
@property (nonatomic, strong) IBOutlet UIView *segmentedControllerView;
@property (nonatomic, strong) IBOutlet UILabel *mealExchangeStatusLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ratingsButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *retryConnectionButton;
@property (nonatomic, strong) LoadingView *indicatorLabel;

// Other
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CNPPopupController *popupController;

@end

@implementation MenuController

#pragma mark -

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _currentIndex = 0;
    self.itemTable.delaysContentTouches = NO;
    
    [self initUIElements];
    [self createSegmentedControl];
    [self getData];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFromBackground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - data

- (void)getData {
    
    [self updateElementsWithStatus:1];
    
    if ([Reachability isInternetConnectionAvailable]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            _internetIsAvailable = YES;
            _dataIsLoading = YES;
            
            [WizardTime updateCachedTime];
            
            self.dayparts = [WizardDB getDayparts];
            self.itemsByDaypart = [WizardDB getActiveItemsSortedByCafes:self.dayparts];
            self.headerDescriptions = [WizardTime getHeaderDescriptionsWithDayparts:self.dayparts];
            self.ratingValues = [WizardDB getRatingValues];
            [WizardUser updateCurrentVotes];

            dispatch_async(dispatch_get_main_queue(), ^{
                _dataIsLoading = NO;
                [self updateElementsWithStatus:0];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastReloadedMenu"];
                
            });
        });
    }
    else {
        [self updateElementsWithStatus:2];
        _internetIsAvailable = NO;
    }
}

- (void)retryConnection {
    
    [self getData];
}

- (void)willEnterFromBackground {
    // If minutes have changed, update the time headers
    NSArray *tempHeaderDescriptions = [WizardTime getHeaderDescriptionsWithDayparts:self.dayparts];
    if (![self.headerDescriptions isEqualToArray:tempHeaderDescriptions]) {
        self.headerDescriptions = tempHeaderDescriptions;
        [self.itemTable reloadData];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"lastReloadedMenu"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastReloadedMenu"];
    }
    else {
        NSDate *lastReloaded = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"lastReloadedMenu"];
        
        if ([lastReloaded timeIntervalSinceNow] < -300.0f) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastReloadedMenu"];
            
            [self getData];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToRatings"]) {
        RatingsController *destination = [segue destinationViewController];
        destination.delegate = self;
        destination.dayparts = self.dayparts;
        destination.ratingValues = self.ratingValues;
    }
}

#pragma mark Segmented Control
CREATE_SEGMENTED_CONTROL()

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    _currentIndex = (int)segmentedControl.selectedSegmentIndex;
    
    if ([self.dayparts count] > 1 && _internetIsAvailable && _dataIsLoading == NO) {
        [self updateElementsWithStatus:0];

    }
    
    [self.itemTable reloadData];
}

#pragma mark Ratings Delegate
- (void)updateRatingValues:(NSArray*)values withVoteDistribution:(NSArray*)distribution {
    self.ratingValues = values;
    self.voteDistribution = distribution;
}

#pragma mark - Item Popup

- (void)showPopupWithStyle:(CNPPopupStyle)popupStyle {
    NSIndexPath *indexPath = [self.itemTable indexPathForSelectedRow];
    // Data
    NSString *itemName = [[[[self.itemsByDaypart objectAtIndex:_currentIndex]objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row]objectForKey:@"name"];
    
    NSString *itemDescription = [[[[self.itemsByDaypart objectAtIndex:_currentIndex]objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row]objectForKey:@"description"];
    
    NSString *itemStation = [[[[self.itemsByDaypart objectAtIndex:_currentIndex]objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row]objectForKey:@"station"];
    
    NSMutableParagraphStyle *paragraphStyleLeft = NSMutableParagraphStyle.new;
    paragraphStyleLeft.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleLeft.alignment = NSTextAlignmentLeft;
    
    
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:itemName attributes:@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Semibold" size:30.0f], NSParagraphStyleAttributeName : paragraphStyleLeft}];
    
    NSAttributedString *description = [[NSAttributedString alloc] initWithString:itemDescription attributes:@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Semibold" size:18.0f], NSParagraphStyleAttributeName : paragraphStyleLeft}];
    
    NSAttributedString *station = [[NSAttributedString alloc] initWithString:itemStation attributes:@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Semibold" size:18.0f], NSParagraphStyleAttributeName : paragraphStyleLeft}];
    
    
    CNPPopupButton *closeButton = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImage *closeButtonImage = [UIImage imageNamed:@"arrowDown"];
    [closeButton setImage:closeButtonImage forState:UIControlStateNormal];

    closeButton.selectionHandler = ^(CNPPopupButton *closeButton){
        [self.popupController dismissPopupControllerAnimated:YES];
        [self.itemTable deselectRowAtIndexPath:[self.itemTable indexPathForSelectedRow] animated:YES];
        
    };
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:40.0/255.0 alpha:1.0];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.textColor = [UIColor colorWithRed:137.0/255.0 green:143.0/255.0 blue:146.0/255.0 alpha:0.9];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.attributedText = description;
    
    UILabel *stationLabel = [[UILabel alloc] init];
    stationLabel.textColor = [Constants NAVBAR_COLOR];
    stationLabel.numberOfLines = 0;
    stationLabel.attributedText = station;
    
    
    NSMutableArray *popupContents = [NSMutableArray array];
    [popupContents addObject:titleLabel];
    if (![[description string] isEqualToString:@"WizardNull"]) [popupContents addObject:descriptionLabel];
    if (![[station string] isEqualToString:@"WizardNull"]) [popupContents addObject:stationLabel];
    [popupContents addObject:closeButton];
    self.popupController = [[CNPPopupController alloc] initWithContents:popupContents];
    
    
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self showPopupWithStyle:CNPPopupStyleActionSheet];
}

#pragma mark - CNPPopupController Delegate
- (void)popupControllerWillDismiss:(CNPPopupController *)controller {
    
    [self.itemTable deselectRowAtIndexPath:[self.itemTable indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    if (self.dayparts.count > 1) {
        return [[[self.dayparts objectAtIndex:_currentIndex] objectForKey:@"distribution"] count];
    }
    else {
        return 0;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderCellIdentifier = @"HeaderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HeaderCellIdentifier];
    }
    
    // Set daypart label
    UILabel *daypartLabel = (UILabel *)[cell viewWithTag:250];
    
    daypartLabel.text = [[NSString stringWithFormat:@"%@", [[[self.dayparts objectAtIndex:_currentIndex] objectForKey:@"distribution"] objectAtIndex:section]]uppercaseString];

    UILabel *timeLabel = (UILabel *)[cell viewWithTag:251];
    
    // Do not display hours for meal exchange headers
    if (_currentIndex == 0 && _dataIsLoading == NO) {
        timeLabel.text = [self.headerDescriptions objectAtIndex:section];
    }
    else {
        timeLabel.text = @"";
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.itemsByDaypart.count == 2)
        return [[[self.itemsByDaypart objectAtIndex:_currentIndex] objectAtIndex:section] count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get subarray of items
    NSArray *subArrayOfItems = [[self.itemsByDaypart objectAtIndex:_currentIndex]objectAtIndex:indexPath.section];
    
    
    // Get current item name
    NSString *currentItemName;
    currentItemName = [[subArrayOfItems objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    // Set the identifer and dequeue the cell
    NSString *myIdentifier;
    
    NSString *description = [[subArrayOfItems objectAtIndex:indexPath.row]objectForKey:@"description"];
    if (description && ![description  isEqual: @"WizardNull"] && description != NULL) {
        myIdentifier = @"DetailedItemCell";
    }
    else {
        myIdentifier = @"ItemCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
    
    // Cell selection background color
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [Constants TABLE_CELL_BORDER_COLOR];
    [cell setSelectedBackgroundView:bgColorView];
    
    // Create a custom separator line
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height,self.itemTable.frame.size.width, -2)];
    UIColor *bgColor = [Constants TABLE_CELL_BORDER_COLOR];
    CALayer* layer = [CALayer layer];
    layer.frame = separatorLineView.bounds;
    layer.backgroundColor = bgColor.CGColor;
    [separatorLineView.layer addSublayer:layer];
    [cell.contentView addSubview:separatorLineView];
    
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Set item name
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    nameLabel.text = [[NSString stringWithFormat:@"%@", currentItemName]capitalizedString];
    
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:104];
    descriptionLabel.text = description;
    
    
    return cell;
}



#pragma mark - UI Elements

- (void)initUIElements {
    CREATE_STATUS_LABEL()
    CREATE_RETRY_BUTTON()
    
    self.indicatorLabel = [[LoadingView alloc] initWithCircleSize:12.0f];
    [self.indicatorLabel showInView:self.view withCenterPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    [self.mealExchangeStatusLabel setText:@"There's no meal exchange today :("];
}


- (void)updateElementsWithStatus:(int)status {
    switch (status) {
        // Data is ready to display
        case 0:
            if (_currentIndex == 1 && [[[self.dayparts objectAtIndex:1] objectForKey:@"distribution"] count] == 0) {
                self.mealExchangeStatusLabel.hidden = NO;
                //NSLog(@"showing meal exchange");
            }
            else {
                self.mealExchangeStatusLabel.hidden = YES;
                //NSLog(@"hiding meal exchange");
            }
            [self.itemTable reloadData];
            self.itemTable.hidden = NO;
            self.segmentedControllerView.hidden = NO;
            self.statusLabel.hidden = YES;
            self.ratingsButton.enabled = YES;
            self.retryConnectionButton.hidden = YES;
            self.indicatorLabel.hidden = YES;
            [self.indicatorLabel stopAnimating];
            break;
            
        // Data is loading
        case 1:
            self.itemTable.hidden = YES;
            self.segmentedControllerView.hidden = NO;
            self.retryConnectionButton.hidden = YES;
            self.statusLabel.hidden = YES;
            self.indicatorLabel.hidden = NO;
            self.ratingsButton.enabled = NO;
            self.mealExchangeStatusLabel.hidden = YES;
            [self.indicatorLabel startAnimating];
            break;
            
        // No Internet connection
        case 2:
            self.itemTable.hidden = YES;
            self.segmentedControllerView.hidden = NO;
            self.indicatorLabel.hidden = YES;
            self.retryConnectionButton.hidden = NO;
            self.statusLabel.hidden = NO;
            self.statusLabel.text = @"No internet connection";
            self.mealExchangeStatusLabel.hidden = YES;
            self.ratingsButton.enabled = NO;
            [self.indicatorLabel stopAnimating];
            break;
    }
}

#pragma mark - TableView Layout
SET_TABLE_ATTRIBUTES()
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {return 26;}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{return 68;}

@end

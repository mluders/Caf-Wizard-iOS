//
//  WizardUI.h
//  CafWizard
//
//  Created by Miles Luders on 9/11/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#ifndef CafWizard_WizardUI_h
#define CafWizard_WizardUI_h

#define CREATE_STATUS_LABEL() \
self.statusLabel =  [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 350, 100)]; \
self.statusLabel.text = @"Loading..."; \
[self.statusLabel setCenter:CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height-100) / 2)]; \
[self.statusLabel setTextAlignment:NSTextAlignmentCenter]; \
[self.statusLabel setTextColor:[UIColor colorWithRed: 44.0/255.0 green: 44.0/255.0 blue: 44.0/255.0 alpha: 1.0]]; \
[self.statusLabel setFont:[UIFont fontWithName:@"ProximaNova-Semibold" size:25]]; \
[self.view addSubview:self.statusLabel];

#define CREATE_RETRY_BUTTON() \
self.retryConnectionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect]; \
[self.retryConnectionButton addTarget:self action:@selector(retryConnection) forControlEvents:UIControlEventTouchUpInside]; \
[self.retryConnectionButton setTitle:@"Retry" forState:UIControlStateNormal]; \
[self.retryConnectionButton setTitleColor:[UIColor colorWithRed: 116.0/255.0 green: 94.0/255.0 blue: 197.0/255.0 alpha: 1.0] forState:UIControlStateNormal]; \
[self.retryConnectionButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNova-Semibold" size:25]]; \
self.retryConnectionButton.frame = CGRectMake(80.0, 210.0, 160.0, 40.0); \
[self.retryConnectionButton setCenter:CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height) / 2)]; \
[self.view addSubview:self.retryConnectionButton];

#define CREATE_INDICATOR_LABEL() \
self.indicatorLabel = [[LoadingView alloc] initWithCircleSize:12.0f]; \
[self.indicatorLabel showInView:self.view withCenterPoint:CGPointMake(self.\view.frame.size.width/2, self.view.frame.size.height/2)];\

#define CREATE_LOGO()\
self.logo =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,80,127)];\
[self.logo setCenter:CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height-100) / 2.1)];\
self.logo.image=[UIImage imageNamed:@"wizardLogoLight"];\
[self.view addSubview:self.logo];

#define SET_TABLE_ATTRIBUTES() \
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { \
if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {[cell setSeparatorInset:UIEdgeInsetsZero];} \
if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {[cell setLayoutMargins:UIEdgeInsetsZero];}}\
\
- (void)setTableSeparatorAttributes {[self.itemTable setSeparatorColor:[UIColor clearColor]]; self.automaticallyAdjustsScrollViewInsets = NO;} \
- (void)viewDidLayoutSubviews { if ([self.itemTable respondsToSelector:@selector(setLayoutMargins:)]){[self.itemTable setLayoutMargins:UIEdgeInsetsZero];}} \
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section { \
view.tintColor = [Constants TABLE_HEADER_BACKGROUND_COLOR]; \
UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view; \
[header.textLabel setTextColor:[Constants TABLE_HEADER_FONT_COLOR]]; \
header.textLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:15.0];} \

#define CREATE_SEGMENTED_CONTROL() \
- (void)createSegmentedControl {\
self.segmentedControllerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.segmentedControllerView.frame.size.height)];\
\
HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Caf", @"Meal Exchange"]];\
segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [Constants SEGMENTED_CONTROL_FONT_COLOR],\
                                         NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Semibold" size:16.0]};\
segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [Constants SEGMENTED_CONTROL_FONT_COLOR_ENABLED],\
                                                 NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Semibold" size:16.0]};\
\
segmentedControl.frame = CGRectMake(0,0,self.segmentedControllerView.frame.size.width,self.segmentedControllerView.frame.size.height);\
\
segmentedControl.backgroundColor = [Constants SEGMENTED_CONTROL_BACKGROUND_COLOR];\
\
segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;\
\
segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;\
segmentedControl.selectionIndicatorHeight   = 7.0f;\
segmentedControl.selectionStyle             = HMSegmentedControlSelectionStyleArrow;\
segmentedControl.selectionIndicatorColor    = [Constants SELECTION_INDICATOR_COLOR];\
\
\
\
[segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];\
\
[self.view addSubview:self.segmentedControllerView];\
[self.segmentedControllerView addSubview:segmentedControl];\
self.segmentedControllerView.hidden = YES;\
}

#endif

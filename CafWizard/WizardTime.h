//
//  WizardTime.h
//  CafWizard
//
//  Created by Miles Luders on 8/29/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface WizardTime : NSObject

+ (NSString*) getCurrentTime;
+ (NSString*)getCurrentDaypartAsString:(NSArray*)dayparts withTimes:(NSArray*)times;
+ (NSString*)getCurrentDaypartAsString:(NSArray*)dayparts withInt:(int)daypart;
+ (NSInteger)getCurrentDaypartAsIntWithTimes:(NSArray*)times;
+ (NSString*)getDateAsString:(int)day;
+ (NSArray*)getHeaderDescriptionsWithDayparts:(NSArray*)dayparts;
+ (NSDate*)getYesterday;
+ (void)updateCachedTime;

@end

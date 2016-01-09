//
//  WizardUser.h
//  CafWizard
//
//  Created by Miles Luders on 9/2/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface WizardUser : NSObject

+ (NSString*)generateWIZID;
+ (void)createNewWizardUser;
+ (void)createNewWizardUserWithDeviceToken:(NSData *)deviceToken;
+ (NSString*)getMyWIZID;
+ (NSString*)getDeviceTokenFromParse;
+ (void)updateDeviceToken:(NSData *)deviceToken;
+ (NSNumber*)getCurrentVoteForDaypart:(NSString*)daypart;
+ (void)setCurrentVote:(NSNumber*)vote forDaypart:(NSString*)daypart;
+ (void)updateCurrentVotes;

@end

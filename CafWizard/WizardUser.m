//
//  WizardUser.m
//  CafWizard
//
//  Created by Miles Luders on 9/2/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import "WizardUser.h"
#import "WizardTime.h"

@implementation WizardUser

+ (NSString*)generateWIZID {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 25];
    
    for (int i=0; i<25; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
    }
    
    return (NSString*) randomString;
}

+ (void)createNewWizardUser {
    NSString *newWIZID = [self generateWIZID];
    
    [[NSUserDefaults standardUserDefaults] setObject:newWIZID forKey:@"myWIZID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    PFObject *newWizardUser = [PFObject objectWithClassName:@"WizardUser"];
    newWizardUser[@"WIZID"] = newWIZID;
    newWizardUser[@"favorites"] = [[NSArray alloc] init];
    newWizardUser[@"lastAlert"] = [NSNumber numberWithInt:-1];
    newWizardUser[@"lastUpdated"] = [NSNumber numberWithInt:-1];
    newWizardUser[@"voteDistribution"] = [self blankVoteDistribution];
    
    [newWizardUser saveInBackground];
}

+ (void)createNewWizardUserWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    NSString *newWIZID = [self generateWIZID];
    
    //NSLog(@"New WIZID: %@", newWIZID);
    
    [[NSUserDefaults standardUserDefaults] setObject:newWIZID forKey:@"myWIZID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    PFQuery *query = [PFQuery queryWithClassName:@"WizardUser"];
    [query whereKey:@"deviceToken" equalTo:[currentInstallation deviceToken]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *existingUsers, NSError *error) {
        if (existingUsers.count > 0) {
            
            for (PFObject *user in existingUsers) {
                user[@"WIZID"] = newWIZID;
                [user saveInBackground];
            }
        } else {
            
            PFObject *newWizardUser = [PFObject objectWithClassName:@"WizardUser"];
            newWizardUser[@"WIZID"] = newWIZID;
            newWizardUser[@"favorites"] = [[NSArray alloc] init];
            newWizardUser[@"deviceToken"] = [currentInstallation deviceToken];
            newWizardUser[@"lastAlert"] = [NSNumber numberWithInt:-1];
            newWizardUser[@"lastUpdated"] = [NSNumber numberWithInt:-1];
            newWizardUser[@"voteDistribution"] = [self blankVoteDistribution];
            
            [newWizardUser saveInBackground];
        }
    }];
}

+ (NSArray*)blankVoteDistribution {
    return [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1], nil];
}

+ (NSString*)getMyWIZID {
    NSString *myWIZID = [[NSUserDefaults standardUserDefaults] stringForKey:@"myWIZID"];
    
    if (myWIZID) {
        return myWIZID;
    }
    
    [self createNewWizardUser];
    myWIZID = [[NSUserDefaults standardUserDefaults] stringForKey:@"myWIZID"];
    
    return myWIZID;
}

+ (NSString*)getDeviceTokenFromParse {
    
    PFQuery *query = [PFQuery queryWithClassName:@"WizardUser"];
    [query whereKey: @"WIZID" equalTo:[self getMyWIZID]];
    PFObject *user = [query getFirstObject];
    
    if (user) {
        return user[@"deviceToken"];
    }
    else {
        return user[@"Cannot find device token"];
    }
}

+ (void)updateDeviceToken:(NSData *)deviceToken {
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"myDeviceToken"];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    PFQuery *userQuery = [PFQuery queryWithClassName:@"WizardUser"];
    [userQuery whereKey:@"WIZID" equalTo:[WizardUser getMyWIZID]];
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if (!user) {
            //NSLog(@"Failed to find the user");
        } else {
            
            user[@"deviceToken"] = [currentInstallation deviceToken];
            [user saveInBackground];
        }
    }];
}

+ (NSNumber*)getCurrentVoteForDaypart:(NSString*)daypart {
    NSNumber *currentVote = [[NSUserDefaults standardUserDefaults] objectForKey:daypart];
    if (currentVote) {
        return currentVote;
    }
    else {
        return [NSNumber numberWithInt:-1];
    }
}

+ (void)setCurrentVote:(NSNumber*)vote forDaypart:(NSString*)daypart {
    [[NSUserDefaults standardUserDefaults] setObject:vote forKey:daypart];

}

+ (void)updateCurrentVotes {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];
    
    /*NSLog(@"weekday: %ld", (long)weekday);
    NSLog(@"userdefaults weekday: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdatedVoteDistribution"]);*/
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdatedVoteDistribution"] != [NSNumber numberWithInteger:weekday]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:@"Breakfast"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:@"Lunch"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:@"Dinner"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:@"Brunch"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:weekday] forKey:@"lastUpdatedVoteDistribution"];
        //NSLog(@"new userdefaults weekday: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdatedVoteDistribution"]);
    }
}



@end

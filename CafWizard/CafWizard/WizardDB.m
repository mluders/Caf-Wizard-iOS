//
//  WizardDB.m
//  CafWizard
//
//  Created by Miles Luders on 8/29/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import "WizardDB.h"
#import "WizardTime.h"
#import "WizardUser.h"

@implementation WizardDB

+ (NSArray*)getDayparts {
    NSMutableArray *daypartsToReturn= [NSMutableArray array];
    
    // Get cafDaypart
    PFQuery *query = [PFQuery queryWithClassName:@"Daypart"];
    [query orderByAscending:@"order"];
    NSArray *dayparts = [query findObjects];
    
    for (PFObject *daypart in dayparts) {
        NSArray *distribution = daypart[@"distribution"];
        NSArray *hours = daypart[@"hours"];
        NSMutableDictionary *singleDaypart = [NSMutableDictionary dictionary];
        [singleDaypart setObject:distribution forKey:@"distribution"];
        [singleDaypart setObject:hours forKey:@"hours"];
        [daypartsToReturn addObject:singleDaypart];
    }
    
    return [daypartsToReturn copy];
}

+ (NSArray*)getActiveItemsSortedByCafes:(NSArray*)cafes {
    NSMutableArray *itemsToReturn = [NSMutableArray array];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"active" equalTo:@YES];
    NSArray *activeItems = [query findObjects];
    
    for (NSDictionary *cafeDistribution in cafes) {
        //NSLog(@"cafe distribution: %@", cafeDistribution);
        NSMutableArray *tempArray = [NSMutableArray array];
        
        NSArray *daypartDistribution = [cafeDistribution objectForKey:@"distribution"];
        
        for (NSString *daypart in daypartDistribution) {
            //NSLog(@"daypart: %@", daypart);
            NSMutableArray *singleDaypart = [NSMutableArray array];
            
            for (PFObject *activeItem in activeItems) {
                //NSLog(@"active Item: %@", activeItem);
                if ([activeItem[@"distribution"] containsObject:daypart]) {
                    NSMutableDictionary *singleItemDictionary = [NSMutableDictionary dictionary];
                    [singleItemDictionary setObject:activeItem[@"itemId"] forKey:@"itemId"];
                    [singleItemDictionary setObject:activeItem[@"name"] forKey:@"name"];
                    [singleItemDictionary setObject:activeItem[@"description"] forKey:@"description"];
                    [singleItemDictionary setObject:activeItem[@"distribution"] forKey:@"distribution"];
                    [singleItemDictionary setObject:activeItem[@"station"] forKey:@"station"];

                    
                    [singleDaypart addObject:singleItemDictionary];
                }
            }
            
            [tempArray addObject:[singleDaypart copy]];
        }
        
        [itemsToReturn addObject:tempArray];
    }
    
    return [itemsToReturn copy];
}

+ (NSDictionary*)getActiveItems {
    NSMutableDictionary *itemIdsToReturn = [NSMutableDictionary dictionary];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"active" equalTo:@YES];
    NSArray *activeItems = [query findObjects];
    
    for (PFObject *activeItem in activeItems) {
        [itemIdsToReturn setObject:activeItem[@"name"] forKey:activeItem[@"itemId"]];
    }
    
    return [itemIdsToReturn copy];
}

+ (NSArray*)getFavorites {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    
    PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"WizardUser"];
    [favoriteQuery whereKey:@"WIZID" equalTo:[WizardUser getMyWIZID]];
    PFObject *existingUser = [favoriteQuery getFirstObject];
    
    NSArray *favoritesById = existingUser[@"favorites"];
    
    PFQuery *itemQuery = [PFQuery queryWithClassName:@"Item"];
    [itemQuery whereKey:@"itemId" containedIn:favoritesById];
    NSArray *favorites = [itemQuery findObjects];
    
    for (PFObject *favorite in favorites) {
        NSString *name = favorite[@"name"];
        NSNumber *Id = favorite[@"itemId"];
        
        [d setObject:name forKey:Id];
    }
    
    return [d copy];
}

+ (NSDictionary*)reverseDictionary:(NSDictionary*)input {
    
    NSMutableDictionary *d = [input mutableCopy];
    
    for (NSString *key in [d allKeys]) {
        d[d[key]] = key;
        [d removeObjectForKey:key];
    }
    return [d copy];
}

+ (NSDictionary*)getActiveItemDescriptions {
    NSMutableDictionary *itemDescriptionsToReturn = [NSMutableDictionary dictionary];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"active" equalTo:@YES];
    [query whereKey:@"description" notEqualTo:@"WizardNull"];
    NSArray *activeItems = [query findObjects];
        
    for (PFObject *activeItem in activeItems) {
        NSString *name = activeItem[@"name"];
        if (activeItem[@"description"])
            [itemDescriptionsToReturn setObject:activeItem[@"description"] forKey:name];
    }
    
    return [itemDescriptionsToReturn copy];
}
+ (NSArray*) getHours {
    NSMutableArray *hoursToReturn= [NSMutableArray array];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Hours"];
    [query whereKey:@"name" equalTo:@"cafHours"];
    PFObject *masterHours = [query getFirstObject];
    
    NSArray *distribution = masterHours[@"distribution"];
    
    for (id daypart in distribution) {
        NSMutableArray *currentDaypart = [NSMutableArray array];
        
        [currentDaypart addObject:[daypart objectAtIndex:0]];
        [currentDaypart addObject:[daypart objectAtIndex:1]];
        [hoursToReturn addObject: currentDaypart];
    }
    
    return [hoursToReturn copy];
}

+ (NSArray*)getAllItemsExcludingFavorites:(NSArray*)favorites {
    NSMutableArray *itemsToReturn = [NSMutableArray array];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query setLimit:1000];
    NSArray *items = [query findObjects];
    
    for (PFObject *item in items) {
        NSString *itemName = item[@"name"];
        if (![favorites containsObject:itemName]) {
            [itemsToReturn addObject:itemName];
        }
    }
    
    NSArray *unsortedItems = [itemsToReturn copy];
    NSArray *sortedItems = [unsortedItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    return sortedItems;
}

+ (NSMutableDictionary*)getFavoriteCountsForItems:(NSArray*)items {
    NSMutableDictionary *favoriteCountsToReturn= [NSMutableDictionary dictionary];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"active" equalTo:@YES];
    NSArray *activeItems = [query findObjects];
    
    for (PFObject *item in activeItems) {
        NSString *name = item[@"name"];
        NSNumber *count = item[@"favorites"];
        [favoriteCountsToReturn setValue:count forKey:name];
    }
    
    return favoriteCountsToReturn;
}

+ (void)addSingleItemToFavorites:(NSNumber*)itemId {
    PFQuery *query = [PFQuery queryWithClassName:@"WizardUser"];
    [query whereKey:@"WIZID" equalTo:[WizardUser getMyWIZID]];

    [query getFirstObjectInBackgroundWithBlock:^(PFObject* user, NSError *error) {
        if (!error) {
            NSMutableArray *favorites = user[@"favorites"];
            [favorites addObject:itemId];
            user[@"favorites"] = [favorites copy];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError*error) {
                [self incrementFavoriteCountForItem:itemId withCount:1];
            }];
        }
    }];
}

+ (void)deleteSingleItemFromFavorites:(NSNumber*)itemId {
    PFQuery *query = [PFQuery queryWithClassName:@"WizardUser"];
    [query whereKey:@"WIZID" equalTo:[WizardUser getMyWIZID]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject* user, NSError *error) {
        if (!error) {
            NSMutableArray *favorites = user[@"favorites"];
            [favorites removeObject:itemId];
            user[@"favorites"] = [favorites copy];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError*error) {
                [self incrementFavoriteCountForItem:itemId withCount:-1];
            }];
        }
    }];
}

+ (void)addMultipleItemsToFavorites:(NSArray*)items {
    for (NSNumber *itemId in items) {
        [self addSingleItemToFavorites:itemId];
    }
}

+ (void)incrementFavoriteCountForItem:(NSNumber*)itemId withCount:(int)count {
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"itemId" equalTo:itemId];

    [query findObjectsInBackgroundWithBlock:^(NSArray *items, NSError *error) {
        if (!error) {
            for (PFObject *item in items) {
                [item incrementKey:@"favorites" byAmount:[NSNumber numberWithInt:count]];
                [item saveInBackground];
            }
        }
    }];
}

+ (NSArray*)getRatingValues {
    NSMutableArray *ratingCountsToReturn = [NSMutableArray array];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Ratings"];

    [query addAscendingOrder:@"order"];
    NSArray *ratings = [query findObjects];
    
    for (PFObject *rating in ratings) {
        NSArray *ratingCount = rating[@"count"];
        [ratingCountsToReturn addObject:ratingCount];
    }
    
    return [ratingCountsToReturn copy];
}

+ (void)updateVoteCountForDaypart:(int)daypart withSelectedIndex:(int)selectedIndex withPreviousIndex:(int)previousIndex {

    PFQuery *query = [PFQuery queryWithClassName:@"Ratings"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *choices, NSError *error) {
        if (!error) {
            for (PFObject *choice in choices) {
                NSMutableArray *currentVoteCount = [choice[@"count"] mutableCopy];
                int oldCount = [[currentVoteCount objectAtIndex:daypart] intValue];
                int choiceIndex = [choice[@"order"] intValue];
                
                if (choiceIndex == selectedIndex) {
                    int newCount = oldCount + 1;
                    [currentVoteCount replaceObjectAtIndex:daypart withObject:[NSNumber numberWithInt:newCount]];
                    choice[@"count"] = [currentVoteCount copy];
                    [choice saveInBackground];
                }
                else if (choiceIndex == previousIndex) {
                    int newCount = oldCount - 1;
                    if (newCount >= 0) {
                        [currentVoteCount replaceObjectAtIndex:daypart withObject:[NSNumber numberWithInt:newCount]];
                        choice[@"count"] = [currentVoteCount copy];
                        [choice saveInBackground];
                    }
                }
            }
        }
    }];
}

+ (void)saveRatingValuesToParse:(NSArray*)values {
    PFQuery *query = [PFQuery queryWithClassName:@"Ratings"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *choices, NSError *error) {
        if (!error) {
            for (PFObject *choice in choices) {
                NSArray *newVoteCount = [values objectAtIndex:[choice[@"order"] integerValue]];
                choice[@"count"] = newVoteCount;
                [choice saveInBackground];
            }
        }
    }];
}

@end

//
//  WizardDB.h
//  CafWizard
//
//  Created by Miles Luders on 8/29/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface WizardDB : NSObject

+ (NSArray*)getDayparts;
+ (NSDictionary*)getActiveItems;
+ (NSArray*)getActiveItemsSortedByCafes:(NSArray*)cafes;
+ (NSDictionary*)getActiveItemDescriptions;
+ (NSArray*)getHours;
+ (NSArray*)getAllItemsExcludingFavorites:(NSArray*)favorites;
+ (NSDictionary*)getFavorites;
+ (NSMutableDictionary*)getFavoriteCountsForItems:(NSArray*)items;
+ (void)addSingleItemToFavorites:(NSNumber*)itemId;
+ (void)deleteSingleItemFromFavorites:(NSNumber*)itemId;
+ (void)addMultipleItemsToFavorites:(NSArray*)items;
+ (void)incrementFavoriteCountForItem:(NSNumber*)itemId withCount:(int)count;
+ (NSArray*)getRatingValues;
+ (void)updateVoteCountForDaypart:(int)daypart withSelectedIndex:(int)selectedIndex withPreviousIndex:(int)previousIndex;
+ (NSDictionary*)reverseDictionary:(NSDictionary*)input;
+ (void)saveRatingValuesToParse:(NSArray*)values;

@end

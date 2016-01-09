//
//  WizardTime.m
//  CafWizard
//
//  Created by Miles Luders on 8/29/15.
//  Copyright (c) 2015 Miles Luders. All rights reserved.
//

#import "WizardTime.h"

@implementation WizardTime

+ (NSString*) getCurrentTime {
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                              initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:today];
    
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    /*NSString *URL = [NSString stringWithFormat:@"http://www.timeapi.org/pst/now?\\H:\\M"];
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *text = [NSString stringWithContentsOfURL:[NSURL URLWithString:URL] encoding:NSUTF8StringEncoding error:nil];*/
    
    PFQuery *query = [PFQuery queryWithClassName:@"Time"];
    
    [query whereKey:@"name" equalTo:@"officialTime"];
    PFObject *time = [query getFirstObject];
    
    NSString *text = time[@"value"];
    
    if( !text )
    {
        return [NSString stringWithFormat:@"%ld:%ld", (long)hour, (long)minute];
    }
    else
    {
        return text;
    }
}

+ (NSString*) getCachedTime {
    NSString *cachedTime = [[NSUserDefaults standardUserDefaults] stringForKey:@"cachedTime"];
    if (cachedTime) {
        return cachedTime;
    }
    else {
        NSString *newTime = [self getCurrentTime];
        [[NSUserDefaults standardUserDefaults] setObject:newTime forKey:@"cachedTime"];
        return newTime;
    }
}

+ (void)updateCachedTime {
    NSString *newTime = [self getCurrentTime];
    [[NSUserDefaults standardUserDefaults] setObject:newTime forKey:@"cachedTime"];
}


+ (NSString*)getCurrentDaypartAsString:(NSArray*)dayparts withTimes:(NSArray*)times {
    //NSLog(@"dayparts: %@", dayparts);
    
    NSInteger daypartAsInt = [self getCurrentDaypartAsIntWithTimes:times];
    //NSLog(@"daypartAsInt boys = %ld", (long)daypartAsInt);
    
    if (daypartAsInt < 0 || daypartAsInt > 2) {
        return @"Closed";
    }
    else {
        return [NSString stringWithFormat:@"%@", [dayparts objectAtIndex:daypartAsInt]];
    }
}

+ (NSString*)getCurrentDaypartAsString:(NSArray*)dayparts withInt:(int)daypart {
    if (daypart < 0 || daypart > 2) {
        return @"Closed";
    }
    else {
        return [NSString stringWithFormat:@"%@", [dayparts objectAtIndex:daypart]];
    }
}

+ (NSInteger)getCurrentDaypartAsIntWithTimes:(NSArray*)times {
    NSString *currentTime = [WizardTime getCachedTime];
    NSArray *currentTimeSplit = [currentTime componentsSeparatedByString: @":"];
    int currentTimeHour = [[currentTimeSplit objectAtIndex:0] intValue];
    int currentTimeMinute = [[currentTimeSplit objectAtIndex:1] intValue];

    
    for (NSDictionary *cafe in times) {
        NSArray *hours = [cafe objectForKey:@"hours"];
        
        int iteration = 0;
        for (NSArray *daypart in hours) {
            NSString *startTime = [daypart objectAtIndex:0];
            NSString *endTime = [daypart objectAtIndex:1];
            
            NSArray *startTimeSplit = [startTime componentsSeparatedByString: @":"];
            NSArray *endTimeSplit = [endTime componentsSeparatedByString: @":"];
            
            int startTimeHour = [[startTimeSplit objectAtIndex:0] intValue];
            int startTimeMinute = [[startTimeSplit objectAtIndex:1] intValue];
            int endTimeHour = [[endTimeSplit objectAtIndex:0] intValue];
            int endTimeMinute = [[endTimeSplit objectAtIndex:1] intValue];
            
            if (currentTimeHour < startTimeHour) {
                if (iteration == 0) {
                    return -1;
                }
                else {
                    return -1;
                }
            }
            if (currentTimeHour == startTimeHour) {
                if (currentTimeMinute >= startTimeMinute) {
                    return (NSInteger) iteration;
                }
                else {
                    if (iteration == 0) {
                        return -1;
                    }
                }
            }
            else if (currentTimeHour > startTimeHour) {
                if (currentTimeHour < endTimeHour) {
                    return (NSInteger) iteration;
                }
                else if (currentTimeHour == endTimeHour) {
                    if (currentTimeMinute < endTimeMinute) {
                        return (NSInteger) iteration;
                    }
                }
            }
            
            iteration++;
        }
    }
    
    // We return 7 to imply that caf is closed
    return (NSInteger) 7;
}

+ (NSString*)getDateAsString:(int)day {
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"MM-dd-YYYY"];
    
    NSDate *today = [NSDate date];
    NSDate *modifiedDate = [today dateByAddingTimeInterval:day*86400];
    
    return [dateFormatter stringFromDate:modifiedDate];
}

+ (NSString*)convertMilitaryToStandard:(NSString*)time {
    //NSLog(@"time %@", time);
    NSArray *timeSplit = [time componentsSeparatedByString: @":"];
    int timeHour = [[timeSplit objectAtIndex:0] intValue];
    int timeMinute = [[timeSplit objectAtIndex:1] intValue];
    
    if (timeHour > 12) {
        int newTimeHour = timeHour - 12;
        return [NSString stringWithFormat:@"%d:%02dpm", newTimeHour, timeMinute];
    }
    else if (timeHour == 12) {
        return [NSString stringWithFormat:@"%d:%02dpm", timeHour, timeMinute];

    }
    else {
        return [NSString stringWithFormat:@"%d:%02dam", timeHour, timeMinute];
    }
}

+ (NSArray*)getHeaderDescriptionsWithDayparts:(NSArray*)dayparts {
    NSMutableArray *tempArrayOfHeaderDescriptions = [[NSMutableArray alloc] init];
    
    NSInteger currentDaypart = [self getCurrentDaypartAsIntWithTimes:dayparts];
    
    
    NSArray *hours = [[dayparts objectAtIndex:0]objectForKey:@"hours"];
    
    for (int i=0; i<hours.count; i++) {
        
        NSString *startTime = [[hours objectAtIndex:i] objectAtIndex:0];
        NSString *endTime = [[hours objectAtIndex:i] objectAtIndex:1];
        
        if (currentDaypart == i) {
            NSString *currentTime = [self getCachedTime];
            
            NSArray *currentTimeSplit = [currentTime componentsSeparatedByString: @":"];
            int currentTimeHour = [[currentTimeSplit objectAtIndex:0] intValue];
            int currentTimeMinute = [[currentTimeSplit objectAtIndex:1] intValue];
            
            NSArray *endTimeSplit = [endTime componentsSeparatedByString: @":"];
            int endTimeHour = [[endTimeSplit objectAtIndex:0] intValue];
            int endTimeMinute = [[endTimeSplit objectAtIndex:1] intValue];
            
            int hourDifference = endTimeHour - currentTimeHour;
            int minuteDifference = endTimeMinute - currentTimeMinute;
            
            int totalMinutes = (60*hourDifference + minuteDifference);
            
            float hoursAsFloat = (float) totalMinutes / 60;
            int hoursRounded = floor(hoursAsFloat);
            
            float minutesPercentage = hoursAsFloat - (float) hoursRounded;
            float minutesAsFloat = minutesPercentage * 60;
            int minutesRounded = floor(minutesAsFloat);
            
            ////NS2Log(@"minutesAsFloat: %d", minutesRounded);
            
            
            if (hoursRounded == 0) {
                [tempArrayOfHeaderDescriptions addObject:[NSString stringWithFormat:@"Ends in %dm",minutesRounded]];
            }
            else {
                [tempArrayOfHeaderDescriptions addObject:[NSString stringWithFormat:@"Ends in %dh %dm", hoursRounded, minutesRounded]];
            }
            
        }
        else if (currentDaypart > i) {
            [tempArrayOfHeaderDescriptions addObject:[NSString stringWithFormat:@"Ended"]]; //at %@", [self convertMilitaryToStandard:endTime]]];
        }
        else {
            [tempArrayOfHeaderDescriptions addObject:[NSString stringWithFormat:@"%@ - %@", [self convertMilitaryToStandard:startTime], [self convertMilitaryToStandard:endTime]]];
        }
    }
    
    return [tempArrayOfHeaderDescriptions copy];
    
}

+ (NSDate*)getYesterday {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
    
    return yesterday;
}



@end

//
//  NSDateExtensions.m
//  Deltek
//
//  Created by Jason Harwig on 3/17/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "NSDateExtensions.h"


@implementation NSDate (NSDateExtensions)


- (BOOL)isToday {    
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate todayGMT]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:self];
    NSDate *otherDate = [cal dateFromComponents:components];
    return [today isEqualToDate:otherDate];
}

+ (NSDate *)todayGMT {
    return [[NSDate date] dateByAddingTimeInterval:[[NSTimeZone defaultTimeZone] secondsFromGMT]];
}


@end

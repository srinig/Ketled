//
//  NSNumberExtensions.m
//  Deltek
//
//  Created by Jason Harwig on 3/17/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "NSNumberExtensions.h"


@implementation NSNumber (NSNumberExtensions)
- (NSDate *)dateFromMillisecondsGMT {
    double seconds = [self unsignedLongLongValue] / 1000.0;
    
    NSInteger offset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    
    seconds += offset;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}
@end

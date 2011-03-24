//
//  Account.m
//  Ketled
//
//  Created by Jason Harwig on 3/23/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "Account.h"


@implementation Account

@synthesize name, code, hours;


+ (id)accountWithJsonDictionary:(NSDictionary *)d {
    Account *inst = [[Account alloc] init];
    
    inst.name = [d objectForKey:@"name"];
    inst.code = [d objectForKey:@"code"];
    inst.hours = [d objectForKey:@"hours"];
    
    return [inst autorelease];
}

- (void)dealloc {
    [name release];
    [code release];
    [hours release];
    [super dealloc];
}

- (float)totalHours {
    float total = 0;
    for (NSNumber *hoursInDay in hours) {
        total += [hoursInDay floatValue];
    }
    return total;
}

@end

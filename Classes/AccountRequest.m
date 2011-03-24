//
//  AccountRequest.m
//  Ketled
//
//  Created by Jason Harwig on 3/23/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "AccountRequest.h"
#import "NSNumberExtensions.h"
#import "Account.h"

@implementation AccountRequest

@synthesize dateRange, accounts, required;

+ (id)accountRequestWithJsonDictionary:(NSDictionary *)json {
    AccountRequest *inst = [[AccountRequest alloc] init];
    
        
    NSArray *dateRangeNumbers = [json objectForKey:@"dateRange"];
    NSDate *d1 = [[dateRangeNumbers objectAtIndex:0] dateFromMillisecondsGMT];
    NSDate *d2 = [[dateRangeNumbers objectAtIndex:1] dateFromMillisecondsGMT];
    inst.dateRange = [NSArray arrayWithObjects:d1, d2, nil];

    NSMutableArray *mAccounts = [NSMutableArray array];
    NSArray *accountDictionaries = [json objectForKey:@"accounts"];
    for (NSDictionary *accountDictionary in accountDictionaries) {
        [mAccounts addObject:[Account accountWithJsonDictionary:accountDictionary]];
    }
    inst.accounts = mAccounts;
    
    inst.required = [[json objectForKey:@"required"] floatValue];
    
    return [inst autorelease];
}

- (void)dealloc {
    [dateRange release];
    [accounts release];
    [super dealloc];
}


- (float)totalHours {
    float total = 0;
    for (Account *account in accounts) {
        total += account.totalHours;
    }
    return total;
}

- (BOOL)isValid {
    return [self.accounts count] > 0 && [dateRange count] == 2;
}

@end

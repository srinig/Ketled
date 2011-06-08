//
//  LeaveBalance.m
//  Ketled
//
//  Created by Jason Harwig on 3/29/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "LeaveBalance.h"


@implementation LeaveBalance

@synthesize name, balance;


+ (id)leaveBalanceWithName:(NSString *)aName {
    LeaveBalance *lb = [[LeaveBalance alloc] init];
    lb.name = aName;
    lb.balance = 0.0;
    
    return lb;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %f", name, balance];
}

@end

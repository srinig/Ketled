//
//  LeaveBalance.h
//  Ketled
//
//  Created by Jason Harwig on 3/29/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LeaveBalance : NSObject {
    NSString *name;
    float balance;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) float balance;

+ (id)leaveBalanceWithName:(NSString *)aName;

@end

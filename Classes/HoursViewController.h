//
//  HoursViewController.h
//  Deltek
//
//  Created by Jason Harwig on 3/16/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HourEntryViewController.h"

@interface HoursViewController : UITableViewController <HourEntryDelegate> {
    NSDictionary *account;
    NSArray *range;
    NSUInteger accountIndex;
}

@property (nonatomic, retain) NSDictionary *account;
@property (nonatomic, retain) NSArray *range;

- (id)initWithAccount:(NSDictionary *)anAccount accountIndex:(NSUInteger)accountIndex dateRange:(NSArray *)range;

@end

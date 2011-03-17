//
//  RootViewController.h
//  Deltek
//
//  Created by Jason Harwig on 3/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountsViewController : UITableViewController {
    NSDictionary *charges;
	NSArray *accounts;    
    UIView *footerView;
    UILabel *totalHoursLabel;
    UIView *headerView;
    UIProgressView *progress;
}

@property (nonatomic, retain) NSArray *accounts;
@property (nonatomic, retain) NSDictionary *charges;
@property (nonatomic, retain) IBOutlet UIView *footerView;
@property (nonatomic, retain) IBOutlet UILabel *totalHoursLabel;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIProgressView *progress;

@end

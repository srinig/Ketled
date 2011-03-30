//
//  RootViewController.h
//  Deltek
//
//  Created by Jason Harwig on 3/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountRequest, LeaveBalanceView;

@interface AccountsViewController : UITableViewController {
    AccountRequest *accountRequest;
    NSArray *leaveBalances;
    
    UIView *footerView;
    UILabel *totalDaysLabel;
    UILabel *totalHoursLabel;
    UIView *headerView;
    UILabel *ptoLabel;
    UILabel *holidayLabel;
    UIProgressView *hoursProgress;
    UIProgressView *daysProgress;
    LeaveBalanceView *leaveBalancesView;
    UIActivityIndicatorView *leaveBalanceActivity;
}

@property (nonatomic, retain) AccountRequest *accountRequest;
@property (nonatomic, copy) NSArray *leaveBalances;
@property (nonatomic, retain) IBOutlet UIView *footerView;
@property (nonatomic, retain) IBOutlet UILabel *totalDaysLabel;
@property (nonatomic, retain) IBOutlet UILabel *totalHoursLabel;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UILabel *ptoLabel;
@property (nonatomic, retain) IBOutlet UILabel *holidayLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *hoursProgress;
@property (nonatomic, retain) IBOutlet UIProgressView *daysProgress;
@property (nonatomic, retain) IBOutlet LeaveBalanceView *leaveBalancesView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *leaveBalanceActivity;


- (IBAction)refresh;
@end

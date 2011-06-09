//
//  WeeklyViewController.m
//  Ketled
//
//  Created by David Singley on 6/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "WeeklyViewController.h"
#import "AccountRequest.h"
#import "Account.h"
#import "CellLoader.h"

@implementation WeeklyViewController
@synthesize accountsScrollView;
@synthesize daysScrollView;
@synthesize hoursScrollView;
@synthesize accountRequest;

- (id)initWithAccountRequest:(AccountRequest *)anAccountRequest {
    self = [super initWithNibName:@"WeeklyViewController" bundle:nil];
    if (self) {
        self.accountRequest = anAccountRequest;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateFormatter *weekdayDf = [[NSDateFormatter alloc] init];
    weekdayDf.timeZone = timeZone;
    [weekdayDf setDateFormat:@"EE"];
    NSDateFormatter *dateDf = [[NSDateFormatter alloc] init];
    dateDf.timeZone = timeZone;
    [dateDf setDateFormat:@"d LLL"];
    
    float accountHeight = 0;
    float y = 0;
    for (Account *account in accountRequest.accounts) {
        UILabel *accountLabel= (UILabel *)[CellLoader newCellWithType:@"WeeklyAccountCell"];
        CGRect adjusted = accountLabel.frame;
        adjusted.origin.y = y;
        y += (accountHeight = adjusted.size.height);
        adjusted.size.width = accountsScrollView.frame.size.width;
        accountLabel.frame = adjusted;
        accountLabel.text = account.name;
        [accountsScrollView addSubview:accountLabel];
    }
    accountsScrollView.contentSize = CGSizeMake(accountsScrollView.frame.size.width, y);

    NSDate *startDate = [accountRequest.dateRange objectAtIndex:0];
    NSDate *endDate = [accountRequest.dateRange objectAtIndex:1];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dayComponents = [gregorian components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
    int numberOfDays = (int)[dayComponents day] + 1;
    
    float dayTotal = 0;
    float x = 0;
    for (int i = 0; i < numberOfDays; i++) {
        UIView *dayCell = [CellLoader newCellWithType:@"WeeklyDayCell"];
        CGRect dayCellFrame = dayCell.frame;
        dayCellFrame.origin.x = x;        
        dayCell.frame = dayCellFrame;        
        [dayComponents setDay:i];
        NSDate *cellDate = [gregorian dateByAddingComponents:dayComponents toDate:startDate options:0];
        UILabel *weekdayLabel = (UILabel *)[dayCell viewWithTag:1];
        weekdayLabel.text = [weekdayDf stringFromDate:cellDate];
        UILabel *dateLabel = (UILabel *)[dayCell viewWithTag:2];
        dateLabel.text = [dateDf stringFromDate:cellDate];
        
        NSDateComponents *dayOfWeekComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:cellDate];
        if ([dayOfWeekComponents weekday] == 6 || [dayOfWeekComponents weekday] == 7) {
            dayCell.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
        } else {
            dayCell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        }
        
        [daysScrollView addSubview:dayCell];
        
        dayTotal = 0;
        y = 0;
        for (Account *account in accountRequest.accounts) {
            UILabel *hourLabel = (UILabel *)[CellLoader newCellWithType:@"WeeklyHourCell"];
            CGRect adjusted = hourLabel.frame;
            adjusted.origin.x = x;
            adjusted.origin.y = y;
            adjusted.size.height = accountHeight;
            adjusted.size.width = dayCellFrame.size.width;
            hourLabel.frame = adjusted;
            float hours = [[account.hours objectAtIndex:i] floatValue];
            dayTotal += hours;
            if (hours > 0) {
                hourLabel.text = [NSString stringWithFormat:@"%3.1f", hours];
            } else {
                hourLabel.text = @"";
            }
            
            if ([dayOfWeekComponents weekday] == 6 || [dayOfWeekComponents weekday] == 7) {
                hourLabel.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
            } else {
                hourLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            }
            
            [hoursScrollView addSubview:hourLabel];
            
            y += accountHeight;
        }
        
        // daily totals
        UILabel *hourLabel = (UILabel *)[CellLoader newCellWithType:@"WeeklyHourCell"];
        CGRect adjusted = hourLabel.frame;
        adjusted.origin.x = x;
        adjusted.origin.y = y;
        adjusted.size.height = accountHeight;
        adjusted.size.width = dayCellFrame.size.width;
        hourLabel.frame = adjusted;
        hourLabel.text = [NSString stringWithFormat:@"%3.1f", dayTotal];
        hourLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        hourLabel.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
        
        [hoursScrollView addSubview:hourLabel];
        
        y += accountHeight;
        x += dayCellFrame.size.width;
    }
    
    daysScrollView.contentSize = CGSizeMake(x, daysScrollView.frame.size.height);
    hoursScrollView.contentSize = CGSizeMake(x, y);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [self setDaysScrollView:nil];
    [self setAccountsScrollView:nil];
    [self setHoursScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationIsLandscape(interfaceOrientation);
}

- (void)orientationChanged:(NSNotification *)aNotification {
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {            
        [self dismissModalViewControllerAnimated:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == accountsScrollView) {
        // adjust hours y
        [hoursScrollView setContentOffset:CGPointMake(hoursScrollView.contentOffset.x, accountsScrollView.contentOffset.y)];
    } else if (scrollView == daysScrollView) {
        // adjust hours x
        [hoursScrollView setContentOffset:CGPointMake(daysScrollView.contentOffset.x, hoursScrollView.contentOffset.y)];
    } else if (scrollView == hoursScrollView) {
        // adjust days x
        // adjust accounts y
        [daysScrollView setContentOffset:CGPointMake(hoursScrollView.contentOffset.x, daysScrollView.contentOffset.y)];
        [accountsScrollView setContentOffset:CGPointMake(accountsScrollView.contentOffset.x, hoursScrollView.contentOffset.y)];
    }
}

@end

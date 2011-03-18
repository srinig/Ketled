//
//  HoursViewController.m
//  Deltek
//
//  Created by Jason Harwig on 3/16/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "HoursViewController.h"
#import "UITableViewCellExtensions.h"
#import "MBProgressHUD.h"
#import "DeltekService.h"

@interface HoursViewController ()
- (BOOL)isDateToday:(NSDate *)aDate;
- (NSDate *)todayGMT;
@end

@implementation HoursViewController

@synthesize account, range;

- (id)initWithAccount:(NSDictionary *)anAccount accountIndex:(NSUInteger)anAccountIndex dateRange:(NSArray *)aRange {
    self = [super init];
    if (self) {
        self.account = anAccount;
        self.range = aRange;
        accountIndex = anAccountIndex;
        self.title = [account objectForKey:@"name"];        
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidLoad {
    self.tableView.rowHeight = 63.0;
}

- (void)viewDidAppear:(BOOL)animated {
    
    
    int days = [[self todayGMT] timeIntervalSinceDate:[range objectAtIndex:0]] / SECONDS_IN_DAYS;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:days inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:indexPath 
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[account objectForKey:@"hours"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HoursCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [UITableViewCell tableViewCellFromNib:@"HoursCell" reuseIdentifier:@"HoursCell"];
        tableView.rowHeight = cell.frame.size.height;
    }
    
    NSDate *startDate = [range objectAtIndex:0];
    NSDate *cellDate = [startDate dateByAddingTimeInterval:indexPath.row * SECONDS_IN_DAYS];
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];    
    [df setDateFormat:@"EEEE"];
    UILabel *weekday = (UILabel *)[cell viewWithTag:1];
    weekday.text = [[df stringFromDate:cellDate] uppercaseString];
    
    [df setDateFormat:@"dd"];
    UILabel *day = (UILabel *)[cell viewWithTag:2];
    day.text = [df stringFromDate:cellDate];
    if ([self isDateToday:cellDate]) {
        day.textColor = self.navigationController.navigationBar.tintColor;
    } else
        day.textColor = weekday.textColor;

    
    
    [df setDateFormat:@"MMM"];
    UILabel *month = (UILabel *)[cell viewWithTag:3];
    month.text = [[df stringFromDate:cellDate] uppercaseString];    
    [df release];
    
    UILabel *hours = (UILabel *)[cell viewWithTag:4];    
    hours.text = [[[account objectForKey:@"hours"] objectAtIndex:indexPath.row] stringValue];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *hours = [[account objectForKey:@"hours"] objectAtIndex:indexPath.row];
    HourEntryViewController *vc = [[HourEntryViewController alloc] initWithAccount:account 
                                                                             hours:hours];
    vc.delegate = self;
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

- (BOOL)isDateToday:(NSDate *)aDate {    
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[self todayGMT]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:aDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    return [today isEqualToDate:otherDate];
}


#pragma mark HourEntryDelegate

- (void)hourEntryViewController:(HourEntryViewController *)vc didSelectHours:(NSString *)hours {
    
    [MBProgressHUD showHUDAddedTo:vc.view animated:YES].labelText = @"Saving";

    int dayIndex = [self.tableView indexPathForSelectedRow].row;
    
    [[DeltekService sharedInstance] saveHours:hours accountIndex:accountIndex dayIndex:dayIndex completion:^(BOOL success) {
       
        [MBProgressHUD hideHUDForView:vc.view animated:YES];
        if (success) {
                        
            NSMutableDictionary *mAccount = [NSMutableDictionary dictionaryWithDictionary:account];
            NSMutableArray *mHours = [NSMutableArray arrayWithArray:[mAccount objectForKey:@"hours"]];
            [mHours replaceObjectAtIndex:dayIndex withObject:[NSNumber numberWithFloat:[hours floatValue]]];
            [mAccount setObject:mHours forKey:@"hours"];

            self.account = [NSDictionary dictionaryWithDictionary:mAccount];
            [self.tableView reloadData];

            [self dismissModalViewControllerAnimated:YES];
        } else {
            [[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to Save" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];            
        }
    }];
}


#pragma mark Private

- (NSDate *)todayGMT {
    return [[NSDate date] dateByAddingTimeInterval:[[NSTimeZone defaultTimeZone] secondsFromGMT]];
}

@end

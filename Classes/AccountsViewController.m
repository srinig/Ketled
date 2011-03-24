//
//  RootViewController.m
//  Deltek
//
//  Created by Jason Harwig on 3/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "AccountsViewController.h"
#import "DeltekService.h"
#import "MBProgressHUD.h"
#import "HoursViewController.h"
#import "LoginController.h"
#import "AccountRequest.h"
#import "Account.h"

@implementation AccountsViewController

@synthesize accountRequest;
@synthesize footerView;
@synthesize totalDaysLabel;
@synthesize totalHoursLabel;
@synthesize headerView;
@synthesize ptoLabel;
@synthesize holidayLabel;
@synthesize hoursProgress;
@synthesize daysProgress;

- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeoutNotification:) name:REFRESH_NEEDED object:nil];    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)timeoutNotification:(NSNotification *)n {
    [self.navigationController popToViewController:self animated:YES];
    [self refresh];
}

#pragma mark -
#pragma mark View lifecycle

- (IBAction)refresh {
    if (self.modalViewController)
        [self dismissModalViewControllerAnimated:YES];
            
    headerView.hidden = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Loading";
    
	[[DeltekService sharedInstance] chargesWithCompletion:^(AccountRequest *anAccountRequest){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.accountRequest = anAccountRequest;            
        
        if ([accountRequest isValid]) {
            NSArray *dateRange = accountRequest.dateRange;
            NSDate *start = [dateRange objectAtIndex:0];
            NSDate *end = [dateRange objectAtIndex:1];
            NSTimeInterval payPeriod = [end timeIntervalSinceDate:start];
            
            // Pay Period Progress calculation
            int totalDays = payPeriod / SECONDS_IN_DAYS + 1;
            int finishedDays = [[NSDate date] timeIntervalSinceDate:start] / SECONDS_IN_DAYS;
            [daysProgress setProgress:(float)finishedDays / totalDays];
            totalDaysLabel.text = [NSString stringWithFormat:@"%i / %i days", finishedDays, totalDays];
            
            totalHoursLabel.text = [NSString stringWithFormat:@"%@ of %@ hours", 
                                    [NSNumber numberWithFloat:accountRequest.totalHours], 
                                    [NSNumber numberWithFloat:accountRequest.required]];
            [hoursProgress setProgress:accountRequest.totalHours / accountRequest.required];
            
            headerView.hidden = NO;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unknown error occurred" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];            
        }
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;        
		[self.tableView reloadData];
                
        self.tableView.tableHeaderView = headerView;                    
        self.tableView.tableFooterView = footerView;
	}];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.contentInset = UIEdgeInsetsMake(-1 * headerView.frame.size.height, 0.0f, 0.0f, 0.0f);
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"cred"]) {
        NSInvocation *i = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(refresh)]];
        [i setSelector:@selector(refresh)];
        [i setTarget:self];

        LoginController *login = [[LoginController alloc] initWithFinishedInvocation:i];
        [self presentModalViewController:login animated:YES];
        [login release];

        return;
    }  

    if (!self.accountRequest)
        [self refresh];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug_enabled"]) {
        self.navigationItem.rightBarButtonItem = 
        [[[UIBarButtonItem alloc] initWithTitle:@"Debug" 
                                          style:UIBarButtonItemStyleBordered 
                                         target:self 
                                         action:@selector(toggleWebview)] autorelease];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (accountRequest) {        
        totalHoursLabel.text = [NSString stringWithFormat:@"%@ of %@ hours", 
                                [NSNumber numberWithFloat:accountRequest.totalHours], 
                                [NSNumber numberWithFloat:accountRequest.required]];
        [hoursProgress setProgress:accountRequest.totalHours / accountRequest.required];
    }
    
    [self.tableView reloadData];
}


- (void)toggleWebview {
    UIWebView *webview = (UIWebView *)[self.view.window viewWithTag:9999];
    
    
    if (webview) {
        [webview removeFromSuperview];
    } else {
        webview = [[DeltekService sharedInstance] valueForKeyPath:@"syncronousWebView.webview"];
        
        webview.tag = 9999;
        webview.frame = CGRectOffset(CGRectInset(self.view.window.bounds, 0, 150), 0, 150);
        [self.view.window addSubview:webview];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [accountRequest.accounts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ChargeCell";
    static NSInteger HoursTag = 10;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundView = [[[UIView alloc] init] autorelease];
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        
        UIFont *font = [UIFont systemFontOfSize:18];
        CGSize sizeToFit = [@"00.00" sizeWithFont:font];
        UILabel *hours = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width - 30 - sizeToFit.width, 0, sizeToFit.width, tableView.rowHeight)];
        hours.tag = HoursTag;
        hours.font = font;
        hours.textColor = [UIColor grayColor];
        hours.backgroundColor = [UIColor clearColor];
        hours.highlightedTextColor = [UIColor whiteColor];
        hours.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        hours.textAlignment = UITextAlignmentRight;
        [cell.contentView addSubview:hours];
        [hours release];
    }

    Account *account = [accountRequest.accounts objectAtIndex:indexPath.row];
	cell.textLabel.text = account.name;
	cell.detailTextLabel.text = account.code;
	
    UILabel *hours = (UILabel *)[cell.contentView viewWithTag:HoursTag];
    hours.text = [[NSNumber numberWithFloat:account.totalHours] stringValue];
    
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    HoursViewController *hvc = [[HoursViewController alloc] initWithAccount:[accountRequest.accounts objectAtIndex:indexPath.row] 
                                                               accountIndex:indexPath.row 
                                                                  dateRange:accountRequest.dateRange];
    [self.navigationController pushViewController:hvc animated:YES];
    [hvc release];
}


#pragma mark -
#pragma mark Memory management


- (void)viewDidUnload {
    self.accountRequest = nil;
    self.footerView = nil;
    self.totalHoursLabel = nil;
    [self setHeaderView:nil];
    [self setHoursProgress:nil];
    [self setTotalDaysLabel:nil];
    [self setPtoLabel:nil];
    [self setHolidayLabel:nil];
    [self setDaysProgress:nil];
	[super viewDidUnload];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [accountRequest release];
    [footerView release];
    [totalHoursLabel release];
    [headerView release];
    [hoursProgress release];
    [totalDaysLabel release];
    [ptoLabel release];
    [holidayLabel release];
    [daysProgress release];
    [super dealloc];
}


@end


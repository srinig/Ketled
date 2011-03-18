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
#import <YAJLiOS/YAJL.h>

@implementation AccountsViewController

@synthesize accounts;
@synthesize charges;
@synthesize footerView;
@synthesize totalHoursLabel;
@synthesize headerView;
@synthesize progress;

#pragma mark -
#pragma mark View lifecycle

- (IBAction)refresh {
    if (self.modalViewController)
        [self dismissModalViewControllerAnimated:YES];
    
    [self.progress setProgress:0];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Loading";
    
	[[DeltekService sharedInstance] chargesWithCompletion:^(NSDictionary *c){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.charges = c;
		self.accounts = [c objectForKey:@"accounts"];		
        
        
        NSArray *dateRange = [c objectForKey:@"dateRange"];
        NSDate *start = [dateRange objectAtIndex:0];
        NSDate *end = [dateRange objectAtIndex:1];
        NSTimeInterval payPeriod = [end timeIntervalSinceDate:start];
        
        // Pay Period Progress calculation
        int totalDays = payPeriod / SECONDS_IN_DAYS + 1;
        int finishedDays = [[NSDate date] timeIntervalSinceDate:start] / SECONDS_IN_DAYS;
        [progress setProgress:(float)finishedDays / totalDays];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;        
		[self.tableView reloadData];
        
        if ([self.accounts count] == 0) {
            totalHoursLabel.text = @"Unable to retrieve accounts";
        } else {
            totalHoursLabel.text = [NSString stringWithFormat:@"%@ / %@ hours required", [c objectForKey:@"total"], [c objectForKey:@"required"]];
        }
        
        self.tableView.tableFooterView = footerView;
        self.tableView.tableHeaderView = headerView;                    
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

    [self refresh];

    //self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showWebView)] autorelease];
}

/*
- (void)showWebView {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view = [[DeltekService sharedInstance] valueForKeyPath:@"syncronousWebView.webview"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];                                   
    [vc release];

    vc.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideWebView)] autorelease];
    
    [self presentModalViewController:nav animated:YES];
    [nav release];
}

- (void)hideWebView {
    [self dismissModalViewControllerAnimated:YES];
}
*/

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
    return [accounts count];
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
        
        UILabel *hours = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width - 30 - 30, 0, 30, tableView.rowHeight)];
        hours.tag = HoursTag;
        hours.font = [UIFont systemFontOfSize:18];
        hours.textColor = [UIColor grayColor];
        hours.backgroundColor = [UIColor clearColor];
        hours.highlightedTextColor = [UIColor whiteColor];
        hours.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        hours.textAlignment = UITextAlignmentRight;
        [cell.contentView addSubview:hours];
        [hours release];
    }

    NSDictionary *charge = [accounts objectAtIndex:indexPath.row];
	cell.textLabel.text = [charge objectForKey:@"name"];
	cell.detailTextLabel.text = [charge objectForKey:@"code"];
	
    UILabel *hours = (UILabel *)[cell.contentView viewWithTag:HoursTag];
    hours.text = [[charge objectForKey:@"total"] stringValue];
    
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    HoursViewController *hvc = [[HoursViewController alloc] initWithAccount:[accounts objectAtIndex:indexPath.row] accountIndex:indexPath.row dateRange:[charges objectForKey:@"dateRange"]];
    [self.navigationController pushViewController:hvc animated:YES];
    [hvc release];
}


#pragma mark -
#pragma mark Memory management


- (void)viewDidUnload {
    self.accounts = nil;
    self.charges = nil;
    self.footerView = nil;
    self.totalHoursLabel = nil;
    [self setHeaderView:nil];
    [self setProgress:nil];
	[super viewDidUnload];
}


- (void)dealloc {
    [charges release];
	[accounts release];
    [footerView release];
    [totalHoursLabel release];
    [headerView release];
    [progress release];
    [super dealloc];
}


@end


//
//  HourEntryViewController.m
//  Ketled
//
//  Created by Jason Harwig on 3/17/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "HourEntryViewController.h"
#import "NSNumberExtensions.h"
#import "Account.h"

@interface HourEntryViewController ()
@property (nonatomic, retain) NSArray *pickerHours;
@property (nonatomic, retain) NSArray *pickerMinutes;
@end


@implementation HourEntryViewController

@synthesize account;
@synthesize hours;
@synthesize hourPicker;
@synthesize accountLabel;
@synthesize codeLabel;
@synthesize hourTextField;
@synthesize delegate;

@synthesize pickerHours, pickerMinutes;

- (id)initWithAccount:(Account *)anAccount hours:(NSNumber *)aHours {
    self = [super initWithNibName:@"HourEntryViewController" bundle:nil];
    if (self) {
        self.account = anAccount;
        self.hours = aHours;
    }
    return self;
}

- (void)dealloc
{
    [pickerHours release];
    [pickerMinutes release];
    [hours release];
    [account release];
    [hourPicker release];
    [accountLabel release];
    [hourTextField release];
    [codeLabel release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    accountLabel.text = account.name;
    codeLabel.text = account.code;
    NSString *hoursStr = [hours formattedNumber];
    hourTextField.text = hoursStr;    
    
    NSMutableArray *h = [NSMutableArray array];
    NSMutableArray *m = [NSMutableArray array];    
    int selectedHourRow = NSNotFound;
    int selectedMinuteRow = NSNotFound;
        
    NSRange r = [hoursStr rangeOfString:@"."];
    NSString *hourComponent = nil;
    NSString *minuteComponent = nil;
    if (r.location == NSNotFound) {
        hourComponent = hoursStr;
        minuteComponent = @"0";        
    } else {
        hourComponent = [hoursStr substringToIndex:r.location];
        minuteComponent = [hoursStr substringFromIndex:r.location+1];
    }

    for (int i = 0; i <= 10; i++) {
        NSString *hour = [NSString stringWithFormat:@"%i", i];
        [h addObject:hour];
        
        if ([hourComponent isEqualToString:hour])
            selectedHourRow = i;

        if (i < 10) {
            NSString *minute = [NSString stringWithFormat:@"%i", i];
            [m addObject:minute];          
            
            if ([minuteComponent isEqualToString:minute])
                selectedMinuteRow = i;     
        }
    }
    
    self.pickerHours = [[NSArray arrayWithArray:h] retain];
    self.pickerMinutes = [[NSArray arrayWithArray:m] retain];
    
    [hourPicker reloadAllComponents];

    if (selectedHourRow != NSNotFound)
        [hourPicker selectRow:selectedHourRow inComponent:0 animated:NO];
    
    if (selectedMinuteRow != NSNotFound)
        [hourPicker selectRow:selectedMinuteRow inComponent:2 animated:NO];    
}

- (void)viewDidUnload
{
    self.pickerHours = nil;
    self.pickerMinutes = nil;
    [self setHourPicker:nil];
    [self setAccountLabel:nil];
    [self setHourTextField:nil];
    [self setCodeLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (IBAction)done:(id)sender {
    [delegate hourEntryViewController:self didSelectHours:hourTextField.text];
}

- (IBAction)cancel:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}


#pragma mark UIPicker Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return component == 0 ? [pickerHours count] : component == 1 ? 1 : [pickerMinutes count];
}


#pragma mark UIPicker Delegate


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return component == 0 ? 100 : component == 1 ? 31 : 100;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UILabel *)label {
    if (!label) {
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, component == 1 ? 13 : 70, 44)] autorelease];
        label.textColor = component == 0 ? [UIColor blackColor] : [UIColor colorWithWhite:0.2 alpha:1.0];
        label.textAlignment = component == 2 ? UITextAlignmentLeft : UITextAlignmentRight;    
        label.font = [UIFont boldSystemFontOfSize:30];        
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = YES;
    }

    label.text = component == 0 ? [pickerHours objectAtIndex:row] : component == 1 ? @"." : [pickerMinutes objectAtIndex:row];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSString *hour = [pickerHours objectAtIndex:[pickerView selectedRowInComponent:0]];
    NSString *minute = [pickerMinutes objectAtIndex:[pickerView selectedRowInComponent:2]];
    
    if ([minute isEqualToString:@"0"])
        hourTextField.text = hour;
    else 
        hourTextField.text = [NSString stringWithFormat:@"%@.%@", hour, minute];
}

@end

//
//  HourEntryViewController.m
//  Ketled
//
//  Created by Jason Harwig on 3/17/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "HourEntryViewController.h"


@implementation HourEntryViewController
@synthesize account;
@synthesize hours;
@synthesize hourPicker;
@synthesize accountLabel;
@synthesize hourTextField;
@synthesize delegate;

- (id)initWithAccount:(NSDictionary *)anAccount hours:(NSNumber *)aHours {
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
    [hours release];
    [account release];
    [hourPicker release];
    [accountLabel release];
    [hourTextField release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    accountLabel.text = [account objectForKey:@"name"];
    hourTextField.text = [hours stringValue];
    
    NSMutableArray *h = [NSMutableArray array];
    int selectedRow = NSNotFound;
    for (int i = 0; i <= 10; i++) {
        NSString *even = [NSString stringWithFormat:@"%i", i];
        NSString *decimal = [NSString stringWithFormat:@"%i.5", i];
        [h addObject:even];
        [h addObject:decimal];
        
        if ([[hours stringValue] isEqualToString:even])
            selectedRow = i * 2;
        
        if ([[hours stringValue] isEqualToString:decimal])
            selectedRow = i * 2 + 1;
        
    }
    pickerHours = [[NSArray arrayWithArray:h] retain];
    
    [hourPicker reloadAllComponents];
    if (selectedRow != NSNotFound)
        [hourPicker selectRow:selectedRow inComponent:0 animated:NO];
}

- (void)viewDidUnload
{
    [pickerHours release];
    pickerHours = nil;
    [self setHourPicker:nil];
    [self setAccountLabel:nil];
    [self setHourTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)done:(id)sender {
    [delegate hourEntryViewController:self didSelectHours:hourTextField.text];
}

- (IBAction)cancel:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}


#pragma mark UIPicker Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pickerHours count];
}


#pragma mark UIPicker Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [pickerHours objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    hourTextField.text = [pickerHours objectAtIndex:row];
}

@end

//
//  LoginController.m
//  Deltek
//
//  Created by Jason Harwig on 3/17/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "LoginController.h"


@implementation LoginController
@synthesize url;
@synthesize login;
@synthesize password;
@synthesize domain;
@synthesize tableView;
@synthesize urlCell;
@synthesize loginCell;
@synthesize passwordCell;
@synthesize domainCell;
@synthesize finished;

- (id)initWithFinishedInvocation:(NSInvocation *)aFinished {
    self = [super initWithNibName:@"LoginController" bundle:nil];
    if (self) {
        self.finished = aFinished;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self setLogin:nil];
    [self setPassword:nil];
    [self setDomain:nil];
    [self setUrl:nil];
    [self setUrlCell:nil];
    [self setLoginCell:nil];
    [self setPasswordCell:nil];
    [self setDomainCell:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)login:(id)sender {
    if ([url.text length] == 0
        || [login.text length] == 0
        || [password.text length] == 0
        || [domain.text length] == 0) {
        return;
    }
    
    NSDictionary *cred = [NSDictionary dictionaryWithObjectsAndKeys:
                          url.text, @"url",
                          login.text, @"login",                          
                          password.text, @"password",
                          domain.text, @"domain", nil];
    [[NSUserDefaults standardUserDefaults] setValue:cred forKey:@"cred"];    
    
    [finished invoke];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    switch (indexPath.section) {
        case 0: return urlCell;
        case 1: return indexPath.row == 0 ? loginCell : indexPath.row == 1 ? passwordCell : domainCell;            
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 38)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];

    headerLabel.text = (section == 0 ? @"Deltek Url" : @"Credentials");
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    headerLabel.shadowOffset = CGSizeMake(0, -1);
    headerLabel.font = [UIFont boldSystemFontOfSize:17];
    headerLabel.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel];
    
    return containerView;    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.tableView.frame;
    CGRect activeFieldRect = [activeField convertRect:activeField.bounds toView:self.view];
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, CGPointMake(0, CGRectGetMaxY(activeFieldRect) - 5))) {
        CGPoint scrollPoint = CGPointMake(0.0, CGRectGetMaxY(activeFieldRect)-5 -kbSize.height);
        [tableView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
}
@end

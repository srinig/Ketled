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
@synthesize finished;

- (id)initWithFinishedInvocation:(NSInvocation *)aFinished {
    self = [super initWithNibName:@"LoginController" bundle:nil];
    if (self) {
        self.finished = aFinished;
    }
    return self;
}

- (void)dealloc
{
    [login release];
    [password release];
    [domain release];
    [finished release];
    [url release];
    [super dealloc];
}


- (void)viewDidUnload
{
    [self setLogin:nil];
    [self setPassword:nil];
    [self setDomain:nil];
    [self setUrl:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)login:(id)sender {
    NSDictionary *cred = [NSDictionary dictionaryWithObjectsAndKeys:
                          url.text, @"url",
                          login.text, @"login",                          
                          password.text, @"password",
                          domain.text, @"domain", nil];
    [[NSUserDefaults standardUserDefaults] setValue:cred forKey:@"cred"];    
    
    [finished invoke];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end

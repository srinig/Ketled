//
//  LoginController.h
//  Deltek
//
//  Created by Jason Harwig on 3/17/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginController : UIViewController {
    NSInvocation *finished;
    UITextField *login;
    UITextField *password;
    UITextField *domain;
    UITableView *tableView;
    UITableViewCell *urlCell;
    UITableViewCell *loginCell;
    UITableViewCell *passwordCell;
    UITableViewCell *domainCell;
    UITextField *url;
    
    UITextField *activeField;
}
@property (nonatomic, retain) IBOutlet UITextField *url;
@property (nonatomic, retain) IBOutlet UITextField *login;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UITextField *domain;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UITableViewCell *urlCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *loginCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *domainCell;



@property (nonatomic, retain) NSInvocation *finished;


- (id)initWithFinishedInvocation:(NSInvocation *)aFinished;
- (IBAction)login:(id)sender;

@end

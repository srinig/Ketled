//
//  WeeklyViewController.h
//  Ketled
//
//  Created by David Singley on 6/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountRequest;

@interface WeeklyViewController : UIViewController {
    UIScrollView *daysScrollView;
    UIScrollView *hoursScrollView;
    UIScrollView *accountsScrollView;
    AccountRequest *accountRequest;
}

@property (nonatomic, strong) IBOutlet UIScrollView *accountsScrollView;

@property (nonatomic, strong) IBOutlet UIScrollView *daysScrollView;

@property (nonatomic, strong) IBOutlet UIScrollView *hoursScrollView;

@property (nonatomic, strong) AccountRequest *accountRequest;

- (id)initWithAccountRequest:(AccountRequest *)anAccountRequest;

@end

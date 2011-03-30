//
//  DeltekService.h
//  Deltek
//
//  Created by Jason Harwig on 3/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SynchronousWebView, AccountRequest;

@interface DeltekService : NSObject<UIWebViewDelegate> {
    NSThread *workerThread;
    SynchronousWebView *syncronousWebView;
}

+ (id)sharedInstance;

- (void)chargesWithCompletion:(void(^)(AccountRequest *request)) block;
- (void)saveHours:(NSString *)hours accountIndex:(NSUInteger)accountIndex dayIndex:(NSUInteger)dayIndex completion:(void(^)(BOOL success, NSString *errorMessage))completion;
- (void)leaveBalacesWithCompletion:(void(^)(NSArray *leaveBalances)) block;
@end

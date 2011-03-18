//
//  DeltekService.h
//  Deltek
//
//  Created by Jason Harwig on 3/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SynchronousWebView;

@interface DeltekService : NSObject<UIWebViewDelegate> {
    NSThread *workerThread;
    SynchronousWebView *syncronousWebView;
}

+ (id)sharedInstance;

- (void)chargesWithCompletion:(void(^)(NSDictionary *charges)) block;
- (void)saveHours:(NSString *)hours accountIndex:(NSUInteger)accountIndex dayIndex:(NSUInteger)dayIndex completion:(void(^)(BOOL success))completion;
@end

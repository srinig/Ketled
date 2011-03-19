//
//  DeltekService.m
//  Deltek
//
//  Created by Jason Harwig on 3/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "DeltekService.h"
#import "SynchronousWebView.h"
#import "NSNumberExtensions.h"
#import <YAJLiOS/YAJL.h>

#define RETRY_COUNT 4

@implementation DeltekService

+ (id)sharedInstance {
    static DeltekService *sharedInstance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [DeltekService alloc];
        sharedInstance = [sharedInstance init];
    });
    return sharedInstance;
}


- (id) init
{
	self = [super init];
	if (self != nil) {
        workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        [workerThread start];
	}
	return self;
}

- (void) dealloc
{
	[syncronousWebView release];
	[super dealloc];
}

- (void)run {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    syncronousWebView = [[SynchronousWebView alloc] init];
    while (YES) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    }         
    [pool drain];
}


- (void)saveHours:(NSString *)hours accountIndex:(NSUInteger)accountIndex dayIndex:(NSUInteger)dayIndex completion:(void(^)(BOOL success, NSString *errorMessage))completion {

    if ([NSThread currentThread] != workerThread) {        
		completion = [[completion copy] autorelease];
        
        NSInvocation *i = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:_cmd]];
        [i setSelector:_cmd];
        [i setTarget:self];
        [i setArgument:&hours atIndex:2];
        [i setArgument:&accountIndex atIndex:3];
        [i setArgument:&dayIndex atIndex:4];
        [i setArgument:&completion atIndex:5];
        [i retainArguments];                
        [i performSelector:@selector(invoke) onThread:workerThread withObject:nil waitUntilDone:NO];
        return;
    }

    NSDictionary *input = [NSDictionary dictionaryWithObjectsAndKeys:
                           hours, @"hours",
                           [NSString stringWithFormat:@"%u", accountIndex], @"accountIndex", 
                           [NSString stringWithFormat:@"%u", dayIndex], @"dayIndex", nil];
    
    [syncronousWebView resultFromScript:@"saveHours" input:input];
    BOOL success = [syncronousWebView waitForElement:@"modalFrame" inFrame:@"unitFrame"];    

    NSString *errorMessage = nil;
    if (success) {
        // Check for errors popup
                
        NSString *successJson;
        int try = -10;
        do {
            successJson = [syncronousWebView resultFromScript:@"saveResult" input:nil];
            [NSThread sleepForTimeInterval:0.5];
        } while ([successJson length] == 0 && ++try <= RETRY_COUNT);
        
        NSDictionary *resultDict = [successJson yajl_JSON];
        success = resultDict != nil && [[resultDict objectForKey:@"success"] boolValue];
        
        if (!success) {
            errorMessage = [resultDict objectForKey:@"message"];
            if (!errorMessage)
                errorMessage = @"Unknown Error Occured";            
        }
    }
    
    if (completion) 
        dispatch_async(dispatch_get_main_queue(), ^{ completion(success, errorMessage); });
}

- (void)chargesWithCompletion:(void(^)(NSDictionary *charges)) block {
    
	if ([NSThread currentThread] != workerThread) {        
		block = [[block copy] autorelease];
        // reset webview
        syncronousWebView.webview = nil;
        [self performSelector:_cmd onThread:workerThread withObject:block waitUntilDone:NO];
        return;
    }

    NSDictionary *cred = [[NSUserDefaults standardUserDefaults] objectForKey:@"cred"];
    [syncronousWebView load:[cred objectForKey:@"url"]];
    [syncronousWebView resultFromScript:@"login" input:cred];
    
    
    [syncronousWebView waitForElement:@"menu_1" inFrame:@"navigationFrame"];
    [syncronousWebView resultFromScript:@"navigateTimesheet" input:nil];
        
    if ([syncronousWebView waitForElement:@"udtColumn0" inFrame:@"unitFrame"]) {
 
        NSString *accountsJson;
        int try = 1;
        do {
            accountsJson = [syncronousWebView resultFromScript:@"queryPage" input:nil];
            [NSThread sleepForTimeInterval:1.0];
        } while ([accountsJson length] == 0 && ++try <= RETRY_COUNT);
        
        
        NSDictionary *accounts = [accountsJson yajl_JSON];

        NSDate *d1 = [[[accounts objectForKey:@"dateRange"] objectAtIndex:0] dateFromMillisecondsGMT];
        NSDate *d2 = [[[accounts objectForKey:@"dateRange"] objectAtIndex:1] dateFromMillisecondsGMT];
        
        [accounts setValue:[NSArray arrayWithObjects:d1, d2, nil] forKey:@"dateRange"];
        
        if (block) 
            dispatch_async(dispatch_get_main_queue(), ^{ block(accounts); });
    }        
}

@end

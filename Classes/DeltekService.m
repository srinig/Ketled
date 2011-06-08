//
//  DeltekService.m
//  Deltek
//
//  Created by Jason Harwig on 3/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "DeltekService.h"
#import "SynchronousWebView.h"
#import "AccountRequest.h"
#import "LeaveBalance.h"
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


- (void)run {
    @autoreleasepool {
        syncronousWebView = [[SynchronousWebView alloc] init];
        while (YES) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
        }         
    }
}


- (void)saveHours:(NSString *)hours accountIndex:(NSUInteger)accountIndex dayIndex:(NSUInteger)dayIndex completion:(void(^)(BOOL success, NSString *errorMessage))completion {

    if ([NSThread currentThread] != workerThread) {        
		completion = [completion copy];
        
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
        int try = 1;
        do {
            successJson = [syncronousWebView resultFromScript:@"saveResult" input:nil];
            [NSThread sleepForTimeInterval:1.0];
        } while ([successJson length] == 0 && ++try <= 30);
        
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

- (void)leaveBalacesWithCompletion:(void(^)(NSArray *leaveBalances)) block {
    if ([NSThread currentThread] != workerThread) {        
		block = [block copy];
        [self performSelector:_cmd onThread:workerThread withObject:block waitUntilDone:NO];
        return;
    }

    [syncronousWebView resultFromScript:@"leaveBalancePopup" input:nil];
    
    [syncronousWebView waitForElement:@"TsLeaveForm" 
                       fromWindowPath:@"window.frames['unitFrame'].window.frames['modalFrame'].window"];

    NSString *leaveBalanceJson;
    int try = 1;
    do {
        leaveBalanceJson = [syncronousWebView resultFromScript:@"leaveBalanceNames" input:nil];
        [NSThread sleepForTimeInterval:1.0];
    } while ([leaveBalanceJson length] == 0 && ++try <= RETRY_COUNT);
    
    NSArray *leaveBalanceNames = [leaveBalanceJson yajl_JSON];
            
    if ([leaveBalanceNames count] > 0) {
        NSString *json;
        
        NSMutableArray *balances = [NSMutableArray array];
        for (NSString *name in leaveBalanceNames) {
            [balances addObject:[LeaveBalance leaveBalanceWithName:name]];
        }
        
        for (LeaveBalance *balance in balances) {
            
            int try = 1;
            do {
                json = [syncronousWebView resultFromScript:@"leaveBalanceCheck" 
                                                     input:[NSDictionary dictionaryWithObject:balance.name
                                                                                       forKey:@"balanceName"]];                
                if ([json length] == 0) {
                    [NSThread sleepForTimeInterval:1.0];
                    [syncronousWebView waitForElement:@"balance" 
                                       fromWindowPath:@"window.frames['unitFrame'].window.frames['modalFrame'].window"];                                        
                }
                try--;
            } while ([json length] == 0 && try >= 0);
            
            balance.balance = [json floatValue];                                    
        }
        
        if (block) 
            dispatch_async(dispatch_get_main_queue(), ^{ block(balances); });
    }
}

- (void)chargesWithCompletion:(void(^)(AccountRequest *request)) block {
    
	if ([NSThread currentThread] != workerThread) {        
		block = [block copy];
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
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LAST_LOGIN_DATE];
    
    
    if ([syncronousWebView waitForElement:@"udt0_0" inFrame:@"unitFrame"]) {        
        NSString *accountsJson;
        int try = 1;
        do {
            accountsJson = [syncronousWebView resultFromScript:@"queryPage" input:nil];
            [NSThread sleepForTimeInterval:1.0];
        } while ([accountsJson length] == 0 && ++try <= RETRY_COUNT);
        
        
        NSDictionary *accounts = [accountsJson yajl_JSON];
        
        AccountRequest *request = [AccountRequest accountRequestWithJsonDictionary:accounts];
        
        if (block) 
            dispatch_async(dispatch_get_main_queue(), ^{ block(request); });
    }        
}

@end

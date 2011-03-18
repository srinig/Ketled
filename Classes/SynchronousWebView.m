//
//  SynchronousWebView.m
//  Deltek
//
//  Created by Jason Harwig on 3/15/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "SynchronousWebView.h"

#define LOG_BEGIN    NSLog(@"    BEGIN> %@", NSStringFromSelector(_cmd));
#define LOG_FINISHED NSLog(@" FINISHED> %@", NSStringFromSelector(_cmd));

@implementation SynchronousWebView

@synthesize webview;

- (void)reset {
    finished = NO;
    webViewLoads = 0;    
}

- (void)load:(NSString *)url {  
    LOG_BEGIN
    [self reset];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    });
    
    while (!finished) {
        [NSThread sleepForTimeInterval:1];
    }
    
    LOG_FINISHED
}


- (void)waitForPageLoad {
    LOG_BEGIN
    [self reset];

    while (!finished) {
        [NSThread sleepForTimeInterval:1];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = [webview stringByEvaluatingJavaScriptFromString:@"document.title"];
        NSLog(@"title = %@", title);
    });
    
    
    LOG_FINISHED
}


- (BOOL)waitForElement:(NSString *)ident inFrame:(NSString *)frameId {
    __block BOOL exists = NO;
    __block BOOL success = YES;

    int tryTimes = 30;
    while (!exists) {        
        dispatch_group_t group = dispatch_group_create();    
        dispatch_group_async(group, dispatch_get_main_queue(), ^{        
            NSString *js = [NSString stringWithFormat:@"var el = window.frames['%@'].window.document.getElementById('%@'); el.tagName", frameId, ident];
            
            id response = [webview stringByEvaluatingJavaScriptFromString:js];
                    
            exists = ![response isEqualToString:@""];
        });        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        if (!exists && --tryTimes == 0) {
            break;
            success = NO;
        }
        [NSThread sleepForTimeInterval:1];
    }  
    
    return success;
}

- (id)resultFromScript:(NSString *)scriptName input:(NSDictionary *)input {
    LOG_BEGIN
    [self reset];

    __block NSString *result = nil;
    
    dispatch_group_t group = dispatch_group_create();    
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
        NSURL *url = [[NSBundle mainBundle] URLForResource:scriptName withExtension:@"js"];
        NSString *s = [[[NSString alloc] initWithContentsOfURL:url] autorelease];
        
        // replace $ with getbyid
        s = [s stringByReplacingOccurrencesOfString:@"$" withString:@"document.getElementById"];				 

        // Wrap in try catch
        s = [NSString stringWithFormat:@"try { %@ } catch (e) { alert (e.message); }", s];
        
        if (input) {
            for (NSString *inputKey in [input allKeys]) {
                s = [s stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"#{%@}", inputKey] withString:[input valueForKey:inputKey]];																											   
            }
        }
        
        result = [[webview stringByEvaluatingJavaScriptFromString:s] retain];
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
    LOG_FINISHED
    
    return [result autorelease];
}


- (UIWebView *)webview {
    if (!webview) {
        webview = [[UIWebView alloc] init];
		webview.delegate = self;
    }
    
    return webview;
}


#pragma mark Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	webViewLoads++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	webViewLoads--;
	if (webViewLoads > 0) {
		return;
	}

    finished = YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    finished = YES;
}

@end

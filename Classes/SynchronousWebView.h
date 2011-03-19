//
//  SynchronousWebView.h
//  Deltek
//
//  Every call blocks until completion. Call on background thread!
//  All UIWebView calls happen on the main thread
//
//  Created by Jason Harwig on 3/15/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SynchronousWebView : NSObject<UIWebViewDelegate> {
 	UIWebView *webview;  
    uint webViewLoads;
    BOOL finished;
}

@property (nonatomic, retain) UIWebView *webview;

- (void)load:(NSString *)url;
- (id)resultFromScript:(NSString *)scriptName input:(NSDictionary *)input;

- (BOOL)waitForElement:(NSString *)ident fromWindowPath:(NSString *)windowPath;
- (BOOL)waitForElement:(NSString *)ident inFrame:(NSString *)frameId;
@end

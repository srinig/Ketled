//
//  SynchronousWebView.h
//  Deltek
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
- (void)waitForPageLoad;
- (BOOL)waitForElement:(NSString *)ident inFrame:(NSString *)frameId;
@end

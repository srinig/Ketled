//
//  DeltekAppDelegate.h
//  Deltek
//
//  Created by Jason Harwig on 3/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeltekAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end


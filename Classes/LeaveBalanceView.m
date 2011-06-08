//
//  LeaveBalanceView.m
//  Ketled
//
//  Created by Jason Harwig on 3/29/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "LeaveBalanceView.h"
#import "LeaveBalance.h"
#import "NSNumberExtensions.h"

@implementation LeaveBalanceView

@synthesize leaveBalances;


- (void)setLeaveBalances:(NSArray *)newLeaveBalances {
    if (leaveBalances != newLeaveBalances) {
        leaveBalances = [newLeaveBalances copy];
                
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        for (LeaveBalance *leaveBalance in leaveBalances) {
            UILabel *nameLabel = [[UILabel alloc] init];
            nameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            nameLabel.text = leaveBalance.name;
            nameLabel.font = [UIFont systemFontOfSize:11.0];
            nameLabel.textColor = [UIColor colorWithWhite:0.33 alpha:1.0];  
            nameLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
            nameLabel.shadowOffset = CGSizeMake(0, 1);
            nameLabel.backgroundColor = [UIColor clearColor];
            
            UILabel *balanceLabel = [[UILabel alloc] init];
            balanceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            balanceLabel.text = [[NSNumber numberWithFloat:leaveBalance.balance] formattedNumber];
            balanceLabel.font = [UIFont boldSystemFontOfSize:11.0];
            balanceLabel.textColor = [UIColor colorWithWhite:0.33 alpha:1.0];
            balanceLabel.textAlignment = UITextAlignmentRight;
            balanceLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
            balanceLabel.shadowOffset = CGSizeMake(0, 1);
            balanceLabel.backgroundColor = [UIColor clearColor];
            
            UIView *combined = [[UIView alloc] init];       
            combined.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            combined.frame = CGRectMake(0, 0, self.bounds.size.width, 18);
            nameLabel.frame = CGRectMake(self.bounds.size.width - 100, 0, 100, 18);
            balanceLabel.frame = CGRectMake(0, 0, self.bounds.size.width - 100 - 8, 18);
            [combined addSubview:nameLabel];
            [combined addSubview:balanceLabel];
            
            [self addSubview:combined];
        }
        [self setNeedsLayout];                
    }

}

- (void)layoutSubviews {
    [super layoutSubviews];
    float y = 0.0;
    for (UIView *view in self.subviews) {
        CGRect frame = view.frame;
        frame.origin.y = y;
        view.frame = frame;
        
        y += 18/*height*/ + 8 /*padding*/;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.bounds.size.width, [self.leaveBalances count] * (18 + 8));
}


@end

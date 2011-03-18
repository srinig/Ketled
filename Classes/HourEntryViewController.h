//
//  HourEntryViewController.h
//  Ketled
//
//  Created by Jason Harwig on 3/17/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HourEntryViewController;
@protocol HourEntryDelegate <NSObject>
- (void)hourEntryViewController:(HourEntryViewController *)vc didSelectHours:(NSString *)hours;
@end


@interface HourEntryViewController : UIViewController<UIPickerViewDataSource> {
    NSDictionary *account;
    NSNumber *hours;
    id<HourEntryDelegate> delegate;
    UIPickerView *hourPicker;
    UILabel *accountLabel;
    UILabel *codeLabel;
    UITextField *hourTextField;
    
    NSArray *pickerHours;
    NSArray *pickerMinutes;
}
@property (nonatomic, retain) IBOutlet UIPickerView *hourPicker;
@property (nonatomic, retain) IBOutlet UILabel *accountLabel;
@property (nonatomic, retain) IBOutlet UILabel *codeLabel;
@property (nonatomic, retain) IBOutlet UITextField *hourTextField;

@property (nonatomic, retain) NSDictionary *account;
@property (nonatomic, retain) NSNumber *hours;

@property (nonatomic, assign) id<HourEntryDelegate> delegate;

- (id)initWithAccount:(NSDictionary *)anAccount hours:(NSNumber *)aHours;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
@end

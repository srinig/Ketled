//
//  CellLoader.h
//  Ketled
//
//  Created by David Singley on 6/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellLoader : NSObject {
    UIView *cell;
}

@property (nonatomic, strong) IBOutlet UIView *cell;

+ (UIView *)newCellWithType:(NSString *)cellType;

@end

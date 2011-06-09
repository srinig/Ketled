//
//  CellLoader.m
//  Ketled
//
//  Created by David Singley on 6/8/11.
//  Copyright 2011 Near Infinity Corporation. All rights reserved.
//

#import "CellLoader.h"

@implementation CellLoader
@synthesize cell;

+ (UIView *)newCellWithType:(NSString *)cellType
{
    CellLoader *loader = [[CellLoader alloc] init];
    [[NSBundle mainBundle] loadNibNamed:cellType owner:loader options:nil];    
    return loader.cell;
}

@end

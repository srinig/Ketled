
#import "UITableViewCellExtensions.h"


@implementation UITableViewCell (UITableViewCellExtensions)
+ (UITableViewCell *)tableViewCellFromNib:(NSString *)nib reuseIdentifier:(NSString *)reuseId {
    UIViewController *tempViewController = [[UIViewController alloc] initWithNibName:nib bundle:nil];
    UITableViewCell *cell = (UITableViewCell *)tempViewController.view;

    NSAssert([reuseId isEqual:cell.reuseIdentifier], @"resuse identifier does not match nib"); 
    return cell;
}
@end

#import <Foundation/Foundation.h>

@class DSCellPath;

typedef void (^cellToggleBlock)(UITableViewCell *cell, BOOL expanded);

@interface DSNestedAccordionHandler : NSObject <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) UITableView *tableView;
@property(copy, nonatomic) cellToggleBlock cellToggleBlock;

- (void)reload;

- (void)closeOpenCells;

- (void)tableView:(UITableView *)tableView toggleAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView toggleAtPath:(DSCellPath *)path;

- (NSInteger)noOfRowsInRootLevel;

- (NSInteger)tableView:(UITableView *)view noOfChildRowsForCellAtPath:(DSCellPath *)path;

- (UITableViewCell *)tableView:(UITableView *)view cellForPath:(DSCellPath *)path;

- (DSCellPath *)cellPathForIndexPath:(NSIndexPath *)indexPath;

@end

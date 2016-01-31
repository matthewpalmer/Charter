#import "DSNestedAccordionHandler.h"
#import "DSCellPath.h"
#import "DSCellLevel.h"
#import "NSException+DSException.h"

@implementation DSNestedAccordionHandler {
    DSCellLevel *topCellLevel;
}

- (id)init{
    self = [super init];
    if (self) {
        topCellLevel = [[DSCellLevel alloc] initWithCellCount:[self noOfRowsInRootLevel] openCellIndex:-1 childLevel:nil];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [topCellLevel nestedCellCount];
}

- (void)reload {
    [topCellLevel reset];
    [topCellLevel setCellCount:[self noOfRowsInRootLevel]];
    [_tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView cellForPath:[topCellLevel pathToCellAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView toggleAtIndexPath:indexPath];
}

- (void)closeOpenCells {
    if ([topCellLevel hasOpenCell]) {
        NSIndexPath *openCellIndexPath = [NSIndexPath indexPathForRow:[topCellLevel openCellIndex] inSection:0];
        [self tableView:_tableView toggleAtIndexPath:openCellIndexPath];
    }
}

- (void)tableView:(UITableView *)tableView toggleAtPath:(DSCellPath *)path {
    DSCellLevel *level = [topCellLevel getLeafLevel:path];

    NSInteger indexOfClickedCellWithinLevel = [[path.levelIndexes lastObject] integerValue];

    if ([level hasOpenChildLevelAtIndex:indexOfClickedCellWithinLevel]) {
        [self deleteFrom:tableView childLevelOfLevel:level atIndex:[topCellLevel flattenedIndexOfCellInLevel:level atIndex:indexOfClickedCellWithinLevel]];

    } else {
        if ([level hasOpenChildLevelButAtDifferentIndex:indexOfClickedCellWithinLevel]) {
            [self deleteFrom:tableView childLevelOfLevel:level atIndex:[topCellLevel flattenedIndexOfExpandedCellInLevel:level]];
        }
        NSInteger rowCount = [self tableView:tableView noOfChildRowsForCellAtPath:path];

        [self insertInto:tableView itemsOfCount:rowCount atIndex:indexOfClickedCellWithinLevel withinLevel:level];

        NSInteger indexFromRootLevel = [topCellLevel flattenedIndexOfCellInLevel:level atIndex:indexOfClickedCellWithinLevel];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexFromRootLevel inSection:0];

        [tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

        if (self.cellToggleBlock) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:newIndexPath];
            self.cellToggleBlock(cell, YES);
        }
    }
}

- (void)tableView:(UITableView *)tableView toggleAtIndexPath:(NSIndexPath *)indexPath {
    DSCellPath *path = [self cellPathForIndexPath:indexPath];
    [self tableView:tableView toggleAtPath:path];
}

- (DSCellPath *)cellPathForIndexPath:(NSIndexPath *)indexPath {
    return [topCellLevel pathToCellAtIndex:indexPath.row];;
}

- (void)insertInto:(UITableView *)tableView itemsOfCount:(NSInteger)rowCount atIndex:(NSInteger)index withinLevel:(DSCellLevel *)level {
    [level addChildLevelWithCellCount:rowCount atIndex:index];
    NSInteger indexFromRootLevel = [topCellLevel flattenedIndexOfCellInLevel:level atIndex:index];
    [tableView insertRowsAtIndexPaths:[self indexPathsForCellCount:level.childLevel.cellCount startingFromIndex:indexFromRootLevel] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deleteFrom:(UITableView *)tableView childLevelOfLevel:(DSCellLevel *)level atIndex:(NSInteger)index {
    NSInteger noOfCellsToRemove = [level removeChildLevel];
    [tableView deleteRowsAtIndexPaths:[self indexPathsForCellCount:noOfCellsToRemove startingFromIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    if (self.cellToggleBlock) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        self.cellToggleBlock(cell, NO);
    }
}

- (NSMutableArray *)indexPathsForCellCount:(NSInteger)count startingFromIndex:(NSInteger)index {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:++index inSection:0]];
    }
    return indexPaths;
}

- (NSInteger)noOfRowsInRootLevel {
    @throw [NSException dsMethodNotOverridden:NSStringFromSelector(_cmd)];
}

- (NSInteger)tableView:(UITableView *)view noOfChildRowsForCellAtPath:(DSCellPath *)path {
    @throw [NSException dsMethodNotOverridden:NSStringFromSelector(_cmd)];
}

- (UITableViewCell *)tableView:(UITableView *)view cellForPath:(DSCellPath *)path {
    @throw [NSException dsMethodNotOverridden:NSStringFromSelector(_cmd)];
}

@end
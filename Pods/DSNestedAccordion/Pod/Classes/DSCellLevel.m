#import "DSCellLevel.h"
#import "DSCellPath.h"
#import "DSCellPathTracker.h"

@implementation DSCellLevel
- (id)initWithCellCount:(NSInteger)cellCount openCellIndex:(NSInteger)openCellIndex childLevel:(DSCellLevel *)childLevel {
    self = [super init];
    if (self) {
        _cellCount = cellCount;
        _openCellIndex = openCellIndex;
        _childLevel = childLevel;
    }
    return self;
}

- (void)reset {
    _cellCount = 0;
    _openCellIndex = -1;
    _childLevel = nil;
}

- (bool)hasOpenCell {
    return _openCellIndex != -1;
}

- (NSInteger)noOfCellsBeforeAndIncludingOpenCell {
    return [self hasOpenCell] ? _openCellIndex + 1 : _cellCount;
}

- (NSInteger)noOfCellsAfterOpenCell {
    return [self hasOpenCell] ? _cellCount - (_openCellIndex + 1) : 0;
}

- (DSCellPath *)pathToCellAtIndex:(NSInteger)cellIndex {
    return [self findCellPath:[[DSCellPathTracker alloc] initWithFlattenedCellIndex:cellIndex]];
}

- (NSInteger)nestedCellCount {
    NSInteger noOfCells = self.cellCount;
    DSCellLevel *cellLevel = self;
    while (cellLevel.childLevel != nil) {
        noOfCells = noOfCells + cellLevel.childLevel.cellCount;
        cellLevel = cellLevel.childLevel;
    }
    return noOfCells;
}


- (DSCellPath *)findCellPath:(DSCellPathTracker *)pathTracker {
    NSInteger noOfCells = MIN(pathTracker.flattenedCellIndex + 1, [self noOfCellsBeforeAndIncludingOpenCell]);
    [pathTracker visitedCellsInNewLevel:noOfCells];

    if ([pathTracker haveNotFoundPathYet]) {
        if (_childLevel != nil) {
            [_childLevel findCellPath:pathTracker];

            if ([pathTracker haveNotFoundPathYet]) {
                noOfCells = MIN(pathTracker.flattenedCellIndex + 1, [self noOfCellsAfterOpenCell]);
                [pathTracker visitedCellsInLeafLevel:noOfCells];
            }
        }

        if ([pathTracker haveNotFoundPathYet]) {
            [pathTracker removeLastPath];
        }
    }
    return pathTracker.cellPath;
}

- (DSCellLevel *)getLeafLevel:(DSCellPath *)path {
    int level = 1;
    DSCellLevel *cellLevel = self;
    while (level++ < path.levelIndexes.count) {
        cellLevel = cellLevel.childLevel;
    }
    return cellLevel;
}

- (void)addChildLevelWithCellCount:(NSInteger)cellCount atIndex:(NSInteger)index {
    _childLevel = [[DSCellLevel alloc] initWithCellCount:cellCount openCellIndex:-1 childLevel:nil];
    _openCellIndex = index;

}

- (NSInteger)removeChildLevel {
    NSInteger noOfCellsRemoved = [_childLevel nestedCellCount];
    _childLevel = nil;
    _openCellIndex = -1;
    return noOfCellsRemoved;
}

- (BOOL)hasOpenChildLevelAtIndex:(NSInteger)cellIndex {
    return [self hasOpenCell] && _openCellIndex == cellIndex;
}

- (BOOL)hasOpenChildLevelButAtDifferentIndex:(NSInteger)cellIndex {
    return [self hasOpenCell] && _openCellIndex != cellIndex;
}

- (NSInteger)flattenedIndexOfExpandedCellInLevel:(DSCellLevel *)level {
    DSCellLevel *currentLevel = self;
    NSInteger count = 0;

    while (currentLevel != level) {
        count = count + [currentLevel noOfCellsBeforeAndIncludingOpenCell];
        currentLevel = currentLevel.childLevel;
    }
    return count + [currentLevel noOfCellsBeforeAndIncludingOpenCell] - 1;
}

- (NSInteger)flattenedIndexOfCellInLevel:(DSCellLevel *)level atIndex:(NSInteger)cellIndex {

    if (self == level)
        return cellIndex;

    DSCellLevel *currentLevel = self;
    NSInteger count = 0;

    while (currentLevel.childLevel != level) {
        count = count + [currentLevel noOfCellsBeforeAndIncludingOpenCell];
        currentLevel = currentLevel.childLevel;
    }
    return count + [currentLevel noOfCellsBeforeAndIncludingOpenCell] + cellIndex;
}

@end
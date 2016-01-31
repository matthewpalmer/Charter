#import "DSCellPathTracker.h"
#import "DSCellPath.h"

@implementation DSCellPathTracker

- (id)initWithFlattenedCellIndex:(NSInteger)flattenedCellIndex {
    self = [super init];
    if (self) {
        _flattenedCellIndex = flattenedCellIndex;
        _cellPath = [[DSCellPath alloc] init];
    }
    return self;
}

- (void)visitedCellsInLeafLevel:(NSInteger)cellCount {
    _flattenedCellIndex = _flattenedCellIndex - cellCount;
    [_cellPath addToLastPath:cellCount];
}

- (BOOL)haveNotFoundPathYet {
    return _flattenedCellIndex != -1;
}

- (void)visitedCellsInNewLevel:(NSInteger)cellCount {
    _flattenedCellIndex = _flattenedCellIndex - cellCount;
    [_cellPath addToPath:cellCount - 1];
}

- (void)removeLastPath {
    [_cellPath removeLastPath];
}

@end
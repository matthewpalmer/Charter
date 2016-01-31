#import "DSCellPath.h"

@implementation DSCellPath

- (id)init{
    self = [super init];
    if(self){
        _levelIndexes = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addToPath:(NSInteger) path{
    [_levelIndexes addObject:@(path)];
}

- (void)removeLastPath {
    [_levelIndexes removeLastObject];
}

- (void)addToLastPath:(NSInteger)noOfCells {
    _levelIndexes[_levelIndexes.count - 1] = @([_levelIndexes[_levelIndexes.count - 1] intValue] + noOfCells);
}

@end
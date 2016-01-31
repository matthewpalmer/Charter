#import <Foundation/Foundation.h>

@class DSCellPath;

@interface DSCellPathTracker : NSObject

@property(nonatomic) NSInteger flattenedCellIndex;

@property(nonatomic, strong) DSCellPath *cellPath;

- (id)initWithFlattenedCellIndex:(NSInteger)flattenedCellIndex;

- (void)visitedCellsInLeafLevel:(NSInteger)cellCount;

- (BOOL)haveNotFoundPathYet;

- (void)visitedCellsInNewLevel:(NSInteger)cellCount;

- (void)removeLastPath;

@end

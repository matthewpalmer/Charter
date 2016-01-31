#import <Foundation/Foundation.h>

@class DSCellPath;

@interface DSCellLevel : NSObject

@property(nonatomic) NSInteger cellCount;

@property(nonatomic, strong) DSCellLevel *childLevel;

@property(nonatomic) NSInteger openCellIndex;

- (id)initWithCellCount:(NSInteger)cellCount openCellIndex:(NSInteger)openCellIndex childLevel:(DSCellLevel *)childLevel;

- (DSCellPath *)pathToCellAtIndex:(NSInteger)cellIndex;

- (NSInteger)nestedCellCount;

- (DSCellLevel *)getLeafLevel:(DSCellPath *)path;

- (void)addChildLevelWithCellCount:(NSInteger)cellCount atIndex:(NSInteger)index;

- (void)reset;

- (bool)hasOpenCell;

- (NSInteger)removeChildLevel;

- (BOOL)hasOpenChildLevelAtIndex:(NSInteger)cellIndex;

- (BOOL)hasOpenChildLevelButAtDifferentIndex:(NSInteger)cellIndex;

- (NSInteger)flattenedIndexOfExpandedCellInLevel:(DSCellLevel *)level;

- (NSInteger)flattenedIndexOfCellInLevel:(DSCellLevel *)level atIndex:(NSInteger)cellIndex;

@end
#import <Foundation/Foundation.h>

@interface DSCellPath : NSObject

@property(nonatomic, strong) NSMutableArray *levelIndexes;

- (id)init;

- (void)addToPath:(NSInteger)path;

- (void)removeLastPath;

- (void)addToLastPath:(NSInteger)noOfCells;

@end
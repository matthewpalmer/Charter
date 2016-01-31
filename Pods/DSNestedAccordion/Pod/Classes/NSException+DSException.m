#import "NSException+DSException.h"

@implementation NSException (DSException)

+ (NSException *)dsMethodNotOverridden:(NSString *)methodName {
    return [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", methodName]
                                 userInfo:nil];
}

@end
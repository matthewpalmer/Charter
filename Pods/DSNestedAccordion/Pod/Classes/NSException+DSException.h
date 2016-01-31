#import <Foundation/Foundation.h>

@interface NSException (DSException)

+ (NSException *)dsMethodNotOverridden:(NSString *)methodName;

@end
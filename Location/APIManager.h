#import <Foundation/Foundation.h>
#import "APIDelegate.h"

@interface APIManager : NSObject
    <NSURLConnectionDelegate>

@property (nonatomic, retain) id<APIDelegate>delegate;

- (void)startConnectionWithURLRoot:(NSString *)urlRoot params:(NSDictionary *)params andBody:(NSData *)body;

@end

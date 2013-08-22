#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, retain) NSString *ID;

- (id)initWithID:(NSString *)ID andUsername:(NSString *)username;

@end

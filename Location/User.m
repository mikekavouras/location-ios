#import "User.h"

@interface User()

@property (nonatomic, retain) NSString *username;

@end

@implementation User

- (id)initWithID:(NSString *)ID andUsername:(NSString *)username
{
    if (self = [super init]) {
        self.ID = ID;
        self.username = username;
    }
    
    return self;
}

@end

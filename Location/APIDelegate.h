#import <Foundation/Foundation.h>

@protocol APIDelegate <NSObject>

- (void)didSucceedWithJSON:(NSDictionary *)json;
- (void)didFailWithErrors:(NSDictionary *)errors;

@end

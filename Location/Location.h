#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float horizontalAccuracy;
@property (nonatomic, assign) float verticalAccuracy;
@property (nonatomic, retain) NSDate *timestamp;

@end

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "APIDelegate.h"

@interface MainViewController : UIViewController
<CLLocationManagerDelegate, UITextFieldDelegate, APIDelegate, UIAccelerometerDelegate>

- (void)didEnterBackground;
- (void)didEnterForeground;

@end

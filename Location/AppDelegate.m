#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate()

@property (nonatomic, retain) MainViewController *mvc;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.mvc = [[MainViewController alloc] init];
    self.window.rootViewController = self.mvc;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    [self.mvc didEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [self.mvc didEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end

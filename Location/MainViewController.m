#import "MainViewController.h"
#import "APIManager.h"
#import "User.h"
#import "Location.h"

#define kAPIURL @"http://10.1.1.191/points/new?"
//#define kAPIURL @"http://mk-location.herokuapp.com/points/new?"

@interface MainViewController ()

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float latitude;
@property (nonatomic, retain) NSUserDefaults *defaults;
@property (nonatomic, retain) UIView *usernameView;
@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) UILabel *status;
@property (nonatomic, retain) UISwitch *locationSwitch;

@property (nonatomic, retain) UIAccelerometer *accelerometer;

@property (nonatomic, retain) UIProgressView *progressX;
@property (nonatomic, retain) UIProgressView *progressY;
@property (nonatomic, retain) UIProgressView *progressZ;

@property (nonatomic, retain) NSMutableArray *xData;
@property (nonatomic, retain) NSMutableArray *yData;
@property (nonatomic, retain) NSMutableArray *zData;

@end

@implementation MainViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.accelerometer = [UIAccelerometer sharedAccelerometer];
        self.accelerometer.updateInterval = 0.1;
        self.accelerometer.delegate = self;
        
        self.xData = [[NSMutableArray alloc] init];
        self.yData = [[NSMutableArray alloc] init];
        self.zData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    self.locationSwitch = [[UISwitch alloc] init];
    self.locationSwitch.center = self.view.center;
    [self.locationSwitch addTarget:self action:@selector(toggleLocation:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.locationSwitch];
    
    if ([self.defaults boolForKey:@"shouldGetLocation"]) {
        [self.locationSwitch setOn:[self.defaults boolForKey:@"shouldGetLocation"] animated:NO];
    }
    
    self.status = [[UILabel alloc] init];
    self.status.frame = CGRectMake(10, 10, 100, 50);
    self.status.text = @"no";
    
    [self.view addSubview:self.status];
    
    if ([self.defaults stringForKey:@"location-username"] != NULL && ![[self.defaults stringForKey:@"location-username"] isEqualToString:@""]) {
        NSString *username = [self.defaults objectForKey:@"location-username"];
        NSString *ID = [self.defaults objectForKey:@"location-id"];
        self.user = [[User alloc] initWithID:ID andUsername:username];
    } else {
        [self showLoginScreen];
        [self.view addSubview:self.usernameView];
    }
    
    self.progressX = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressY = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressZ = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    
    self.progressX.frame = CGRectMake(60, 80, self.view.bounds.size.width - 80, 20);
    self.progressY.frame = CGRectMake(60, 100, self.view.bounds.size.width - 80, 20);
    self.progressZ.frame = CGRectMake(60, 120, self.view.bounds.size.width - 80, 20);
    
    UILabel *labelX = [[UILabel alloc] initWithFrame:CGRectMake(20, 76, 40, 20)];
    UILabel *labelY = [[UILabel alloc] initWithFrame:CGRectMake(20, 96, 40, 20)];
    UILabel *labelZ = [[UILabel alloc] initWithFrame:CGRectMake(20, 114, 40, 20)];
    
    labelX.text = @"X:";
    labelY.text = @"Y:";
    labelZ.text = @"Z:";
    
    [self.view addSubview:self.progressX];
    [self.view addSubview:self.progressY];
    [self.view addSubview:self.progressZ];
    
    [self.view addSubview:labelX];
    [self.view addSubview:labelY];
    [self.view addSubview:labelZ];
    
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(readAccelerometerData:) userInfo:nil repeats:YES];
    
    [loop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)readAccelerometerData:(NSTimer *)timer
{
    NSError *error;

    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"x" : self.xData, @"y" : self.yData, @"z" : self.zData} options:NSJSONWritingPrettyPrinted error:&error];
    
    APIManager *api = [[APIManager alloc] init];
    [api startConnectionWithURLRoot:kAPIURL params:nil andBody:data];
    
    [self.xData removeAllObjects];
    [self.yData removeAllObjects];
    [self.zData removeAllObjects];
}


- (void)toggleLocation:(id)sender
{
    [self.defaults setBool:self.locationSwitch.on forKey:@"shouldGetLocation"];
    
    self.locationSwitch.on == YES ? [self.locationManager startUpdatingLocation] : [self.locationManager stopUpdatingLocation];
    self.status.text = self.locationSwitch.on == YES ? @"yes" : @"no";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)createLocationFromPoint:(Location *)point
{
    NSString *latitude = [NSString stringWithFormat:@"%f", point.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", point.longitude];
    NSString *h_accuracy = [NSString stringWithFormat:@"%f", point.horizontalAccuracy];
    NSString *v_accuracy = [NSString stringWithFormat:@"%f", point.verticalAccuracy];
    
    NSArray *keys = [NSArray arrayWithObjects:@"user_id", @"latitude", @"longitude", @"horizontal_accuracy", @"vertical_accuracy", nil];
    NSArray *values = [NSArray arrayWithObjects:self.user.ID, latitude, longitude, h_accuracy, v_accuracy, nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    APIManager *api = [[APIManager alloc] init];
    [api startConnectionWithURLRoot:kAPIURL params:params andBody:nil];
}

- (void)showLoginScreen
{
    self.usernameView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.usernameView.backgroundColor = [UIColor whiteColor];
    
    float width = self.view.frame.size.width;
    float textWidth = 280;
    float textHeight = 50;
    
    // login text field
    self.usernameField = [[UITextField alloc] init];
    self.usernameField.frame = CGRectMake((width / 2) - (textWidth / 2), 60, textWidth, textHeight);
    self.usernameField.placeholder = @"username";
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameField.delegate = self;
    
    
    // login button
    UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    usernameButton.frame = CGRectMake((width / 2) - (textWidth / 2), 150, 120, 40);
    usernameButton.backgroundColor = [UIColor blackColor];
    [usernameButton setTitle:@"That’s me!" forState:UIControlStateNormal];
    [usernameButton addTarget:self action:@selector(loginUser:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.usernameView addSubview:self.usernameField];
    [self.usernameView addSubview:usernameButton];
}

- (void)loginUser:(id)sender
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:self.usernameField.text forKey:@"username"];
    
    APIManager *api = [[APIManager alloc] init];
    api.delegate = self;
    [api startConnectionWithURLRoot:@"http://mk-location.herokuapp.com/sessions?" params:params andBody:nil];
//    [api startConnectionWithURLRoot:@"http://192.168.0.15/sessions?" andParams:params];
}

- (void)didEnterBackground
{
    if (![self.defaults boolForKey:@"shouldGetLocation"]) {
        [self.locationManager stopUpdatingLocation];
        self.status.text = @"no";
    }
}

- (void)didEnterForeground
{
    [self.locationManager startUpdatingLocation];
}

#pragma mark APIDelegate

- (void)didSucceedWithJSON:(NSDictionary *)json
{
    NSString *username = [json objectForKey:@"username"];
    NSString *ID = [json objectForKey:@"id"];
    
    [self.defaults setValue:username forKey:@"location-username"];
    [self.defaults setValue:ID forKey:@"location-id"];
    
    self.user = [[User alloc] initWithID:ID andUsername:username];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.usernameView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.usernameView removeFromSuperview];
                     }];
}

- (void)didFailWithErrors:(NSDictionary *)errors
{
}


#pragma mark UITextFieldDelegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self loginUser:textField];
    return YES;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    CLLocationDegrees longitude = location.coordinate.longitude;
    CLLocationDegrees latitude = location.coordinate.latitude;
    
    self.longitude = longitude;
    self.latitude = latitude;
    
    Location *point = [[Location alloc] init];
    point.longitude = longitude;
    point.latitude = latitude;
    point.timestamp = location.timestamp;
    point.horizontalAccuracy = location.horizontalAccuracy;
    point.verticalAccuracy = location.verticalAccuracy;
    
    [self createLocationFromPoint:point];
    
    self.status.text = @"yes";
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.status.text = @"no";
}

#pragma mark UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    self.progressX.progress = ABS(acceleration.x);
    self.progressY.progress = ABS(acceleration.y);
    self.progressZ.progress = ABS(acceleration.z);
    
    NSNumber *xData = [NSNumber numberWithDouble:acceleration.x];
    NSNumber *yData = [NSNumber numberWithDouble:acceleration.y];
    NSNumber *zData = [NSNumber numberWithDouble:acceleration.z];
    
    [self.xData addObject:xData];
    [self.yData addObject:yData];
    [self.zData addObject:zData];
}

@end

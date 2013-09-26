//
//  SSAViewController.m
//  ssa2
//
//  Created by AJ Jenkins on 6/17/12.
//  Copyright (c) 2012 Tufts. All rights reserved.
//

#import "SSAViewController.h"

@interface SSAViewController ()

@end

@implementation SSAViewController

@synthesize stopField = _stopField;
@synthesize numStops = _numStops;
@synthesize stepper = _stepper;
@synthesize timer = _timer;
@synthesize localNotif = _localNotif;
@synthesize accelX = _accelX;
@synthesize accelY = _accelY;
@synthesize accelZ = _accelZ;
@synthesize xValue = _xValue;
@synthesize yValue = _yValue;
@synthesize zValue = _zValue;
@synthesize bti = _bti;
@synthesize motionManager = _motionManager;
@synthesize mTimer = _mTimer;
@synthesize accel = _accel;
@synthesize fh = _fh;
@synthesize fileName = _fileName;
@synthesize motionUpdateRate = _motionUpdateRate;
@synthesize r2value = _r2value;
@synthesize movement = _movement;
@synthesize descriptive = _descriptive;
@synthesize logTime = _logTime;

unsigned int bgTask;

// Called when app starts. Set constants
- (void)viewDidLoad
{
    self.motionUpdateRate = .20;
    self.descriptive = NO;
    self.movement = @"?";
    self.logTime = 0;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

// Called when app closes
- (void)viewDidUnload
{
    [self setStopField:nil];
    [self setStepper:nil];
    [self setAccelX:nil];
    [self setAccelY:nil];
    [self setAccelZ:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Stepper button controls. Calls updateStopField
- (IBAction)changeStops:(UIStepper *)sender {
    if (![self.timer isValid]) {
        int value = [sender value];
        self.numStops = [NSNumber numberWithInt:value];
        [self updateStopField];
    }
}

// Updates the number displayed in numStops field
- (void)updateStopField {
    NSString *stops = [NSString stringWithFormat:@"%d", [self.numStops intValue]];
    [self.stopField setText:stops];
}

// Updates the values in the acceleration fields
- (void)updateAccelField {
    NSString *xval = [NSString stringWithFormat:@"%f", self.xValue];
    [self.accelX setText:xval];
    NSString *yval = [NSString stringWithFormat:@"%f", self.yValue];
    [self.accelY setText:yval];
    NSString *zval = [NSString stringWithFormat:@"%f", self.zValue];
    [self.accelZ setText:zval];
}

// Get acceleration data and update global variables. Calls logMotion and updateAccelField
- (void)updateMotion {
    self.accel = [[self.motionManager deviceMotion] userAcceleration];
    
    self.xValue = self.accel.x;
    self.yValue = self.accel.y;
    self.zValue = self.accel.z;
    self.r2value = (self.xValue * self.xValue) + (self.yValue * self.yValue) + (self.zValue * self.zValue);
    self.logTime += self.motionUpdateRate;
    
    [self logMotion];

    [self updateAccelField];
}

// Prints cstring to console with acceleration data
- (void)logMotion {
    NSString *output = [NSString stringWithFormat:@"%f, %f, %f, %f, %f, %@", self.logTime, self.r2value, self.xValue, self.yValue, self.zValue, self.movement];
    const char *cstring = [output cStringUsingEncoding:NSASCIIStringEncoding];
    printf("%s\n", cstring);
}

// Start button controls.
// Initializes: Motion, Stop Timer, Acceleration Update Timer, Background Task
- (IBAction)start:(id)sender {
    [self initMotion];
    [self createHeader];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 
                                                  target:self 
                                                selector:@selector(decrementStops) 
                                                userInfo:nil 
                                                 repeats:YES];
    self.mTimer = [NSTimer scheduledTimerWithTimeInterval:self.motionUpdateRate
                                                  target:self 
                                                selector:@selector(updateMotion) 
                                                userInfo:nil 
                                                 repeats:YES];
    self.bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self tick];
    }];
        
}

// Creates header in console in ARFF format
- (void)createHeader {
    printf("@RELATION train_movement\n\n"
           "@ATTRIBUTE time NUMERIC\n"
           "@ATTRIBUTE r2 NUMERIC\n"
           "@ATTRIBUTE x NUMERIC\n"
           "@ATTRIBUTE y NUMERIC\n"
           "@ATTRIBUTE z NUMERIC\n"
           "@ATTRIBUTE movement {moving,stopped}\n\n"
           "@DATA\n");
}

 
// Used to make function calls while in background
- (void)tick {
    [self.timer fire];
    [self.mTimer fire];
}

// Reset button controls.
// Ends background task, resets Stops and Motion.
- (IBAction)reset:(id)sender {
    [[UIApplication sharedApplication] endBackgroundTask:self.bti];
    self.bti = UIBackgroundTaskInvalid;
    [self resetStops];
    [self stopMotion];
}

// Resets stop field/buttons, unless it's at 10
- (void)resetStops {
    [self.timer invalidate];
    if ([self.numStops intValue] != 10) { 
        self.numStops = [NSNumber numberWithInt:0];
        [self updateStopField];
        self.stepper.value = 0;
    }
}

// Decrements stop field to 0, then sends alert
- (void)decrementStops {
    if ([self.numStops intValue] > 0) {
        if ([self.numStops intValue] != 10) {
            int newValue = [self.numStops intValue] - 1;
            self.numStops = [NSNumber numberWithInt:newValue];
            [self updateStopField];
        }
    } else {
        [self resetStops];
        [self pushLocalNotification];
        [self pushAlertView];
        [self playSound];
        [self stopMotion];
    }       
}
    
// Sends push notification for background running
- (void)pushLocalNotification {
    double timeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
    self.localNotif = [[UILocalNotification alloc] init];
    if (self.localNotif) {
//        self.localNotif.alertBody = @"This is your stop.";
        self.localNotif.alertBody = [NSString stringWithFormat:@"%f", timeRemaining];
        self.localNotif.alertAction = NSLocalizedString(@"Got It.", nil);
        self.localNotif.soundName = UILocalNotificationDefaultSoundName;
        self.localNotif.applicationIconBadgeNumber = 0;
        [[UIApplication sharedApplication] presentLocalNotificationNow:self.localNotif];
        self.localNotif = nil;
    }
}

// Sends push notification for foreground running
- (void)pushAlertView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"This is your stop." delegate:nil cancelButtonTitle:@"Got it!" otherButtonTitles:nil];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [alert show];
    }
}

// Plays a sound
- (void)playSound {
    NSString *path = [NSString stringWithFormat: @"%@/%@",
                      [[NSBundle mainBundle] resourcePath], @"beep.wav"];
    NSURL *filePath = [NSURL fileURLWithPath: path isDirectory: NO];
    CFURLRef alertURL = (__bridge CFURLRef)filePath;
    SystemSoundID soundObject;
    AudioServicesCreateSystemSoundID(alertURL, &soundObject);
    AudioServicesPlayAlertSound(soundObject);
}

// Initializes Motion
- (void)initMotion {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = self.motionUpdateRate;
    self.xValue = 0.0;
    self.yValue = 0.0;
    self.zValue = 0.0;
    [self startMotion];
}

// Starts motion updates, if available
- (BOOL)startMotion {
    if (self.motionManager.isDeviceMotionAvailable) {
        [self.motionManager startDeviceMotionUpdates];
        return YES;
    } else {
        NSLog(@"Device Motion updates not available.");
        return NO;
    }
}

// Stops motion updates and resets acceleration values
- (void)stopMotion {
    [self.mTimer invalidate];
    if (self.motionManager.isDeviceMotionActive) {
        [self.motionManager stopDeviceMotionUpdates];
    }
    self.xValue = 0.0;
    self.yValue = 0.0;
    self.zValue = 0.0;
    [self updateAccelField];
}

// Creates a log file somewhere?
- (void)createLog {
    //////////////
    // This function is not in use
    // Please ignore
    //////////////
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.fileName = [dateFormatter stringFromDate:[NSDate date]];
    self.fileName = [NSString stringWithFormat:@"%@.log", self.fileName];

    NSFileManager *filemgr;
    NSString *dataFile;
    NSString *docsDir;
    NSArray *dirPaths;
    
    filemgr = [NSFileManager defaultManager];
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    dataFile = [docsDir stringByAppendingPathComponent: @"datafile.dat"];
    
    if (
        [filemgr createFileAtPath: dataFile contents:nil attributes:nil]) {
        NSLog(@"YEAH MAN");
    } else {
        NSLog(@"NO!");
    }
    
    self.fh = [NSFileHandle fileHandleForWritingAtPath:dataFile];

}

// Writes anything to the console
- (void)writeToLog:(id)text {
    const char *cstring = [text cStringUsingEncoding:NSASCIIStringEncoding];
    printf("\n%s", cstring);
}

// Closes log file. No longer used.
- (void)closeLog {
    [self.fh closeFile];
}

// Accel [+] button
- (IBAction)markAccel:(id)sender {
    self.movement = @"moving";
//    printf(", 0, Accelerating");
}

// Max Vel. [^] button
- (IBAction)markMaxVel:(id)sender {
    self.movement = @"moving";
//    printf(", 0, Max Velocity Reached");
}

// Decel [-] button
- (IBAction)markDecel:(id)sender {
    self.movement = @"decel";
//    printf(", 0, Decelerating");
}

// Stopped [0] button
- (IBAction)markStopped:(id)sender {
    self.movement = @"stopped";
//    printf(", 0, Stopped");
}
@end
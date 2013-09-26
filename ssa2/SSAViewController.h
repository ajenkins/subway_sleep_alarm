//
//  SSAViewController.h
//  ssa2
//
//  Created by AJ Jenkins on 6/17/12.
//  Copyright (c) 2012 Tufts. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#include <CoreMotion/CoreMotion.h>

@interface SSAViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *stopField;
@property (weak, nonatomic) NSNumber *numStops;

@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@property (weak, nonatomic) NSTimer *timer;
@property (retain, nonatomic) UILocalNotification *localNotif;

@property (weak, nonatomic) IBOutlet UITextField *accelX;
@property (weak, nonatomic) IBOutlet UITextField *accelY;
@property (weak, nonatomic) IBOutlet UITextField *accelZ;

- (IBAction)markAccel:(id)sender;
- (IBAction)markMaxVel:(id)sender;
- (IBAction)markDecel:(id)sender;
- (IBAction)markStopped:(id)sender;

@property double xValue;
@property double yValue;
@property double zValue;
@property double r2value;
@property double logTime;
@property CMAcceleration accel;
@property double motionUpdateRate;
@property NSString *movement;
@property BOOL descriptive;

@property (retain, nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) NSTimer *mTimer;

@property UIBackgroundTaskIdentifier bti;

@property (retain, nonatomic) NSFileHandle *fh;
@property (weak, nonatomic) NSString *fileName;



- (IBAction)changeStops:(id)sender;

- (void)updateStopField;
- (void)updateAccelField;

- (IBAction)start:(id)sender;
- (IBAction)reset:(id)sender;

- (void)decrementStops;
- (void)resetStops;

- (void)pushLocalNotification;
- (void)pushAlertView;
- (void)playSound;

- (void)tick;

- (void)initMotion;
- (BOOL)startMotion;
- (void)stopMotion;
- (void)updateMotion;

- (void)logMotion;
- (void)createHeader;

- (void)createLog;
- (void)writeToLog:(id)text;
- (void)closeLog;

@end

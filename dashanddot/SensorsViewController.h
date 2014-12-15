//
//  SecondViewController.h
//  dashanddot
//
//  Created by Shell Shrader on 12/6/14.
//  Copyright (c) 2014 Shell Shrader. All rights reserved.
//
#import "RobotControlViewController.h"

@interface SensorsViewController : RobotControlViewController

@property (nonatomic, strong) NSTimer *refreshDataTimer;

@property (weak, nonatomic) IBOutlet UIProgressView *amplitudeProgress;

@property (weak, nonatomic) IBOutlet UIProgressView *xProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *yProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *zProgress;
@property (weak, nonatomic) IBOutlet UISwitch *detectMovementSwitch;
@property (weak, nonatomic) IBOutlet UILabel *sensorsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *dashSensorLeft;
@property (weak, nonatomic) IBOutlet UIImageView *dashSensorRight;
@property (weak, nonatomic) IBOutlet UIImageView *dashSensorRear;

- (IBAction)detectMovementSwitchChanged:(id)sender;

- (void) refreshSensorData:(NSTimer *)timer;

@end


//
//  SecondViewController.m
//  dashanddot
//
//  Created by Shell Shrader on 12/6/14.
//  Copyright (c) 2014 Shell Shrader. All rights reserved.
//

#import "SensorsViewController.h"

//@interface SensorsViewController ()
//
//@end

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@implementation SensorsViewController

int x = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.refreshDataTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                            target:self selector:@selector(refreshSensorData:) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.refreshDataTimer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshSensorData:(NSTimer *)timer {
    
    for (WWRobot *robot in self.connectedRobots) {
        if (robot.delegate == nil) robot.delegate = self;
        
        WWSensorSet *sensorData = robot.history.currentState;
        
        WWSensorAccelerometer *SAcc = (WWSensorAccelerometer *)[sensorData sensorForIndex:WW_SENSOR_ACCELEROMETER];
        
        self.xProgress.progress = SAcc.x + .35;
        self.yProgress.progress = SAcc.y + .43;
        self.zProgress.progress = SAcc.z - .47;
        
        float movement = ABS(SAcc.x) + ABS(SAcc.y) + ABS(SAcc.z);
        
        if ([self.detectMovementSwitch isOn] && movement > 1.5f && x == 0) {
            WWCommandSet *speakerCommand = [WWCommandSet new];
            WWCommandSpeaker *speaker = [[WWCommandSpeaker alloc] initWithDefaultSound:WW_SOUNDFILE_WEEHEE];
            speaker.volume = 1;
            [speakerCommand setSound:speaker];
            
            [robot sendRobotCommandSet:speakerCommand];
            x++;
        }
        
        if (x > 0 && x < 30) {
            x++;
        } else {
            x = 0;
        }
        
        WWSensorMicrophone *SMic = (WWSensorMicrophone *)[sensorData sensorForIndex:WW_SENSOR_MICROPHONE];
        self.amplitudeProgress.progress = SMic.amplitude;
        
        NSLog(@"%@ x=%3.2f y=%3.2f z=%3.2f movement=%3.2f", robot.name, SAcc ? SAcc.x : NAN, SAcc ? SAcc.y : NAN, SAcc ? SAcc.z : NAN, movement);
        NSLog(@"%@ sound amplitude is %3.2f angle is %3.2f degrees", robot.name, SMic.amplitude, RADIANS_TO_DEGREES(SMic ? SMic.triangulationAngle : NAN));
    }
}

@end

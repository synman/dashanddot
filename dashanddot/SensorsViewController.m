//
//  SecondViewController.m
//  dashanddot
//
//  Created by Shell Shrader on 12/6/14.
//  Copyright (c) 2014 Shell Shrader. All rights reserved.
//

#import "SensorsViewController.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@implementation SensorsViewController

int WALL_REFLECTANCE = 10;
float SENSOR_REFRESH_RATE = .25;

int x = 0;
int direction=5;
int panDegree=0;

double lastMovement = -999;
double distanceTraveled = -999;

//NSNumber *dist;
//WWEvent *objectInFront;

WWCommandSet *stopDriving;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    dist = [NSNumber numberWithUnsignedInteger:10];
//    objectInFront = [WWEventToolbelt detectObjectFront:dist];

    stopDriving = [WWCommandSet new];
    WWCommandBodyLinearAngular *linAng = [[WWCommandBodyLinearAngular alloc] initWithLinear:0 angular:0];
    [stopDriving setBodyLinearAngular:linAng];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.refreshDataTimer = [NSTimer scheduledTimerWithTimeInterval:SENSOR_REFRESH_RATE
                            target:self selector:@selector(refreshSensorData:) userInfo:nil repeats:YES];
    
//    for (WWRobot *robot in self.connectedRobots) {
//        [robot addEvent:objectInFront];
//    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.refreshDataTimer invalidate];
    [self sendCommandSetToRobots:stopDriving];
    
//    for (WWRobot *robot in self.connectedRobots) {
//        [robot removeEvent:objectInFront];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)detectMovementSwitchChanged:(id)sender {
    if (![self.detectMovementSwitch isOn]) {
        [self sendCommandSetToRobots:stopDriving];
    }
}

- (void) refreshSensorData:(NSTimer *)timer {
    
    for (WWRobot *robot in self.connectedRobots) {
        WWSensorSet *sensorData = robot.history.currentState;
        
        WWSensorAccelerometer *SAcc = (WWSensorAccelerometer *)[sensorData sensorForIndex:WW_SENSOR_ACCELEROMETER];
        WWSensorMicrophone *SMic = (WWSensorMicrophone *)[sensorData sensorForIndex:WW_SENSOR_MICROPHONE];
        WWSensorDistance *SDistFRF = (WWSensorDistance *)[sensorData sensorForIndex:WW_SENSOR_DISTANCE_FRONT_RIGHT_FACING];
        WWSensorDistance *SDistFLF = (WWSensorDistance *)[sensorData sensorForIndex:WW_SENSOR_DISTANCE_FRONT_LEFT_FACING];
        WWSensorDistance *SDistFBF = (WWSensorDistance *)[sensorData sensorForIndex:WW_SENSOR_DISTANCE_BACK];
        WWSensorEncoder *SLeftWheel = (WWSensorEncoder *)[sensorData sensorForIndex:WW_SENSOR_ENCODER_LEFT_WHEEL];
        WWSensorEncoder *SRightWheel = (WWSensorEncoder *)[sensorData sensorForIndex:WW_SENSOR_ENCODER_RIGHT_WHEEL];
       
        self.xProgress.progress = SAcc.x + .5;
        self.yProgress.progress = SAcc.y + .5;
        self.zProgress.progress = SAcc.z -.5;
        
        float movement = SAcc.x + SAcc.y + SAcc.z;
        if (lastMovement == -999) lastMovement = movement;
    
        if (robot.robotType == WW_ROBOT_DOT && [self.detectMovementSwitch isOn] && ABS(movement - lastMovement) > .1  && x == 0) {
            WWCommandSet *speakerCommand = [WWCommandSet new];
            WWCommandSpeaker *speaker = [[WWCommandSpeaker alloc] initWithDefaultSound:WW_SOUNDFILE_BUZZ];
            speaker.volume = 1;
            [speakerCommand setSound:speaker];
            
            [robot sendRobotCommandSet:speakerCommand];
            x++;
        }
        
        if (x > 0 && x < 25) {
            x++;
        } else {
            x = 0;
        }
        
        lastMovement = movement;
        
        self.amplitudeProgress.progress = SMic.amplitude;
        
        
        if (robot.robotType == WW_ROBOT_DASH && [self.detectMovementSwitch isOn]) {
    
            double lin=50;
            double ang;
        
            if (SDistFRF.reflectance > 3) {
                ang = -M_PI / 4;
            } else {
                if (SDistFRF.reflectance > 1) {
                    ang = -M_PI / 6;
                } else {
                    if (SDistFRF.reflectance == 0 && SDistFLF.reflectance == 0) {
                        ang = M_PI / 8;
                    } else {
                        ang = M_PI / 6;
                    }
                }
            }
    
            double traveled = SLeftWheel.distance + SRightWheel.distance;
            
            // are we hitting a wall ?
            if ((SDistFLF.reflectance > WALL_REFLECTANCE && SDistFRF.reflectance > WALL_REFLECTANCE) ||
                                                            (SDistFBF.reflectance < WALL_REFLECTANCE &&
                                                             distanceTraveled  - traveled >= 0 && distanceTraveled - traveled < 10)) {
                lin = -50;
//                ang = SDistFRF.reflectance > SDistFLF.reflectance ? -M_PI : SDistFRF.reflectance < SDistFLF.reflectance ? M_PI : 0;
                ang = 0;
            } else {
                distanceTraveled = traveled;
            }
        
            WWCommandSet *moveCommand = [WWCommandSet new];
            WWCommandBodyLinearAngular *linAng = [[WWCommandBodyLinearAngular alloc] initWithLinear:lin
                                                                                        angular:ang];
            [moveCommand setBodyLinearAngular:linAng];
        
            [self sendCommandSetToRobots:moveCommand];
            
//            WWCommandSet *headPositionCommand = [WWCommandSet new];
//            WWCommandHeadPosition *tilt = [[WWCommandHeadPosition alloc] initWithDegree:0];
//            WWCommandHeadPosition *pan = [[WWCommandHeadPosition alloc] initWithDegree:panDegree];
//            [headPositionCommand setHeadPositionTilt:tilt pan:pan];
//        
//            [self sendCommandSetToRobots:headPositionCommand];
//        
//            if (panDegree > 120) {
//                direction = -5;
//            } else {
//                if (panDegree < -120) {
//                    direction = 5;
//                }
//            }
//        
//            panDegree = panDegree + direction;
        }
    
        NSString *labelText  = [NSString stringWithFormat:@"%@ x=%3.2f y=%3.2f z=%3.2f amp=%3.2f ang=%3.2f rr=%3.2f lr=%3.2f br=%3.2f",
              robot.name,
              SAcc ? SAcc.x : NAN,
              SAcc ? SAcc.y : NAN,
              SAcc ? SAcc.z : NAN,
              SMic ? SMic.amplitude : NAN,
              SMic ? RADIANS_TO_DEGREES(SMic.triangulationAngle) : NAN,
              SDistFRF ? SDistFRF.reflectance : NAN,
              SDistFLF ? SDistFLF.reflectance : NAN,
              SDistFBF ? SDistFBF.reflectance : NAN
        ];
        
        [self.sensorsLabel setText:labelText];
        NSLog(@"%@", labelText);
    }
}

//- (void) robot:(WWRobot *)robot eventsTriggered:(NSArray *)events {
//    for (WWEvent *event in events) {
//        if ([event isEqual:objectInFront]) {
//            NSLog(@"%@ object in front", robot.name);
//        }
//    }
//}

@end

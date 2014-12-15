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

int WALL_REFLECTANCE = 20;
float SENSOR_REFRESH_RATE = .25;

int soundPause = 0;
int direction=5;
int panDegree=0;

double lastMovement = -999;
double distanceTraveled = -999;

//NSNumber *dist;
//WWEvent *objectInFront;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    dist = [NSNumber numberWithUnsignedInteger:10];
//    objectInFront = [WWEventToolbelt detectObjectFront:dist];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.refreshDataTimer = [NSTimer scheduledTimerWithTimeInterval:SENSOR_REFRESH_RATE
                            target:self selector:@selector(refreshSensorData:)  userInfo:nil repeats:YES];
    
//    for (WWRobot *robot in self.connectedRobots) {
//        [robot addEvent:objectInFront];
//    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.refreshDataTimer invalidate];
    [self sendCommandSetToRobots:[WWCommandToolbelt moveStop]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)detectMovementSwitchChanged:(id)sender {
    if (![self.detectMovementSwitch isOn]) {
        [self sendCommandSetToRobots:[WWCommandToolbelt moveStop]];
    }
}

- (void) refreshSensorData:(NSTimer *)timer {
    int reverse = 0;
    
    for (WWRobot *robot in self.connectedRobots) {
        WWSensorSet *sensorData = robot.history.currentState;
        
//        for (int i = 1; i <= 10000; i++)
//        {
//            WWSensor *sensor = (WWSensor *) [sensorData sensorForIndex:i];
//            if (sensor) NSLog(@"%d is %@", i, sensor ? @"good" : @"empty");
//        }
        
        WWSensorAccelerometer *SAcc = (WWSensorAccelerometer *)[sensorData sensorForIndex:WW_SENSOR_ACCELEROMETER];
        WWSensorGyroscope *SGyro = (WWSensorGyroscope *)[sensorData sensorForIndex:WW_SENSOR_GYROSCOPE];
        WWSensorMicrophone *SMic = (WWSensorMicrophone *)[sensorData sensorForIndex:WW_SENSOR_MICROPHONE];
        WWSensorDistance *SDistFRF = (WWSensorDistance *)[sensorData sensorForIndex:WW_SENSOR_DISTANCE_FRONT_RIGHT_FACING];
        WWSensorDistance *SDistFLF = (WWSensorDistance *)[sensorData sensorForIndex:WW_SENSOR_DISTANCE_FRONT_LEFT_FACING];
        WWSensorDistance *SDistFBF = (WWSensorDistance *)[sensorData sensorForIndex:WW_SENSOR_DISTANCE_BACK];
        WWSensorEncoder *SLeftWheel = (WWSensorEncoder *)[sensorData sensorForIndex:WW_SENSOR_ENCODER_LEFT_WHEEL];
        WWSensorEncoder *SRightWheel = (WWSensorEncoder *)[sensorData sensorForIndex:WW_SENSOR_ENCODER_RIGHT_WHEEL];
        WWSensorBodyPose *BodyPose = (WWSensorBodyPose *) [sensorData sensorForIndex:WW_SENSOR_BODY_POSE];
        
//        self.xProgress.progress = SAcc.x + .5;
//        self.yProgress.progress = SAcc.y + .5;
//        self.zProgress.progress = SAcc.z -.5;

        self.xProgress.progress = SGyro.x;
        self.yProgress.progress = SGyro.y;
        self.zProgress.progress = SGyro.z;

        float movement = SAcc.x + SAcc.y + SAcc.z;
        if (lastMovement == -999) lastMovement = movement;
        
        if (soundPause < 0) soundPause++;
        
        if (SMic.triangulationAngle != 0 && soundPause == 0) {
            
            double degrees = RADIANS_TO_DEGREES(SMic.triangulationAngle) > 120 ? 120 : RADIANS_TO_DEGREES(SMic.triangulationAngle) < -120 ? -120 : RADIANS_TO_DEGREES(SMic.triangulationAngle);
            
            WWCommandSet *headPositionCommand = [WWCommandSet new];
            WWCommandHeadPosition *tilt = [[WWCommandHeadPosition alloc] initWithDegree:0];
            WWCommandHeadPosition *pan = [[WWCommandHeadPosition alloc] initWithDegree:degrees];
            [headPositionCommand setHeadPositionTilt:tilt pan:pan];
            
            [self sendCommandSetToRobots:headPositionCommand];
            soundPause++;
        }
    
        if (robot.robotType == WW_ROBOT_DOT && [self.detectMovementSwitch isOn] && (ABS(movement - lastMovement) > .2 || SMic.amplitude > .03)  && soundPause == 0) {
            WWCommandSet *speakerCommand = [WWCommandSet new];
            WWCommandSpeaker *speaker = [[WWCommandSpeaker alloc] initWithDefaultSound:SMic.amplitude > .03 ? WW_SOUNDFILE_HI : WW_SOUNDFILE_GIGGLE];
            speaker.volume = 1;
            [speakerCommand setSound:speaker];
            
            [robot sendRobotCommandSet:speakerCommand];
            soundPause++;
        }
        
        if (soundPause > 0 && soundPause < 16) {
            soundPause++;
            
            WWCommandSet *eyeCommand = [WWCommandSet new];
            WWCommandEyeRing *eye;
            
            if ((int) soundPause / 2 < (double) soundPause / 2) {
                eye = [[WWCommandEyeRing alloc] initWithBitmap:@[@true,@false,@true,@false,@true,@false,@true,@false,@true,@false,@true,@false]];
            } else {
                eye = [[WWCommandEyeRing alloc] initWithBitmap:@[@false,@true,@false,@true,@false,@true,@false,@true,@false,@true,@false,@true]];
            }
            
            [eyeCommand setEyeRing:eye];
            [robot sendRobotCommandSet:eyeCommand];
            
        } else if (soundPause > 0) {
            soundPause = -7;

            WWCommandSet *eyeCommand = [WWCommandSet new];
            WWCommandEyeRing *eye = [[WWCommandEyeRing alloc] init];
            [eye setAllBitmap:true];
            [eyeCommand setEyeRing:eye];
  
            [robot sendRobotCommandSet:eyeCommand];
            
            WWCommandSet *headPositionCommand = [WWCommandSet new];
            WWCommandHeadPosition *tilt = [[WWCommandHeadPosition alloc] initWithDegree:0];
            WWCommandHeadPosition *pan = [[WWCommandHeadPosition alloc] initWithDegree:0];
            [headPositionCommand setHeadPositionTilt:tilt pan:pan];
            
            [self sendCommandSetToRobots:headPositionCommand];
        }
        
        self.amplitudeProgress.progress = SMic.amplitude;
        
        if (robot.robotType == WW_ROBOT_DASH) {

            self.dashSensorLeft.hidden = SDistFRF.reflectance > 2 ? false : true;
            self.dashSensorRight.hidden = SDistFLF.reflectance > 5 ? false : true;
            self.dashSensorRear.hidden = SDistFBF.reflectance > 5 ? false : true;

            if ([self.detectMovementSwitch isOn]) {
                
                double lin=50;
                double ang;
        
                if (SDistFRF.reflectance > 2) {
                    ang = SDistFRF.reflectance > 10 ? -M_PI / 3 : -M_PI / 4;
                } else {
                    if (SDistFLF.reflectance > 5) {
                        ang = SDistFLF.reflectance > 10 ? M_PI / 3 : M_PI / 4;
                    } else {
                        ang = M_PI / 4;
                    }
                }
    
                // are we hitting a wall ?
                if (SDistFLF.reflectance > WALL_REFLECTANCE || SDistFRF.reflectance > WALL_REFLECTANCE) {
                    lin = -50;
                    ang=0;
                }
            
                WWCommandSet *moveCommand = [WWCommandSet new];
                WWCommandBodyLinearAngular *linAng = [[WWCommandBodyLinearAngular alloc] initWithLinear:lin
                                                                                        angular:ang];
                [moveCommand setBodyLinearAngular:linAng];
        
                [self sendCommandSetToRobots:moveCommand];
            }
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
        
//        NSLog(@"%3.2f", SMic.triangulationConfidence);
//        NSLog(@"%3.2f", SDistFRF.distance);
//        NSLog(@"%d", SMic.clapDetected);
//        NSLog(@"%3.2f %3.2f %3.2f", BodyPose.radians, BodyPose.x, BodyPose.y);
        
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

//
//  DriveViewController.m
//  dashanddot
//
//  Created by Shell Shrader on 12/6/14.
//  Copyright (c) 2014 Shell Shrader. All rights reserved.
//


#import "DriveViewController.h"

@implementation DriveViewController

const double NOT_SET = -999;

double offsetX = NOT_SET;
double offsetY = NOT_SET;

BOOL touched = false;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = .2;

    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                [self outputMotionData:motion];
                                            }];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionManager finalize];
}

-(void)outputMotionData:(CMDeviceMotion *)motion {
    
    if (!touched) return;
    
    double x = -(motion.gravity.x + motion.userAcceleration.x);
    double y = -(motion.gravity.y + motion.userAcceleration.y);

    if (offsetX == NOT_SET) {
        offsetX = x;
        offsetY = y;
    }
    
    // normalize 45 degrees to 1
    x = (x - offsetX) * 2.22;
    y = (y - offsetY) * 2.22;
    
    // x dead zone
    if (ABS(x) < .1) {
        x = 0;
    } else {
        x = x + (x > 0 ? -.1 : .1);
    }
    
    // y dead zone
    if (ABS(y) < .1) {
        y = 0;
    } else {
        y = y + (y > 0 ? -.1 : .1);
    }
   
    // max throw
    if (x > 1) x = 1;
    if (y > 1) y = 1;
    if (x < -1) x = -1;
    if (y < -1) y = -1;
    
    // x measures linear velocity -100 to 100 ratio
    // y measures angular velocity -8 to 8 ratio
    WWCommandSet *moveCommand = [WWCommandSet new];
    WWCommandBodyLinearAngular *linAng = [[WWCommandBodyLinearAngular alloc] initWithLinear:100 * x
                                                                                    angular:8 * y];
    [moveCommand setBodyLinearAngular:linAng];
    
    [self sendCommandSetToRobots:moveCommand];
    
//    NSLog(@"x=%3.2f y=%3.2f",  100 * x, 8 * y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touched = true;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touched = false;
    offsetX = NOT_SET;
    
    [self sendCommandSetToRobots:[WWCommandToolbelt moveStop]];
}

@end

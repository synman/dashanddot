//
//  SecondViewController.h
//  dashanddot
//
//  Created by Shell Shrader on 12/6/14.
//  Copyright (c) 2014 Shell Shrader. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SensorsViewController : UIViewController <WWRobotDelegate>

@property (nonatomic, strong) NSArray *connectedRobots;

@end


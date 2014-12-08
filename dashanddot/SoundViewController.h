//
//  FirstViewController.h
//  dashanddot
//
//  Created by Shell Shrader on 12/6/14.
//  Copyright (c) 2014 Shell Shrader. All rights reserved.
//

@interface SoundViewController : UIViewController  <WWRobotDelegate>

@property (nonatomic, strong) NSArray *connectedRobots;

- (IBAction)playSound:(id)sender;

@end


//
//  RobotListViewController.h
//  dashanddot
//
//  Created by Shell Shrader on 12/7/14.
//  Copyright (c) 2014 Shell Shrader. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RobotListViewController : UITableViewController<WWRobotManagerDelegate>

@property (nonatomic, strong) WWRobotManager *manager;

@end


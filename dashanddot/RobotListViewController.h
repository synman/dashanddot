//
//  RobotListViewController.h
//  dashanddot
//
//  Created by Shell Shrader on 12/7/14.
//  Copyright (c) 2014 Shell Shrader. All rights reserved.
//

@interface RobotListViewController : UITableViewController <WWRobotManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *detailsButton;
@property (nonatomic, strong) WWRobotManager *manager;
@property NSMutableArray *robots;

- (void) checkIfCollapsed;

@end


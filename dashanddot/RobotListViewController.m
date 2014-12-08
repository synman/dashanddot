//
//  RobotListViewController.m
//  dashanddot
//
//  Created by Shell Shrader on 12/7/14.
//  Copyright (c) 2014 Shell Shrader. All rights reserved.
//

#import "RobotListViewController.h"
#import "RobotListTableViewCell.h"

//@interface RobotListViewController ()
//
//@property NSMutableArray *robots;
//
//
//@end

@implementation RobotListViewController

NSArray *navButtons = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    navButtons = self.navigationItem.rightBarButtonItems;
    self.robots = [NSMutableArray new];
    
    // iniitalize our table
    [self.tableView registerNib:[UINib nibWithNibName:@"RobotListTableViewCell" bundle:nil] forCellReuseIdentifier:@"RobotListTableViewCell"];

    self.tableView.rowHeight = 130;
    UIColor *start = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.15];
    UIColor *stop = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.45];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self.view bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)start.CGColor, (id)stop.CGColor, nil];
    [self.tableView.layer insertSublayer:gradient atIndex:0];

    // setup robot manager
    self.manager = [WWRobotManager manager];
    NSAssert(self.manager, @"unable to instantiate robot manager");
    self.manager.delegate = self;
    
    [self.manager startScanningForRobots:2.0f];
}

- (void) viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
    [self performSelector:@selector(checkIfCollapsed) withObject:nil afterDelay:.1];
}

- (void) checkIfCollapsed {
    if (self.splitViewController.collapsed) {
        [self.navigationItem setRightBarButtonItems:navButtons animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItems:nil animated:NO];
    }
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
    [self checkIfCollapsed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.robots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RobotListTableViewCell *cell = (RobotListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RobotListTableViewCell" forIndexPath:indexPath];
    
    // status
    WWRobot *robot = (WWRobot *)self.robots[indexPath.row];
    if (robot.isConnected) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:50/255.0 green:200/255.0 blue:50/255.0 alpha:0.6];
    }
    else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.6];
    }
    
    // robot info
    NSMutableString *detail = [NSMutableString stringWithCapacity:200];
//    [detail appendFormat:@"uuId: %@\n", robot.uuId];
    [detail appendFormat:@"Firmware %@\n", robot.firmwareVersion];
//    [detail appendFormat:@"Serial: %@\n", robot.serialNumber];
    [detail appendFormat:@"RSSI %d dB\n", robot.signalStrength.intValue];
    [detail appendFormat:@"Personality color: %d\n", robot.personalityColorIndex];
    [detail appendFormat:@"Robot Type: %d\n", robot.robotType];
    
    cell.infoLabel.text = detail;
    
    // robot name
    cell.nameLabel.text = robot.name;
    
    // image
    switch (robot.robotType) {
        case WW_ROBOT_DOT:
            cell.robotImageView.image = [UIImage imageNamed:@"dot.png"];
            break;
        case WW_ROBOT_DASH:
            cell.robotImageView.image = [UIImage imageNamed:@"dash.png"];
            
        default:
            break;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WWRobot *robot = self.robots[indexPath.row];
    if (robot.isConnected) {
        [self.manager disconnectFromRobot:robot];
    }
    else {
        [self.manager connectToRobot:robot];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void) manager:(WWRobotManager *)manager didDiscoverRobot:(WWRobot *)robot {
    if (![self.robots containsObject:robot]) {
        // found new robots, refresh list
        [self.robots addObject:robot];
        [self.tableView reloadData];
    }
}

- (void) manager:(WWRobotManager *)manager didUpdateDiscoveredRobots:(WWRobot *)robot {
    // existing robots have new data, refresh
    [self.tableView reloadData];
}

- (void) manager:(WWRobotManager *)manager didLoseRobot:(WWRobot *)robot {
    // lost connectivity with existing robot, refresh list
    [self.robots removeObject:robot];
    [self.tableView reloadData];
}

- (void) manager:(WWRobotManager *)manager didConnectRobot:(WWRobot *)robot {
    // connected with robot, refresh
    [self.tableView reloadData];
}

- (void) manager:(WWRobotManager *)manager didFailToConnectRobot:(WWRobot *)robot error:(WWError *)error {
    NSLog(@"failed to connect to robot: %@, with error: %@", robot.name, error);
    [NSNumber numberWithUnsignedInteger:WW_SENSOR_BUTTON_MAIN];
}

- (void) manager:(WWRobotManager *)manager didDisconnectRobot:(WWRobot *)robot {
    // disconnected with robot, refresh
    [self.tableView reloadData];
}

@end
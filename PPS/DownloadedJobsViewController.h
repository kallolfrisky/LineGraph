//
//  DownloadedJobsViewController.h
//  PPS
//
//  Created by Najmul Hasan on 5/29/15.
//  Copyright (c) 2015 Instalogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadedJobsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSMutableArray *jobs;
@property (nonatomic, retain) UIViewController *parentController;

@end

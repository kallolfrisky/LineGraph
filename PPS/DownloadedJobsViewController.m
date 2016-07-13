//
//  DownloadedJobsViewController.m
//  PPS
//
//  Created by Najmul Hasan on 5/29/15.
//  Copyright (c) 2015 Instalogic. All rights reserved.
//

#import "DownloadedJobsViewController.h"
#import "DataViewController.h"

@interface DownloadedJobsViewController ()

@end

@implementation DownloadedJobsViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    _jobs = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self makeJobList];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_jobs count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"DownloadedJobCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = _jobs[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *jobName = _jobs[indexPath.row];
    
    [(DataViewController*)self.parentController setJobFileName:jobName];
    [(DataViewController*)self.parentController drawDataInGraph];
    
    [[NSUserDefaults standardUserDefaults] setObject:jobName forKey:@"MyJobName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)makeJobList
{
    [_jobs removeAllObjects];    // clear out the old docs and start over
    
    _jobs = [NSMutableArray arrayWithArray:@[@"SampleJob1 (191)", @"SampleJob2 (8120)"]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

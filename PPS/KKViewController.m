//
//  KKViewController.m
//  ReferralHive
//
//  Created by Najmul Hasan on 11/14/14.
//  Copyright (c) 2014 Najmul Hasan. All rights reserved.
//

#import "KKViewController.h"

@interface KKViewController (){
    
    CAGradientLayer *gradientBG;
}

@end

@implementation KKViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self insertBackgroundLayer];
}

- (void)insertBackgroundLayer{
    
    [gradientBG removeFromSuperlayer];
    
    gradientBG = [CAGradientLayer layer];
    gradientBG.frame = self.view.bounds;
    gradientBG.colors = [NSArray arrayWithObjects:(id)[APP_THEME_COLOR_TOP CGColor], (id)[APP_THEME_COLOR_BELLOW CGColor], nil];
    [self.view.layer insertSublayer:gradientBG atIndex:0];
}

- (void) orientationChanged:(NSNotification *)note
{
    [self insertBackgroundLayer];
    
    UIDevice * device = note.object;
    NSLog(@"device.orientation:%ld",(long)device.orientation);
}

- (void)resetNavBar{

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

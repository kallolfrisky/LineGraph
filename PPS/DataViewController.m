//
//  DataViewController.m
//  PPS
//
//  Created by Najmul Hasan on 1/2/15.
//  Copyright (c) 2015 Instalogic. All rights reserved.
//

#import "DataViewController.h"
#import "ARLineChartView.h"
#import "ARLineChartCommon.h"
#import "DownloadedJobsViewController.h"
#import "ListPreviewController.h"

#define TABLE_DATA_PLIST @"PortconfigStrings"

#define CABLE_CONNECTED_TEXT @"Connected";
#define CABLE_NOT_CONNECTED_TEXT @"Not Connected";
#define CABLE_REQUIRES_PASSCODE_TEXT @"Passcode Required"

#define MAX_VERTICS 250

#define     ILQueue                 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface DataViewController (){

    NSArray *recJobUnits;
    NSOperationQueue *queue;
    NSMutableArray *dataSource;
    
    UIDeviceOrientation LAST_ORIENTATION;
}

@property (nonatomic, retain) IBOutlet UIView *fakeView;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (strong, nonatomic) ARLineChartView *lineChartView;
@property (nonatomic, retain) NSArray *values;

@end

@implementation DataViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MyJobName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    queue = [[NSOperationQueue alloc] init];
    dataSource = [NSMutableArray array];
    
    [_searchView makeBorderCornerRadius:_searchView.frame.size.height/2 withColor:[UIColor colorWithWhite:0.0 alpha:0.4]];
    [_searchView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    [self drawDataInGraph];
}

- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    [queue cancelAllOperations];
    [dataSource removeAllObjects];
}

- (void)drawDataInGraph
{
    if (!_jobFileName) return;
    
    if (self.lineChartView){
    
        [self.lineChartView removeFromSuperview];
    }
    
    [self.view bringSubviewToFront:_searchView];
    
    NSBlockOperation *operationBlock = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = operationBlock;
    
    [operationBlock addExecutionBlock:^{
        
        if ([weakOp isCancelled]) return ;
        
        //************* Test: Create Data Source *************
        
        if (dataSource.count == 0){
        
            NSString *txtFilePath = [[NSBundle mainBundle] pathForResource:_jobFileName ofType:@"rec"];
            //    NSString *txtFilePath =  [DOC_FOLDER_PATH stringByAppendingPathComponent:_jobFileName];
            NSString *jobString = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
            
            NSArray *sentences = [jobString componentsSeparatedByString:@"\n"];
            int sampling = (sentences.count > MAX_VERTICS)?(int)(sentences.count / MAX_VERTICS):1;
            
            [sentences enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSString *sentence = [(NSString*)obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSArray *chorses = [sentence componentsSeparatedByString:@":"];
                if ([chorses count] == 2) {
                    
                    if (idx == 3) {
                        recJobUnits = [chorses[1] componentsSeparatedByString:@","];
                    }
                    
                }else{
                    
                    if (idx%sampling == 0){
                    
                        chorses = [sentence componentsSeparatedByString:@"        "];
                        if ([chorses count] == 3) {
                            
                            RLLineChartItem *item = [[RLLineChartItem alloc] init];
                            
                            NSString *time = [chorses[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            NSString *pressure = [chorses[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            NSString *temperature = [chorses[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            
                            item.xValue = [time doubleValue] ;
                            item.y1Value = ([pressure doubleValue]) ;
                            item.y2Value = ([temperature doubleValue]) ;
                            
                            [dataSource addObject:item];
                        }
                    }
                }
            }];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            ////////////// Create Line Char //////////////////////////
            CGRect rect = CGRectMake(0, 0,
                                     _fakeView.frame.size.width,
                                     _fakeView.frame.size.height - 17);
            
            NSString *pressureTitle = [NSString stringWithFormat:@"PRESSURE (%@)",(![@"(null)" isEqualToString:recJobUnits[1]])?recJobUnits[1]:@"kPaa"];
            NSString *temperatureTitle = [NSString stringWithFormat:@"TEMPERATURE (%@)",(![@"(null)" isEqualToString:recJobUnits[2]])?recJobUnits[2]:@"degC"];
            
            self.lineChartView = [[ARLineChartView alloc] initWithFrame:rect dataSource:dataSource xTitle:@"TIME (hours)" y1Title:pressureTitle y2Title:temperatureTitle desc1:@"Pressure" desc2:@"Temperature"];
            [_fakeView addSubview:self.lineChartView];
            [self.lineChartView setBackgroundColor:[UIColor clearColor]];
            
//            [self.lineChartView initialViewSetUp];
        }];
    }];
    
    [queue addOperation:operationBlock];
    
    //************ End Test *********************
}

- (IBAction)zoomUpAction:(id)sender
{
    [self.lineChartView zoomUp];
}
- (IBAction)zoomDownAction:(id)sender
{
    [self.lineChartView zoomDown];
}
- (IBAction)zoomOriginalAction:(id)sender
{
    [self.lineChartView zoomOriginal];
}
- (void)zoomHorizontaUpAction:(id)sender
{
    [self.lineChartView zoomHorizontalUp];
}
- (void)zoomHorizontaDownAction:(id)sender
{
    [self.lineChartView zoomHorizontalDown];
}
- (void)zoomVerticalUpAction:(id)sender
{
    [self.lineChartView zoomVerticalUp];
}
- (void)zoomVerticalDownAction:(id)sender
{
    [self.lineChartView zoomVerticalDown];
}

- (void) orientationChanged:(NSNotification *)note
{
    [super orientationChanged:note];
    UIDevice * device = note.object;
    if (LAST_ORIENTATION == device.orientation) return;
    
    if (
        (device.orientation == UIDeviceOrientationPortrait) ||
        (device.orientation == UIDeviceOrientationLandscapeLeft) ||
        (device.orientation == UIDeviceOrientationLandscapeRight)
        ) {
            [self drawDataInGraph];
            LAST_ORIENTATION = device.orientation;
        }
}

- (long double)makePressureConversion:(long double)psia_Value{

    long double convertedValue = psia_Value;

    NSString *filePath =  [DOC_FOLDER_PATH stringByAppendingPathComponent:@"SettingsDict.plist"];
    NSMutableDictionary *userSettingsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    float Atmospheric_Value = [userSettingsDict[@"atmospheric_pressure"] floatValue];
    
    if ([userSettingsDict[@"pressure_units"] isEqualToString:@"Kpaa"]) {
        convertedValue = psia_Value * 6.89476;
    }else if ([userSettingsDict[@"pressure_units"] isEqualToString:@"MPaa"]){
        convertedValue = psia_Value * 0.00689476;
    }else if ([userSettingsDict[@"pressure_units"] isEqualToString:@"psig"]){
        convertedValue = (psia_Value - Atmospheric_Value);
    }else if ([userSettingsDict[@"pressure_units"] isEqualToString:@"Kpag"]){
        convertedValue = (psia_Value - Atmospheric_Value) * 6.89476;
    }else if ([userSettingsDict[@"pressure_units"] isEqualToString:@"MPag"]){
        convertedValue = (psia_Value - Atmospheric_Value) * 0.00689476;
    }
    
    return convertedValue;
}

- (long double)makeTemperatureConversion:(long double)DegC_Value{
    
    long double convertedValue = DegC_Value;
    
    NSString *filePath =  [DOC_FOLDER_PATH stringByAppendingPathComponent:@"SettingsDict.plist"];
    NSMutableDictionary *userSettingsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    if ([userSettingsDict[@"temperature_units"] isEqualToString:@"DegF"]) {
        convertedValue = (DegC_Value * 1.8) + 32;
    }
    
    return convertedValue;
}

- (void)logToFile:(NSString*)log{

    //Get the file path
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"MyLog.txt"];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    //append text to file (you'll probably want to add a newline every write)
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender{

    if ([identifier isEqualToString:@"ShowListPreview"]) {
        
        if (!_jobFileName) {
            [SVProgressHUD showImage:nil status:@"No jobs loaded yet,\nPlease load a job first" maskType:SVProgressHUDMaskTypeGradient];
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowLocalJobs"]) {

        DownloadedJobsViewController *downloadedJobsVC = [segue destinationViewController];
        downloadedJobsVC.parentController = self;
    }
    
    if ([segue.identifier isEqualToString:@"ShowListPreview"]) {
        
        UINavigationController *nav = [segue destinationViewController];
        ListPreviewController *controller = [nav.viewControllers firstObject];
        
        controller.jobFileName = _jobFileName;
        controller.recJobUnits = recJobUnits;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

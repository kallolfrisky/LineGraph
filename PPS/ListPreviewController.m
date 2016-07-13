//
//  ListPreviewController.m
//  PPS
//
//  Created by Najmul Hasan on 8/21/15.
//  Copyright (c) 2015 Instalogic. All rights reserved.
//

#import "ListPreviewController.h"
#import "ColumnCell.h"

NSString *kColumnCell = @"ColumnCellID";

@interface ListPreviewController (){

    NSArray *tableHeaders;
    IBOutlet UICollectionView *myCollectionView;
    
    NSMutableArray *dataSource;
    NSTimeInterval timeStamp;
}

@end

@implementation ListPreviewController

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    dataSource = [NSMutableArray array];
    tableHeaders = @[@"Index", @"Calendar\nTime", @"Time\n(hrs)", @"Press.\n(psia)", @"Temp.\n(DegC)"];
    
    [self getJobData];
}

- (IBAction)closeMe:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void) orientationChanged:(NSNotification *)note
{
    [super orientationChanged:note];
    
    [myCollectionView reloadData];
}

- (void)getJobData{

    NSString *txtFilePath = [[NSBundle mainBundle] pathForResource:_jobFileName ofType:@"rec"];
    NSString *jobString = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *sentences = [jobString componentsSeparatedByString:@"\n"];
    [sentences enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *sentence = [(NSString*)obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSArray *chorses = [sentence componentsSeparatedByString:@":"];
        if ([chorses count] == 2) {
            
            if (idx == 0) {
                timeStamp = [[DataModel sharedInstance] convertDelphiTimeStampToiOSTimeStamp:chorses[1]];
                NSLog(@"timeStamp: %f",timeStamp);
            }
            
            if (idx == 3) {
                
                NSString *pressureTitle = [NSString stringWithFormat:@"Press.\n(%@)",(![@"(null)" isEqualToString:_recJobUnits[1]])?_recJobUnits[1]:@"kPaa"];
                NSString *temperatureTitle = [NSString stringWithFormat:@"Temp.\n(%@)",(![@"(null)" isEqualToString:_recJobUnits[2]])?_recJobUnits[2]:@"degC"];
                
                tableHeaders = @[@"Index", @"Calendar\nTime", @"Time\n(hrs)", pressureTitle,temperatureTitle];
            }
            
        }else{
            
            chorses = [sentence componentsSeparatedByString:@"        "];
            if ([chorses count] == 3) {
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
//                [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                
                NSString *calenderTime = (timeStamp==0)?@"":[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp ++]];
                
                NSString *time = [chorses[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *pressure = [chorses[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *temperature = [chorses[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSArray *itemArray = @[[NSString stringWithFormat:@"%lu",(unsigned long)dataSource.count + 1],calenderTime,time,pressure,temperature];
                
                [dataSource addObject:itemArray];
            }
        }
    }];
    
    [myCollectionView reloadData];
}

//********************************************** Collectionview operations **********************************************

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return dataSource.count + 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return CGSizeMake(self.view.frame.size.width/5 -1, 44);
    }
    
    return CGSizeMake(self.view.frame.size.width/5 -1, 35);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    ColumnCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kColumnCell forIndexPath:indexPath];
    
    if (indexPath.section == 0){
        
        cell.backgroundColor = TABLE_HEADER_COLOR;
        cell.label.text = tableHeaders [indexPath.row];
        
    }else{
        
        NSArray *itemArray = dataSource [indexPath.section - 1];
        
        cell.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        cell.label.text = itemArray [indexPath.row];
    }
    
    return cell;
}

//***********************************************************************************************************************

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

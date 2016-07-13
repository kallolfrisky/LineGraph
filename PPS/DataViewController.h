//
//  DataViewController.h
//  PPS
//
//  Created by Najmul Hasan on 1/2/15.
//  Copyright (c) 2015 Instalogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : KKViewController <UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSString *jobFileName;

- (void)drawDataInGraph;

@end


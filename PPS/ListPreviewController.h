//
//  ListPreviewController.h
//  PPS
//
//  Created by Najmul Hasan on 8/21/15.
//  Copyright (c) 2015 Instalogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListPreviewController : KKViewController  <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSString *jobFileName;
@property (nonatomic, strong) NSArray *recJobUnits;

@end

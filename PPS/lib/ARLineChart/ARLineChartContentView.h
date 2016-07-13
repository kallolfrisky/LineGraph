//
//  SportLineChartContentView.h
//  testLineChart
//
//  Created by LongJun on 13-12-21.
//  Copyright (c) 2013年 LongJun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARLineChartView.h"

@interface ARLineChartContentView : UIView

@property CGPoint contentScroll;

//Constructor, you must use
- (id)initWithFrame:(CGRect)frame dataSource:(NSArray*)dataSource;

//x And y axes simultaneously amplify a scale
- (void)zoomUp;
//x-axis and y-axis while decreasing a scale
- (void)zoomDown;
//x-axis and y-axis revert to the original scale
- (void)zoomOriginal;

//x-axis zoom in on a scale
- (void)zoomHorizontalUp;
//x-axis decreases a scale
- (void)zoomHorizontalDown;

//a y-axis zoom scale
- (void)zoomVerticalUp;
//a y-axis scale is reduced
- (void)zoomVerticalDown;

//Refresh Chart
- (void)refreshData:(NSArray*)dataSource;

@end

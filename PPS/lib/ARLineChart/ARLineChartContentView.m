//
//  SportLineChartContentView.m
//  testLineChart
//
//  Created by LongJun on 13-12-21.
//  Copyright (c) 2013年 LongJun. All rights reserved.
//

#import "ARLineChartContentView.h"
#import "ARLineChartCommon.h"

#define DEFAULT_Y_COUNT 10 //可见区域y轴竖线总数
#define DEFAULT_X_COUNT 10 //可见区域x轴总数

typedef enum {
    XViewAll    = 0, //x轴显示所有
    XViewLast   = 1  //x轴显示最后部分
}XView;

@interface ARLineChartContentView ()

@property (strong, nonatomic) NSMutableArray *xArray; //x轴刻度
@property (strong, nonatomic) NSMutableArray *y1Array; //左边y轴刻度
@property (strong, nonatomic) NSMutableArray *y2Array; //右边y轴刻度

@property (strong, nonatomic) NSArray *dataSource; //数据源
@property (strong, nonatomic) NSString *msg;

@property CGFloat marginLeft;
@property CGFloat marginRight;
@property CGFloat marginBottom;
@property (strong, nonatomic) UIFont *xyTextFont;
@property (strong, nonatomic) UIColor *xyTextColor;
@property CGPoint originPoint;
@property CGPoint leftTopPoint;
@property CGPoint rightBottomPoint;
@property CGFloat xPerStepWidth;
@property CGFloat yPerStepHeight;
@property UIColor *dataLineColor;
@property CGFloat xPerValue;
@property NSInteger currXStepCount; //当前X轴刻度总数
@property NSInteger currYStepCount; //当前y轴刻度总数

@property int maxHeight;
@property int maxWidth;
@property XView xview;
@property CGPoint myTouchPoint;

static bool isLineIntersectRectangle(CGFloat linePointX1,
                                     CGFloat linePointY1,
                                     CGFloat linePointX2,
                                     CGFloat linePointY2,
                                     CGFloat rectangleLeftTopX,
                                     CGFloat rectangleLeftTopY,
                                     CGFloat rectangleRightBottomX,
                                     CGFloat rectangleRightBottomY);
@end


@implementation ARLineChartContentView

- (id)initWithFrame:(CGRect)frame dataSource:(NSArray*)dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //        self.backgroundColor = [UIColor yellowColor];
        
        
        //////////////////// Data source sorting (bubble sort, data x-axis (distance) from small to large order) /////////////////
        //According to RLLineChartItem.xValue Sort Properties
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"_xValue" ascending:YES];
        self.dataSource = [dataSource sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]];
        
//        //************* test Print sorting *************
//        for (NSInteger i = 0; i < self.dataSource.count; i++) {
//            SportLineChartItem *item = [self.dataSource objectAtIndex:i];
//            NSLog(@"排序后： item.xValue=%.2lf, item.y1Value=%.2lf, item.y2Value=%.2lf", item.xValue, item.y1Value, item.y2Value);
//        }
//        //************ end test *********************
        

        //Generating x-axis, y-axis left and right y-axis scale values
        [self buildXYSetpArray:DEFAULT_X_COUNT yStepCount:DEFAULT_Y_COUNT];
        self.currXStepCount = DEFAULT_X_COUNT;
        self.currYStepCount = DEFAULT_Y_COUNT;
        
        
        self.xyTextFont = [UIFont systemFontOfSize:8];
        self.xyTextColor = [UIColor lightGrayColor];
        self.dataLineColor = xylineColor;
        
        ////////////// Find the largest number into a string, get the height / width; x-axis y-axis draw aside the height / width of the scale of the string /////////////////
        double xMax =  [[self.xArray objectAtIndex:0] integerValue];
        for (NSNumber *num in self.xArray) {
            if ([num doubleValue] > xMax) {
                xMax = [num doubleValue];
            }
        }
        NSString *xMaxStr = [NSString stringWithFormat:@"%.2lf", xMax];
        CGSize size = [xMaxStr sizeWithFont: self.xyTextFont];
        self.marginBottom = size.height + 6;
        //
        double y1Max =  [[self.y1Array objectAtIndex:0] integerValue];
        for (NSNumber *num in self.y1Array) {
            if ([num doubleValue] > y1Max) {
                y1Max = [num doubleValue];
            }
        }
        NSString *y1MaxStr = [NSString stringWithFormat:@"%.2lf", y1Max];
        size = [y1MaxStr sizeWithFont: self.xyTextFont];
        self.marginLeft = 0.0; //size.width;
        //
        double y2Max =  [[self.y2Array objectAtIndex:0] integerValue];
        for (NSNumber *num in self.y2Array) {
            if ([num doubleValue] > y2Max) {
                y2Max = [num doubleValue];
            }
        }
        NSString *y2MaxStr = [NSString stringWithFormat:@"%.2lf", y2Max];
        size = [y2MaxStr sizeWithFont: self.xyTextFont];
        self.marginRight = 0.0;//size.width;
        
        //
        self.originPoint = CGPointMake(self.marginLeft, //+12
                                       self.frame.size.height - self.marginBottom - 2);
        self.leftTopPoint = CGPointMake(self.originPoint.x, 0);
        self.rightBottomPoint = CGPointMake(self.frame.size.width - self.marginRight, //-12
                                            self.originPoint.y);
        
        //
        //Step away from the x-axis of each of
        self.xPerStepWidth = (self.rightBottomPoint.x - self.originPoint.x) / (DEFAULT_X_COUNT) - 0.1;
        self.maxWidth = (self.xArray.count - 1) * self.xPerStepWidth;
        
        //Step away from the y-axis of each of
        self.yPerStepHeight = (self.originPoint.y - self.leftTopPoint.y) / (DEFAULT_Y_COUNT) - 0.1;
        //y-axis maximum number of Step
        NSInteger yStepCount = (self.y1Array.count > self.y2Array.count ? self.y1Array.count : self.y2Array.count);
        self.maxHeight = (yStepCount - 1) * self.yPerStepHeight;
        
        
    }
    return self;
}

- (void)buildXYSetpArray:(NSInteger)xStepCount yStepCount:(NSInteger)yStepCount
{
    //////////////////// Generate x-axis, y-axis left and right y-axis scale value array ///////////////////////
    if (self.dataSource.count >= 2) {
        float xMin, xMax, y1Min, y1Max, y2Min, y2Max;
        RLLineChartItem *item = [self.dataSource objectAtIndex:0];
        xMin = item.xValue; xMax = item.xValue;
        y1Min = item.y1Value; y1Max = item.y1Value;
        y2Min = item.y2Value; y2Max = item.y2Value;
        
        for (NSInteger i = 1; i < self.dataSource.count; i++) {
            RLLineChartItem *item = [self.dataSource objectAtIndex:i];
            if (item.xValue < xMin)
                xMin = item.xValue;
            else if (item.xValue > xMax)
                xMax = item.xValue;
            
            if (item.y1Value < y1Min)
                y1Min = item.y1Value;
            else if (item.y1Value > y1Max)
                y1Max = item.y1Value;
            
            if (item.y2Value < y2Min)
                y2Min = item.y2Value;
            else if (item.y2Value > y2Max)
                y2Max = item.y2Value;
        }
        
        //x-axis: kilometers
        if (!self.xArray)
            self.xArray = [NSMutableArray array];
        else
            [self.xArray removeAllObjects];
        float xPer = (xMax ) / xStepCount ;
        self.xPerValue = xPer;
        for (int i=0; i<xStepCount; i++) {
            [self.xArray addObject:[NSNumber numberWithFloat: (xPer + i * xPer)]];
        }
        
        //Left y-axis: altitude
        if (!self.y1Array)
            self.y1Array = [NSMutableArray array];
        else
            [self.y1Array removeAllObjects];
        float y1Per = (y1Max ) / yStepCount ;
        for (int i=0; i<yStepCount; i++) {
            [self.y1Array addObject:[NSNumber numberWithFloat: (y1Per + i * y1Per)]];
        }
        
        //The right y-axis: Speed
        if (!self.y2Array)
            self.y2Array = [NSMutableArray array];
        else
            [self.y2Array removeAllObjects];
        float y2Per = (y2Max ) / yStepCount ;
        for (int i=0; i<yStepCount; i++) {
            [self.y2Array addObject:[NSNumber numberWithFloat: (y2Per + i * y2Per)]];
        }
    }
    else if (self.dataSource.count == 1) {
     
        RLLineChartItem *item = [self.dataSource objectAtIndex:0];
        //千米
        NSNumber *num1 = [NSNumber numberWithDouble:item.xValue];
        self.xArray = [NSMutableArray arrayWithObject:num1];
        //海拔
        NSNumber *num2 = [NSNumber numberWithDouble:item.y1Value];
        self.y1Array = [NSMutableArray arrayWithObject:num2];
        //速度
        NSNumber *num3 = [NSNumber numberWithDouble:item.y2Value];
        self.y2Array = [NSMutableArray arrayWithObject:num3];
    }
}

- (void)buildXSetpArray:(NSInteger)xStepCount
{
    //////////////////// Generate x-axis scale value array ///////////////////////
    if (self.dataSource.count >= 2) {
        float xMin, xMax;
        RLLineChartItem *item = [self.dataSource objectAtIndex:0];
        xMin = item.xValue; xMax = item.xValue;
        
        for (NSInteger i = 1; i < self.dataSource.count; i++) {
            RLLineChartItem *item = [self.dataSource objectAtIndex:i];
            if (item.xValue < xMin)
                xMin = item.xValue;
            else if (item.xValue > xMax)
                xMax = item.xValue;
            
        }
        
        //x轴：千米
        if (!self.xArray)
            self.xArray = [NSMutableArray array];
        else
            [self.xArray removeAllObjects];
        float xPer = (xMax ) / xStepCount ;
        self.xPerValue = xPer;
        for (int i=0; i<xStepCount; i++) {
            [self.xArray addObject:[NSNumber numberWithFloat: (xPer + i * xPer)]];
        }
    }
    else if (self.dataSource.count == 1) {
        RLLineChartItem *item = [self.dataSource objectAtIndex:0];
        //千米
        NSNumber *num1 = [NSNumber numberWithDouble:item.xValue];
        self.xArray = [NSMutableArray arrayWithObject:num1];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //    //***** test *********
    //    [SportLineChartCommon drawPoint:context point:self.originPoint color:[UIColor redColor]];
    //    [SportLineChartCommon drawPoint:context point:self.leftTopPoint color:[UIColor greenColor]];
    //    [SportLineChartCommon drawPoint:context point:self.rightBottomPoint color:[UIColor purpleColor]];
    //    //****** end test ********
    
    
    ////////////////////// Horizontal //////////////////////////
    for (NSInteger index=0; index < self.xArray.count; index++) {
        
        NSNumber *num = [self.xArray objectAtIndex:index];
        NSString *valStr = [NSString stringWithFormat:@"%.3lf", [num doubleValue]]; //Rounded to two
        
        float xPosition = self.originPoint.x + (index+1)* self.xPerStepWidth + self.contentScroll.x;
        
        if (xPosition > self.originPoint.x && xPosition < self.rightBottomPoint.x) {
            
            //X-axis text painting
            [self.xyTextColor set];
            CGSize title1Size = [valStr sizeWithFont:self.xyTextFont];
            CGRect titleRect1 = CGRectMake(xPosition - (title1Size.width)/2,
                                           self.originPoint.y + 4,
                                           title1Size.width,
                                           title1Size.height);
            [valStr drawInRect:titleRect1 withFont:self.xyTextFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
            
            //Draw a vertical line (does not include the vertical position of the origin)
            CGFloat dashPattern[]= {2.0, 2};
            CGContextSetLineDash(context, 0.0, dashPattern, 2); //Dotted effect
            [ARLineChartCommon drawLine:context
                                startPoint:CGPointMake(xPosition, self.originPoint.y)
                                  endPoint:CGPointMake(xPosition, self.leftTopPoint.y)
                                 lineColor:self.dataLineColor];
        }
    }
    
    /////////////////////// Horizontal line/////////////////////////
    
    for (NSInteger i = 0; i < self.y1Array.count; i++) {
        
        CGFloat y1Position = self.originPoint.y - (i+1) * self.yPerStepHeight + self.contentScroll.y; // - (textSize.height/2);
        
        if (y1Position < self.originPoint.y && y1Position > self.leftTopPoint.y) {

            //Draw a horizontal line (horizontal line position of the origin is not included)
            CGFloat dashPattern[]= {2.0, 2};
            CGContextSetLineDash(context, 0.0, dashPattern, 0); //Dotted effect
            [ARLineChartCommon drawLine:context
                             startPoint:CGPointMake(self.originPoint.x -2, y1Position)
                               endPoint:CGPointMake(self.rightBottomPoint.x, y1Position)
                              lineColor:self.dataLineColor];
        }
    }
    
    /////////////////////// The vertical lines/////////////////////////
    for (NSInteger i = 0; i < self.y2Array.count; i++) {
        
        CGFloat y2Position = self.originPoint.y - (i+1) * self.yPerStepHeight + self.contentScroll.y; // - (textSize.height/2);
        
        if (y2Position < self.originPoint.y && y2Position > self.leftTopPoint.y) {
            
            //Draw a horizontal line (horizontal line position of the origin is not included)
            CGFloat dashPattern[]= {6.0, 5};
            CGContextSetLineDash(context, 0.0, dashPattern, 2); //虚线效果
            [ARLineChartCommon drawLine:context
                             startPoint:CGPointMake(self.originPoint.x, y2Position)
                               endPoint:CGPointMake(self.rightBottomPoint.x, y2Position)
                              lineColor:self.dataLineColor];
        }
    }
    
    /////////////////////// Draw a line based on the data source /////////////////////////
    if (self.dataSource && self.dataSource.count > 0) {
        
        for (NSInteger i = 0; i < self.dataSource.count-1; i++) {
            RLLineChartItem *item = (RLLineChartItem*)[self.dataSource objectAtIndex:i];
            RLLineChartItem *item2 = (RLLineChartItem*)[self.dataSource objectAtIndex:i+1];
            
            float xPerStepVal = [(NSNumber*)[self.xArray objectAtIndex:0] floatValue];
            //        if (xPerStepVal == 0) xPerStepVal = [(NSNumber*)[self.xArray objectAtIndex:1] floatValue];
            float xPosition = self.originPoint.x + ((self.xPerStepWidth * item.xValue) / xPerStepVal) + self.contentScroll.x;
            float xPosition2 = self.originPoint.x + ((self.xPerStepWidth * item2.xValue) / xPerStepVal) + self.contentScroll.x;
            
            float y1PerStepVal = [(NSNumber*)[self.y1Array objectAtIndex:0] floatValue];
            //        if (y1PerStepVal == 0) y1PerStepVal = [(NSNumber*)[self.y1Array objectAtIndex:1] floatValue];
            float y1Position = self.originPoint.y - fabs(((self.yPerStepHeight * item.y1Value) / y1PerStepVal )) + self.contentScroll.y;
            float y1Position2 = self.originPoint.y - fabs(((self.yPerStepHeight * item2.y1Value) / y1PerStepVal )) + self.contentScroll.y;
            
            float y2PerStepVal = [(NSNumber*)[self.y2Array objectAtIndex:0] floatValue];
            //        if (y2PerStepVal == 0) y2PerStepVal = [(NSNumber*)[self.y2Array objectAtIndex:1] floatValue];
            float y2Position = self.originPoint.y - fabs(((self.yPerStepHeight * item.y2Value) / y2PerStepVal )) + self.contentScroll.y;
            float y2Position2 = self.originPoint.y - fabs(((self.yPerStepHeight * item2.y2Value) / y2PerStepVal )) + self.contentScroll.y;
            
            CGPoint startPoint = CGPointMake(xPosition, y1Position);
            CGPoint endPoint = CGPointMake(xPosition2, y1Position2);
            //        graphPoints1[i] = startPoint;
            
            CGPoint startPoint2 = CGPointMake(xPosition, y2Position);
            CGPoint endPoint2 = CGPointMake(xPosition2, y2Position2);
            
            CGFloat normal[1]={1};
            CGContextSetLineDash(context,0,normal,0); //Draw a solid line
            
            //Draw a line
            if ( isLineIntersectRectangle(xPosition, y1Position, xPosition2, y1Position2, _leftTopPoint.x, _leftTopPoint.y, _rightBottomPoint.x, _rightBottomPoint.y) )
            {
                [ARLineChartCommon drawGraphLine:context startPoint:startPoint endPoint:endPoint lineColor:line1Color];
                [ARLineChartCommon drawPoint:context point:startPoint withRadius:4.0 color:line1Color];
            }
            //Draw a line 2
            if ( isLineIntersectRectangle(xPosition, y2Position, xPosition2, y2Position2, _leftTopPoint.x, _leftTopPoint.y, _rightBottomPoint.x, _rightBottomPoint.y) )
            {
                [ARLineChartCommon drawGraphLine:context startPoint:startPoint2 endPoint:endPoint2 lineColor:line2Color];
                [ARLineChartCommon drawPoint:context point:startPoint2 withRadius:4.0 color:line2Color];
            }
        }
    }
    
    //    Left vertical shade
    [ARLineChartCommon drawRectangle:context withRect:CGRectMake(self.originPoint.x, self.leftTopPoint.y, 35, self.frame.size.height- 18) withColor:nil];
    
    //    Right vertical shade
    [ARLineChartCommon drawRectangle:context withRect:CGRectMake(self.rightBottomPoint.x - 25, self.leftTopPoint.y, 25, self.frame.size.height- 18) withColor:nil];
    
    //    bottom horizontal shade
    [ARLineChartCommon drawRectangle:context withRect:CGRectMake(self.originPoint.x, self.frame.size.height- 18, self.frame.size.width, 20) withColor:nil];
    
    /////////////////////// Left vertical Values/////////////////////////

    for (NSInteger i = 0; i < self.y1Array.count; i++) {
       
        NSNumber *num = [self.y1Array objectAtIndex:i];
        NSString *valStr = [NSString stringWithFormat:@"%.2lf", ([num doubleValue])];
        //        CGSize textSize = [valStr sizeWithFont: self.xyTextFont];
        
        CGFloat y1Position = self.originPoint.y - (i+1) * self.yPerStepHeight + self.contentScroll.y; // - (textSize.height/2);
        
        if (y1Position < self.originPoint.y && y1Position > self.leftTopPoint.y) {
            //Paintings left y-axis text
            [line1Color set];
            CGSize title1Size = [valStr sizeWithFont:self.xyTextFont];
            CGRect titleRect1 = CGRectMake(1,
                                           y1Position - (title1Size.height)/2,
                                           title1Size.width,
                                           title1Size.height);
            [valStr drawInRect:titleRect1 withFont:self.xyTextFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentRight];
        }
    }
    
    /////////////////////// The right of the vertical /////////////////////////
    for (NSInteger i = 0; i < self.y2Array.count; i++) {
      
        NSNumber *num = [self.y2Array objectAtIndex:i];
        NSString *valStr = [NSString stringWithFormat:@"%.2lf", ([num doubleValue])];
        //        CGSize textSize = [valStr sizeWithFont: self.xyTextFont];
        
        CGFloat y2Position = self.originPoint.y - (i+1) * self.yPerStepHeight + self.contentScroll.y; // - (textSize.height/2);
        
        if (y2Position < self.originPoint.y && y2Position > self.leftTopPoint.y) {
            //Painting right y-axis text
            [line2Color set];
            CGSize title1Size = [valStr sizeWithFont:self.xyTextFont];
            CGRect titleRect1 = CGRectMake(self.rightBottomPoint.x - title1Size.width -2, //self.rightBottomPoint.x + 2
                                           y2Position - (title1Size.height)/2,
                                           title1Size.width,
                                           title1Size.height);
            [valStr drawInRect:titleRect1 withFont:self.xyTextFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentRight];
        }
    }

    ///////////////// Left y-axis origin on Videos ////////////////////
    CGFloat normal[1]={1};
    CGContextSetLineDash(context,0,normal,0); //Draw a solid line
    
    UIColor *borderColor = xylineColor;//[UIColor blackColor];
    [ARLineChartCommon drawLine:context
                        startPoint:self.originPoint
                          endPoint:self.leftTopPoint
                         lineColor:borderColor];
    ///////////////// Painting right y-axis //////////////////////////
    [ARLineChartCommon drawLine:context
                        startPoint:self.rightBottomPoint
                          endPoint:CGPointMake(self.rightBottomPoint.x, self.leftTopPoint.y)
                         lineColor:borderColor];
    //////////////// Painted on the x-axis origin ///////////////////////
    [ARLineChartCommon drawLine:context
                        startPoint:CGPointMake(self.originPoint.x, self.originPoint.y)
                          endPoint:CGPointMake(self.rightBottomPoint.x, self.rightBottomPoint.y)
                         lineColor:borderColor];
    //////////////// Painted on top horizontal bar ///////////////////////
    [ARLineChartCommon drawLine:context
                     startPoint:self.leftTopPoint
                       endPoint:CGPointMake(self.rightBottomPoint.x, self.leftTopPoint.y)
                      lineColor:borderColor];
   
    if ([_msg length]) {
        
        //////////////// Painted on vertical selection bar ///////////////////////
        
        UIColor *orangeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5f];
        [ARLineChartCommon drawLine:context
                         startPoint:CGPointMake(_myTouchPoint.x, self.rightBottomPoint.y - 34.5)
                           endPoint:CGPointMake(_myTouchPoint.x, self.leftTopPoint.y)
                          lineColor:[UIColor orangeColor]];
        
        [ARLineChartCommon drawTriangle:context withRect:CGRectMake(_myTouchPoint.x - 8, self.rightBottomPoint.y - 35, 16, 8) withColor:orangeColor];
        CGRect msgBoxRect = CGRectMake(_myTouchPoint.x - 50, self.rightBottomPoint.y - 27, 100, 26);
        
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:msgBoxRect cornerRadius:5];
        [orangeColor setFill];
        [path fill];
        
        UIFont *font = [UIFont systemFontOfSize:6];
        CGRect msgRect = CGRectMake(_myTouchPoint.x - 50, self.rightBottomPoint.y - 25, 100, 24);
        [[UIColor whiteColor] set];
        [_msg drawInRect:msgRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    }
}

//static CGPoint s_p1;
//static CGPoint s_p2;
//CGFloat s_xDistance;
//CGFloat s_yDistance;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSArray * touchesArr=[[event allTouches] allObjects];
    //    if (touchesArr.count == 2) {
    //
    ////        s_p1 = [[touchesArr objectAtIndex:0] locationInView:self];
    ////        s_p2 =[[touchesArr objectAtIndex:1] locationInView:self];
    //        CGPoint p1 =[[touchesArr objectAtIndex:0] locationInView:self];
    //        CGPoint p2 =[[touchesArr objectAtIndex:1] locationInView:self];
    //
    //        //        CGFloat xDiff = fabs(p1.x-s_p1.x) + fabs(p2.x-s_p2.x);
    //        //        CGFloat yDiff = fabs(p1.y-s_p1.y) + fabs(p2.y-s_p2.y);
    //        s_xDistance = fabs(p2.x - p1.x);
    //        s_yDistance = fabs(p2.y - p1.y);
    //        NSLog(@"touchesBegan xDistance：%f",s_xDistance);
    //        NSLog(@"touchesBegan yDistance：%f",s_yDistance);
    //
    //    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray * touchesArr=[[event allTouches] allObjects];
    if (touchesArr.count == 1) {
        
        CGPoint touchLocation=[[touches anyObject] locationInView:self];
        CGPoint prevouseLocation=[[touches anyObject] previousLocationInView:self];
        float xDiffrance=touchLocation.x-prevouseLocation.x;
        float yDiffrance=touchLocation.y-prevouseLocation.y;
        
        _contentScroll.x+=xDiffrance;
        _contentScroll.y+=yDiffrance;
        
        if (_contentScroll.x >0) {
            _contentScroll.x=0;
        }
        if(_contentScroll.y<0)
        {
            _contentScroll.y=0;
        }
        
        if (-_contentScroll.x>self.maxWidth) {
            _contentScroll.x=-self.maxWidth;
        }
        if (_contentScroll.y>self.maxHeight) {
            _contentScroll.y=self.maxHeight;
        }
        
        [self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray * touchesArr=[[event allTouches] allObjects];
    if (touchesArr.count == 1) {
        
        _myTouchPoint = [[touches anyObject] locationInView:self];
        NSLog(@"_myTouchPoint.x:%f",_myTouchPoint.x);
        
        //Slotted xValue
//        NSInteger index = (_myTouchPoint.x - self.originPoint.x - self.contentScroll.x)/self.xPerStepWidth;
//        NSNumber *num = [self.xArray objectAtIndex:index - 1];
//        NSLog(@"Slotted xValue:%@",num);
        
        //Exact xValue
        float xPerStepVal = [(NSNumber*)[self.xArray objectAtIndex:0] floatValue];
        double xValue = ((_myTouchPoint.x - self.originPoint.x - self.contentScroll.x) * xPerStepVal)/self.xPerStepWidth;
        
        [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            RLLineChartItem *item = (RLLineChartItem*)obj;
            if (item.xValue >= xValue) {
                
                _msg = [NSString stringWithFormat:@"Time: %f\nPressure: %f\nTemperature: %f",item.xValue,item.y1Value,item.y2Value];
                *stop = YES;
            }
        }];
        
        [self setNeedsDisplay];
        
        UITouch *touch = [touches anyObject];
        if (touch.tapCount == 2) {
            NSLog(@"Double-click on the");
            if (self.xview == XViewLast) {
                [self zoomLastX];
                self.xview = XViewAll;
            }
            else {
                [self zoomOriginal];
                self.xview = XViewLast;
            }
        }
    }
    //    else if (touchesArr.count == 2) {
    //
    //        CGFloat len = 100-20, offset = 80-20;
    //        CGPoint p1 =[[touchesArr objectAtIndex:0] locationInView:self];
    //        CGPoint p2 =[[touchesArr objectAtIndex:1] locationInView:self];
    //
    //        CGFloat xDiff = fabs(p1.x-s_p1.x) + fabs(p2.x-s_p2.x);
    //        CGFloat yDiff = fabs(p1.y-s_p1.y) + fabs(p2.y-s_p2.y);
    ////        CGFloat xDiff = (p1.x-s_p1.x) + (p2.x-s_p2.x);
    ////        CGFloat yDiff = (p1.y-s_p1.y) + (p2.y-s_p2.y);
    //
    //        NSLog(@"捏合长度x：%f",xDiff);
    //        NSLog(@"捏合长度y：%f",yDiff);
    //
    //        CGFloat xDistance = fabs(p2.x - p1.x);
    //        CGFloat yDistance = fabs(p2.y - p1.y);
    //        NSLog(@"xDistance：%f",xDistance);
    //        NSLog(@"yDistance：%f",yDistance);
    //
    //
    //        if (xDiff >= len && yDiff <= offset) { //认为是水平捏合手势
    //            NSLog(@"是水平捏合手势");
    //            if (xDistance - s_xDistance > 0) { //双指向外
    //                NSLog(@"水平双指向外");
    //                [self zoomHorizontalUp];
    //            }
    //            else { //双指向内
    //                NSLog(@"水平双指向内");
    //                [self zoomHorizontalDown];
    //            }
    //        }
    //        else if (xDiff <= offset && yDiff >= len) { //认为是垂直捏合手势
    //            NSLog(@"是垂直捏合手势");
    //            if (yDistance - s_yDistance > 0) { //双指向外
    //                NSLog(@"垂直双指向外");
    //                [self zoomVerticalUp];
    //            }
    //            else { //双指向内
    //                NSLog(@"垂直双指向内");
    //                [self zoomVerticalDown];
    //            }
    //        }
    //        else  { //认为捏合手势
    //            NSLog(@"是捏合手势");
    //            if (xDistance - s_xDistance > 0 || yDistance - s_yDistance > 0) { //双指向外
    //                NSLog(@"捏合手势双指向外");
    //                [self zoomUp];
    //            }
    //            else { //双指向内
    //                NSLog(@"捏合手势双指向内");
    //                [self zoomDown];
    //            }
    //        }
    //
    //
    //    }
}

/** <p>判断线段是否在矩形内 </p>
 * 先看线段所在直线是否与矩形相交，
 * 如果不相交则返回false，
 * 如果相交，
 * 则看线段的两个点是否在矩形的同一边（即两点的x(y)坐标都比矩形的小x(y)坐标小，或者大）,
 * 若在同一边则返回false，
 * 否则就是相交的情况。
 * @param linePointX1 线段起始点x坐标
 * @param linePointY1 线段起始点y坐标
 * @param linePointX2 线段结束点x坐标
 * @param linePointY2 线段结束点y坐标
 * @param rectangleLeftTopX 矩形左上点x坐标
 * @param rectangleLeftTopY 矩形左上点y坐标
 * @param rectangleRightBottomX 矩形右下点x坐标
 * @param rectangleRightBottomY 矩形右下点y坐标
 * @return 是否相交
 */
static bool isLineIntersectRectangle(CGFloat linePointX1,
                                     CGFloat linePointY1,
                                     CGFloat linePointX2,
                                     CGFloat linePointY2,
                                     CGFloat rectangleLeftTopX,
                                     CGFloat rectangleLeftTopY,
                                     CGFloat rectangleRightBottomX,
                                     CGFloat rectangleRightBottomY)
{
    CGFloat  lineHeight = linePointY1 - linePointY2;
    CGFloat lineWidth = linePointX2 - linePointX1;  // 计算叉乘
    CGFloat c = linePointX1 * linePointY2 - linePointX2 * linePointY1;
    if ((lineHeight * rectangleLeftTopX + lineWidth * rectangleLeftTopY + c >= 0 && lineHeight * rectangleRightBottomX + lineWidth * rectangleRightBottomY + c <= 0)
        || (lineHeight * rectangleLeftTopX + lineWidth * rectangleLeftTopY + c <= 0 && lineHeight * rectangleRightBottomX + lineWidth * rectangleRightBottomY + c >= 0)
        || (lineHeight * rectangleLeftTopX + lineWidth * rectangleRightBottomY + c >= 0 && lineHeight * rectangleRightBottomX + lineWidth * rectangleLeftTopY + c <= 0)
        || (lineHeight * rectangleLeftTopX + lineWidth * rectangleRightBottomY + c <= 0 && lineHeight * rectangleRightBottomX + lineWidth * rectangleLeftTopY + c >= 0))
    {
        
        if (rectangleLeftTopX > rectangleRightBottomX) {
            CGFloat temp = rectangleLeftTopX;
            rectangleLeftTopX = rectangleRightBottomX;
            rectangleRightBottomX = temp;
        }
        if (rectangleLeftTopY < rectangleRightBottomY) {
            CGFloat temp1 = rectangleLeftTopY;
            rectangleLeftTopY = rectangleRightBottomY;
            rectangleRightBottomY = temp1;   }
        if ((linePointX1 < rectangleLeftTopX && linePointX2 < rectangleLeftTopX)
            || (linePointX1 > rectangleRightBottomX && linePointX2 > rectangleRightBottomX)
            || (linePointY1 > rectangleLeftTopY && linePointY2 > rectangleLeftTopY)
            || (linePointY1 < rectangleRightBottomY && linePointY2 < rectangleRightBottomY)) {
            return false;
        } else {
            return true;
        }
    } else {
        return false;
    }
}

//x-axis and y-axis simultaneously amplify a scale
- (void)zoomUp
{
    //x轴刻度总数量增加
    self.currXStepCount += 30;
    //Y轴刻度总数量增加
    self.currYStepCount += 60;
    
    //生成x轴、左y轴、右y轴刻度值
    [self buildXYSetpArray:self.currXStepCount yStepCount:self.currYStepCount];
    
    //    //x轴上每一个Step的距离
    //    self.xPerStepWidth = (self.rightBottomPoint.x - self.originPoint.x) / (self.currXStepCount) - 0.1;
    self.maxWidth = (self.xArray.count - 1) * self.xPerStepWidth;
    //
    //    //y轴上每一个Step的距离
    //    self.yPerStepHeight = (self.originPoint.y - self.leftTopPoint.y) / (self.currYStepCount) - 0.1;
    //y轴上最大Step数
    NSInteger yStepCount = (self.y1Array.count > self.y2Array.count ? self.y1Array.count : self.y2Array.count);
    self.maxHeight = (yStepCount - 1) * self.yPerStepHeight;
    
    _contentScroll.y = self.maxHeight - (self.frame.size.height - 60) ;
    
    //重绘
    [self setNeedsDisplay];
}
//x-axis and y-axis while decreasing a scale
- (void)zoomDown
{
    //increase the total number of the x-axis scale
    self.currXStepCount -= 30;
    if (self.currXStepCount < DEFAULT_X_COUNT) self.currXStepCount = DEFAULT_X_COUNT;
    //Increase the total number of Y-axis scale
    self.currYStepCount -= 60;
    if (self.currYStepCount < DEFAULT_Y_COUNT) self.currYStepCount = DEFAULT_Y_COUNT;
    
    //Generating x-axis, y-axis left and right y-axis scale values
    [self buildXYSetpArray:self.currXStepCount yStepCount:self.currYStepCount];
    
    //    //x轴上每一个Step的距离
    //    self.xPerStepWidth = (self.rightBottomPoint.x - self.originPoint.x) / (self.currXStepCount) - 0.1;
    self.maxWidth = (self.xArray.count - 1) * self.xPerStepWidth;
    //
    //    //y轴上每一个Step的距离
    //    self.yPerStepHeight = (self.originPoint.y - self.leftTopPoint.y) / (self.currYStepCount) - 0.1;
    //y轴上最大Step数
    NSInteger yStepCount = (self.y1Array.count > self.y2Array.count ? self.y1Array.count : self.y2Array.count);
    self.maxHeight = (yStepCount - 1) * self.yPerStepHeight;
    
    _contentScroll.y = self.maxHeight - (self.frame.size.height - 60);
    
    //重绘
    [self setNeedsDisplay];
}
//x-axis and y-axis revert to the original scale
- (void)zoomOriginal
{
    self.currXStepCount = DEFAULT_X_COUNT;
    self.currYStepCount = DEFAULT_Y_COUNT;
    _contentScroll.x=0;
    _contentScroll.y=0;
    
    //Generating x-axis, y-axis left and right y-axis scale values
    [self buildXYSetpArray:self.currXStepCount yStepCount:self.currYStepCount];
    
    //x轴上每一个Step的距离
    self.xPerStepWidth = (self.rightBottomPoint.x - self.originPoint.x) / (DEFAULT_X_COUNT) - 0.1;
    self.maxWidth = (self.xArray.count - 1) * self.xPerStepWidth;
    
    //    //y轴上每一个Step的距离
    //    self.yPerStepHeight = (self.originPoint.y - self.leftTopPoint.y) / (DEFAULT_Y_COUNT) - 0.1;
    //y轴上最大Step数
    NSInteger yStepCount = (self.y1Array.count > self.y2Array.count ? self.y1Array.count : self.y2Array.count);
    self.maxHeight = (yStepCount - 1) * self.yPerStepHeight;
    
    //重绘
    [self setNeedsDisplay];
}
//x-axis is moved to an enlarged scale the final
- (void)zoomLastX
{
    //increase the total number of the x-axis scale
    self.currXStepCount = self.dataSource.count;
    
    //Generating x-axis, y-axis left and right y-axis scale values
    [self buildXSetpArray:self.currXStepCount];
    
    //
    self.maxWidth = (self.xArray.count -1 ) * self.xPerStepWidth;
    //
    _contentScroll.x=-self.maxWidth + (self.xPerStepWidth * 3);
    
    
    //重绘
    [self setNeedsDisplay];

}

//x轴放大一个刻度
- (void)zoomHorizontalUp
{
    //x轴刻度总数量增加
    self.currXStepCount++;
    
    //生成x轴、左y轴、右y轴刻度值
    [self buildXYSetpArray:self.currXStepCount yStepCount:self.currYStepCount];
    
    //    //x轴上每一个Step的距离
    //    self.xPerStepWidth = (self.rightBottomPoint.x - self.originPoint.x) / (self.currXStepCount) - 0.1;
    self.maxWidth = (self.xArray.count - 1) * self.xPerStepWidth;
    
    //重绘
    [self setNeedsDisplay];
    
}
//x轴减小一个刻度
- (void)zoomHorizontalDown
{
    //x轴刻度总数量减少
    self.currXStepCount--;
    if (self.currXStepCount < DEFAULT_X_COUNT) self.currXStepCount = DEFAULT_X_COUNT;
    
    //生成x轴、左y轴、右y轴刻度值
    [self buildXYSetpArray:self.currXStepCount yStepCount:self.currYStepCount];
    
    //    //x轴上每一个Step的距离
    //    self.xPerStepWidth = (self.rightBottomPoint.x - self.originPoint.x) / (self.currXStepCount) - 0.1;
    self.maxWidth = (self.xArray.count - 1) * self.xPerStepWidth;
    //
//    _contentScroll.x=-self.maxWidth + (self.xPerStepWidth * 3);
    
    //重绘
    [self setNeedsDisplay];
}

//y轴放大一个刻度
- (void)zoomVerticalUp
{
    //Y轴刻度总数量增加
    self.currYStepCount++;
    
    //生成x轴、左y轴、右y轴刻度值
    [self buildXYSetpArray:self.currXStepCount yStepCount:self.currYStepCount];
    
    //    //y轴上每一个Step的距离
    //    self.yPerStepHeight = (self.originPoint.y - self.leftTopPoint.y) / (self.currYStepCount) - 0.1;
    //y轴上最大Step数
    NSInteger yStepCount = (self.y1Array.count > self.y2Array.count ? self.y1Array.count : self.y2Array.count);
    self.maxHeight = (yStepCount - 1) * self.yPerStepHeight;
    
    //重绘
    [self setNeedsDisplay];
}
//y轴减小一个刻度
- (void)zoomVerticalDown
{
    //Y轴刻度总数量减少
    self.currYStepCount--;
    if (self.currYStepCount < DEFAULT_Y_COUNT) self.currYStepCount = DEFAULT_Y_COUNT;
    
    //生成x轴、左y轴、右y轴刻度值
    [self buildXYSetpArray:self.currXStepCount yStepCount:self.currYStepCount];
    
    //    //y轴上每一个Step的距离
    //    self.yPerStepHeight = (self.originPoint.y - self.leftTopPoint.y) / (self.currYStepCount) - 0.1;
    //y轴上最大Step数
    NSInteger yStepCount = (self.y1Array.count > self.y2Array.count ? self.y1Array.count : self.y2Array.count);
    self.maxHeight = (yStepCount - 1) * self.yPerStepHeight;
    //
//    _contentScroll.y = self.maxHeight + (self.yPerStepHeight * 3);
    
    //重绘
    [self setNeedsDisplay];
}

//刷新图表
- (void)refreshData:(NSArray*)dataSource
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //////////////////// Data source sorting (bubble sort, data x-axis (distance) from small to large order) /////////////////
        //根据 RLLineChartItem.xValue属性进行排序
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"_xValue" ascending:YES];
        self.dataSource = [dataSource sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.xview == XViewLast) {
                [self zoomLastX];
            }
            else {
                [self zoomOriginal];
            }
        });
     });
}

@end

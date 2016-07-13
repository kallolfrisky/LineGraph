//
//  SportLineChartUtilty.h
//  testLineChart
//
//  Created by LongJun on 13-12-21.
//  Copyright (c) 2013年 LongJun. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define line1Color  [UIColor colorWithRed:(float)249/255 green:(float)176/255 blue:(float)47/255 alpha:1.0]//棕黄色
//#define line2Color  [UIColor colorWithRed:(float)73/255 green:(float)146/255 blue:(float)187/255 alpha:1.0]//青蓝色

#define line1Color      [UIColor colorWithRed:80.0/255 green:187.0/255 blue:1.0 alpha:1.0]//棕黄色
#define line2Color      [UIColor colorWithRed:180.0/255 green:40.0/255 blue:20.0/255 alpha:1.0]//青蓝色
#define xylineColor     [UIColor colorWithRed:80.0/255 green:187.0/255 blue:1.0 alpha:0.3]


@interface ARLineChartCommon : NSObject

+ (void)drawPoint:(CGContextRef)context point:(CGPoint)point withRadius:(CGFloat)radius color:(UIColor *)color;
+ (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor;
+ (void)drawGraphLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor;
+ (void)drawRectangle:(CGContextRef)context withRect:(CGRect)rect withColor:(UIColor *)fillColor;

+ (void)drawTriangle:(CGContextRef)context withRect:(CGRect)rect withColor:(UIColor *)fillColor;

+ (void)drawText:(CGContextRef)context text:(NSString*)text point:(CGPoint)point color:(UIColor *)color font:(UIFont*)font textAlignment:(NSTextAlignment)textAlignment;
+ (void)drawText2:(CGContextRef)context text:(NSString*)text color:(UIColor *)color fontSize:(CGFloat)fontSize;


@end


@interface RLLineChartItem : NSObject

@property double xValue; //水平x轴的值
@property double y1Value; //第一根垂直的y轴的值
@property double y2Value; //第二根垂直的y轴的值

@end
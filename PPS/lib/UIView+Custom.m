//  UIButton+Custom.h
//
//  Created by Najmul Hasan
//  Copyright 2013 Kryko  Soft. All rights reserved.

#import "UIView+Custom.h"

@implementation UIView (Custom)

- (void)makeDropShadow{

    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(5, 5);
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self.layer setShadowPath: [[UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:5.0] CGPath]];
    self.layer.borderColor=[[UIColor lightGrayColor] colorWithAlphaComponent:.5].CGColor;
    self.layer.borderWidth=1;
}

- (void)makeBorderCornerRadius:(float)cornerRadius{
    
    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.layer setBorderWidth:1.0];
    [self.layer setCornerRadius:cornerRadius];
    [self.layer setMasksToBounds:YES];
}

- (void)makeBorderCornerRadius:(float)cornerRadius withColor:(UIColor*)color{
    
    [self.layer setBorderColor:color.CGColor];
    [self.layer setBorderWidth:1.0];
    [self.layer setCornerRadius:cornerRadius];
    [self.layer setMasksToBounds:YES];
}

@end

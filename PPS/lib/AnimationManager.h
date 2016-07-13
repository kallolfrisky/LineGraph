//
//  AnimationManager.h
//  PhotoBullet
//
//  Created by Huq Majharul on 12/2/11.
//  Copyright 2011 __SmartMux__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface AnimationManager : NSObject

+ (AnimationManager*)sharedInstance;

-(void)doBottomViewAnimation:(UIView*)incomingView show:(BOOL)hide;
-(void)doTopViewAnimation:(UIView*)incomingView show:(BOOL)hide;

@end

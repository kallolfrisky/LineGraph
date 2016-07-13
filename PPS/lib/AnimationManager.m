//
//  AnimationManager.m
//  PhotoBullet
//
//  Created by Huq Majharul on 12/2/11.
//  Copyright 2011 __SmartMux__. All rights reserved.
//

#import "AnimationManager.h"

@implementation AnimationManager

+ (AnimationManager*)sharedInstance {
    static dispatch_once_t once;
    static AnimationManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[AnimationManager alloc] init]; });
    return sharedInstance;
}

-(void)doBottomViewAnimation:(UIView*)incomingView show:(BOOL)hide
{	
	// Set up the animation
    CATransition *animation1 = [CATransition animation];
	
    [animation1 setType:kCATransitionPush];
    [animation1 setSubtype:kCATransitionFromTop];
	
    [animation1 setDuration:0.5];
    [animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
    [[incomingView layer] addAnimation:animation1 forKey:kCATransition];
	incomingView.hidden = hide;
}

-(void)doTopViewAnimation:(UIView*)incomingView show:(BOOL)hide
{	
	// Set up the animation
    CATransition *animation1 = [CATransition animation];
	
    [animation1 setType:kCATransitionPush];
    [animation1 setSubtype:kCATransitionFromBottom];
	
    [animation1 setDuration:0.5];
    [animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
    [[incomingView layer] addAnimation:animation1 forKey:kCATransition];
	incomingView.hidden = hide;
}

@end

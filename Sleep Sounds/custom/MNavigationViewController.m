//
//  MNavigationViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 26/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "MNavigationViewController.h"

@interface MNavigationViewController ()

@end

@implementation MNavigationViewController

- (BOOL)shouldAutorotate
{
    BOOL ret;
    
    if( [self.viewControllers count] > 0 )
    {
        UIViewController * c = [self.viewControllers lastObject];
        ret = [c shouldAutorotate];
    }
    else
        ret = [super shouldAutorotate];
    
    return ret;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIInterfaceOrientationMask ret;
    
    if( [self.viewControllers count] > 0 )
    {
        UIViewController * c = [self.viewControllers lastObject];
        ret = [c supportedInterfaceOrientations];
    }
    else
        ret = [super shouldAutorotate];
    
    return ret;
}

@end

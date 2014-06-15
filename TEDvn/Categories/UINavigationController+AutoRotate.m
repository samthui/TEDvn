//
//  UINavigationController+AutoRotate.m
//  TEDvn
//
//  Created by samthui7 on 5/11/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import "UINavigationController+AutoRotate.h"

@implementation UINavigationController (AutoRotate)

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return [self.visibleViewController shouldAutorotate];
}


- (NSUInteger)supportedInterfaceOrientations
{
    if (![[self.viewControllers lastObject] isKindOfClass:NSClassFromString(@"ViewController")])
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
    {
        return [self.topViewController supportedInterfaceOrientations];
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end

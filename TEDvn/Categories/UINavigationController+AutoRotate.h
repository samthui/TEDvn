//
//  UINavigationController+AutoRotate.h
//  TEDvn
//
//  Created by samthui7 on 5/11/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (AutoRotate)

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
-(BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end

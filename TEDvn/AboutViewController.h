//
//  AboutViewController.h
//  TEDvn
//
//  Created by samthui7 on 5/10/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController

@property(nonatomic, retain)IBOutlet UITextView* aboutTextView;
@property(nonatomic, retain)IBOutlet UISegmentedControl* languageSegment;

-(IBAction)languageDidChange:(id)sender;

@end

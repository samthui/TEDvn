//
//  VideoDetailViewController.h
//  TEDvn
//
//  Created by samthui7 on 4/6/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoDetailViewController : UIViewController

@property (nonatomic, retain)NSDictionary* informations;
@property (nonatomic, retain)UIImage*   placeholderImg;
@property (nonatomic, retain)IBOutlet UIWebView* videoView;
@property (nonatomic, retain)IBOutlet UILabel* titleLbl;
@property (nonatomic, retain)IBOutlet UILabel* favoriteLbl;
@property (nonatomic, retain)IBOutlet UILabel* numbViewsLbl;
@property (nonatomic, retain)IBOutlet UILabel* likeLbl;
@property (nonatomic, retain)IBOutlet UILabel* dislikeLbl;
@property (nonatomic, retain)IBOutlet UITextView* description;

@end

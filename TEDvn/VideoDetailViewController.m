//
//  VideoDetailViewController.m
//  TEDvn
//
//  Created by samthui7 on 4/6/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "TempViewController.h"

@interface VideoDetailViewController ()<UIWebViewDelegate>

@end

@implementation VideoDetailViewController

@synthesize informations = _informations;
@synthesize placeholderImg = _placeholderImg;
@synthesize videoView = _videoView;
@synthesize favoriteLbl, numbViewsLbl, likeLbl, dislikeLbl, description;

-(void)dealloc
{
    self.informations = nil;
    self.placeholderImg = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.videoView.allowsInlineMediaPlayback = YES;
    //Player
    //place holder
    UIImageView* imgView = [[UIImageView alloc] initWithImage:self.placeholderImg];
    [imgView setTag:1];
    [imgView setFrame:CGRectMake(0, 0, 320, 180)];
    [self.view addSubview:imgView];
    
    [self.videoView.scrollView setScrollEnabled:NO];
    NSString* videoId = [self.informations objectForKey:@"video_id"];
    NSString* htmlCode = [NSString stringWithFormat:@"<iframe width=\"320\" height=\"180\" src=\"https://www.youtube.com/embed/%@\" frameborder=\"0\" allowfullscreen>", videoId];
    [self.videoView loadHTMLString:htmlCode baseURL:nil];
    
    [self.titleLbl setText:[self.informations objectForKey:@"video_title"]];
    [self.favoriteLbl setText:[NSString stringWithFormat:@"Favorites: %@", [self.informations objectForKey:@"numb_favorites"]]];
    [self.numbViewsLbl setText:[NSString stringWithFormat:@" %@ views", [self.informations objectForKey:@"numb_views"]]];
    [self.likeLbl setText:[NSString stringWithFormat:@" %@", [self.informations objectForKey:@"numb_likes"]]];
    [self.dislikeLbl setText:[NSString stringWithFormat:@" %@", [self.informations objectForKey:@"numb_dislikes"]]];
    [self.description setText:[self.informations objectForKey:@"description"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    UIApplication *app = [UIApplication sharedApplication];
//    UIWindow *window = [[app windows] objectAtIndex:0];
//    UIViewController *root = window.rootViewController;
//    window.rootViewController = nil;
//    window.rootViewController = root;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
//        
//        TempViewController *temp = [[TempViewController alloc] init];
//        [self.navigationController pushViewController:temp animated:YES];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    UIView* placeholderView = [self.view viewWithTag:1];
    if (placeholderView) {
        [placeholderView removeFromSuperview];
    }
}

@end

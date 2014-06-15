//
//  ViewController.m
//  TEDvn
//
//  Created by samthui7 on 4/3/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import "ViewController.h"
#import "RequestCategoryList.h"
#import "RequestPlaylistVideos.h"
#import "VideoDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AboutViewController.h"

#define CATEGORY_CELL_HEIGHT    90
#define CATEGORY_CELL_SIZE      CGSizeMake(180,90)
#define VIDEO_CELL_HEIGHT       180
#define VIDEO_CELL_SIZE         CGSizeMake(320,180)
#define REFRESH_SPINNER_WIDTH   320

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, WebServiceDelegate,UIGestureRecognizerDelegate>
{
    BOOL _showList;
    CGPoint _original;
    int _selectedCategory;
    int _totalVideosOfSelectedCategory;
}

@property (nonatomic, retain) NSArray* categoryArray;
@property (nonatomic, retain) NSMutableArray* videosArray;
@property (nonatomic, retain) UITableViewController *categoriesTableViewController;
@property (nonatomic, retain) UITableViewController *videosTableViewController;

@end

@implementation ViewController

@synthesize categoryArray = _categoryArray;
@synthesize videosArray = _videosArray;
@synthesize categoriesTable = _categoriesTable;
@synthesize videosTable = _videosTable;
@synthesize categoriesTableViewController = _categoriesTableViewController;
@synthesize videosTableViewController = _videosTableViewController;

-(void)dealloc
{
    self.categoryArray = nil;
    self.videosArray = nil;
    self.categoriesTableViewController = nil;
    self.categoriesTableViewController = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _showList = YES;
    _selectedCategory = 0;
    [RequestCategoryList requestCategoryList:self];
    
    // add a pan recognizer
    UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    //Navigation bar
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationController.navigationBar.barTintColor = [UIColor lightGrayColor];
    }else{
        [self.navigationController.navigationBar setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    //left btn
    [self.navigationItem setLeftBarButtonItem:nil];
    UIImage* image = [UIImage imageNamed:@"Icon_menu"];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(viewList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* viewListBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setLeftBarButtonItem:viewListBtn];
    [btn release];
    [viewListBtn release];
    
    //right btn
    UIButton* aboutBtn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, image.size.height)] autorelease];
    [aboutBtn addTarget:self action:@selector(showAbout) forControlEvents:UIControlEventTouchUpInside];
    [aboutBtn setBackgroundColor:[UIColor clearColor]];
    [aboutBtn setTitle:@"Giới thiệu" forState:UIControlStateNormal];
    UIBarButtonItem* aboutBarBtn = [[[UIBarButtonItem alloc] initWithCustomView:aboutBtn] autorelease];
    [self.navigationItem setRightBarButtonItem:aboutBarBtn];
    
    //TableViewControllers
    self.videosTableViewController = [[[UITableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    self.videosTableViewController.tableView = self.videosTable;
    //UIRefreshControl
    UIRefreshControl *refreshControl = [[[UIRefreshControl alloc] init] autorelease];
    refreshControl.center = CGPointMake(0.5, 0.5);
    CGRect refreshControlFrame = self.videosTableViewController.refreshControl.frame;
    refreshControlFrame = (CGRect){.origin = CGPointMake(70 - REFRESH_SPINNER_WIDTH/2, refreshControlFrame.origin.y), .size = refreshControlFrame.size};
    self.videosTableViewController.refreshControl.frame = refreshControlFrame;
    refreshControl.tintColor = [UIColor redColor];
//    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.videosTableViewController.refreshControl = refreshControl;
    
    //background color of tables
    UIView* bview1 = [[[UIView alloc] init] autorelease];
    bview1.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1];
    [self.videosTable setBackgroundView:bview1];
    self.videosTable.backgroundView.layer.zPosition -= 1;
    
    UIView* bview2 = [[[UIView alloc] init] autorelease];
    bview2.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1];
    [self.categoriesTable setBackgroundView:bview2];
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    CGRect originalFrame = CGRectZero;
//    CGRect refreshControlFrame = self.videosTableViewController.refreshControl.frame;
//    if (!_showList) {
//        //category menu is hiding
//        
//        originalFrame = (CGRect){.origin = CGPointMake(0-180, 0),.size = self.videosTable.frame.size};
//        refreshControlFrame = (CGRect){.origin = CGPointMake(160 - REFRESH_SPINNER_WIDTH/2, refreshControlFrame.origin.y), .size = refreshControlFrame.size};
//        
//    }else{
//        //category menu is showing
//        
//        originalFrame = (CGRect){.origin = CGPointMake(self.categoriesTable.frame.size.width-180, 0),.size = self.videosTable.frame.size};
//        refreshControlFrame = (CGRect){.origin = CGPointMake(70 - REFRESH_SPINNER_WIDTH/2, refreshControlFrame.origin.y), .size = refreshControlFrame.size};
//    }
//    self.videosTable.frame = originalFrame;
//    self.videosTableViewController.refreshControl.frame = refreshControlFrame;
//}

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

#pragma mark - Table
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (tableView.tag == 1) {//categories table
        height = CATEGORY_CELL_HEIGHT;
    }else if (tableView.tag == 2) {//videos table
        height = VIDEO_CELL_HEIGHT;
    }
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    
    if (tableView.tag == 1) {//categories table
        count = self.categoryArray.count;
    } else if (tableView.tag == 2){//videos table
        count = _totalVideosOfSelectedCategory;
    }
    
    return count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = @"categoryCellID";
    
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
//        [cell setBackgroundColor:[UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1]];
        CGRect thumbRect = CGRectZero;
        if (tableView.tag == 1) {//categories table
            thumbRect = (CGRect){.origin = CGPointMake(0, 0), .size = CATEGORY_CELL_SIZE};
            
            //thumbnail
            UIImageView* thumbView= [[[UIImageView alloc] initWithFrame:thumbRect] autorelease];
            [thumbView setContentMode:UIViewContentModeScaleAspectFill];
            [cell setClipsToBounds:YES];
            [thumbView setTag:1];
            [cell addSubview:thumbView];
            
            //title
            float titleHeight = 40;
            UILabel* title = [[[UILabel alloc] initWithFrame:CGRectMake(0, CATEGORY_CELL_HEIGHT - titleHeight, cell.frame.size.width, titleHeight)] autorelease];
            title.tag = 2;
            title.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            [title setTextColor:[UIColor whiteColor]];
            [cell addSubview:title];
        } else if (tableView.tag == 2) {//videos table
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            thumbRect = (CGRect){.origin = CGPointMake(0, 0), .size = VIDEO_CELL_SIZE};
            
            //thumbnail
            UIImageView* thumbView= [[[UIImageView alloc] initWithFrame:thumbRect] autorelease];
            [thumbView setTag:1];
            [cell addSubview:thumbView];
            
            //title
            float titleHeight = 80;
            UILabel* title = [[[UILabel alloc] initWithFrame:CGRectMake(0, 180 - titleHeight, cell.frame.size.width, titleHeight)] autorelease];
            title.tag = 2;
            title.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            [title setTextColor:[UIColor whiteColor]];
            [cell addSubview:title];
        }
    }
    
    if (tableView.tag == 1) {//categories table
        UIImageView* thumbnailView = (UIImageView*)[cell viewWithTag:1];
        if (thumbnailView) {
            NSURL *url = [NSURL URLWithString:[(NSDictionary*)[self.categoryArray objectAtIndex:indexPath.row] objectForKey:@"thumbnail_url"]];
            [thumbnailView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder_s"]];
        }
        
        UILabel* titleLabel = (UILabel*)[cell viewWithTag:2];
        if (titleLabel) {
            [titleLabel setText:[(NSDictionary*)[self.categoryArray objectAtIndex:indexPath.row] objectForKey:@"category_name"]];
        }
    } else if (tableView.tag == 2) {//videos table
        if ([[self.videosArray objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
            UIImageView* thumbnailView = (UIImageView*)[cell viewWithTag:1];
            if (thumbnailView) {
                [thumbnailView setImage:[UIImage imageNamed:@"placeholder_l"]];
            }
            NSDictionary* selectedCategoryDict = (NSDictionary*)[self.categoryArray objectAtIndex:_selectedCategory];
            NSString* categoryID = [selectedCategoryDict objectForKey:@"category_ID"];
            [RequestPlaylistVideos requestVideoAtIndex:indexPath.row + 1 playlist:categoryID delegate:self];
        }else{
            UIImageView* thumbnailView = (UIImageView*)[cell viewWithTag:1];
            if (thumbnailView) {
                NSURL *url = [NSURL URLWithString:[(NSDictionary*)[self.videosArray objectAtIndex:indexPath.row] objectForKey:@"thumbnail_url"]];
                [thumbnailView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder_l"]];
            }
            
            UILabel* titleLabel = (UILabel*)[cell viewWithTag:2];
            if (titleLabel) {
                [titleLabel setText:[(NSDictionary*)[self.videosArray objectAtIndex:indexPath.row] objectForKey:@"video_title"]];
                
                //size of title Label
                titleLabel.numberOfLines = 0; //will wrap text in new line
                [titleLabel sizeToFit];
                CGRect frame = titleLabel.frame;
                frame = CGRectMake(0, VIDEO_CELL_HEIGHT - frame.size.height, VIDEO_CELL_SIZE.width, frame.size.height);
                [titleLabel setFrame:frame];
            }
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) {//categories table
        if (indexPath.row == _selectedCategory) {
            return;
        }
        
        //cancel previous requests
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestCategoryList:) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestVideoAtIndex:playlist:delegate:) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestVideosOfPlaylist:delegate:startIndex:) object:nil];
        
        _selectedCategory = indexPath.row;
        [self.videosTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        //set number videos of selected category
        _totalVideosOfSelectedCategory = [[[self.categoryArray objectAtIndex:_selectedCategory] objectForKey:@"numb_videos"] intValue];
        
        //init self.videosArray
        self.videosArray = [NSMutableArray arrayWithCapacity:_totalVideosOfSelectedCategory];
        for (int i = 0; i < _totalVideosOfSelectedCategory; i++) {
            [self.videosArray addObject:[NSNull null]];
        }
        
        //stop all update videosTable, to avoid CRASHES.
        [self.videosTable reloadData];
        
        //then request for category
        NSDictionary* selectedCategoryDict = (NSDictionary*)[self.categoryArray objectAtIndex:indexPath.row];
        NSString* categoryID = [selectedCategoryDict objectForKey:@"category_ID"];
//        DBLog(@"request: %@", categoryLink);
        [RequestPlaylistVideos requestVideosOfPlaylist:categoryID delegate:self startIndex:1];
    } else if (tableView.tag == 2){//videos table
        if ([[self.videosArray objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
            return;//avoid CRASH
        }
        
        //get placeholder image
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView* imgView = (UIImageView*)[cell viewWithTag:1];
        UIImage* image = imgView.image;
        
        VideoDetailViewController* videoView = [[VideoDetailViewController alloc] initWithNibName:@"VideoDetailViewController" bundle:nil];
        videoView.informations = (NSDictionary*)[self.videosArray objectAtIndex:indexPath.row];
        videoView.placeholderImg = image;
        [[self navigationController] pushViewController:videoView animated:YES];
    }
}

#pragma mark - Touch Events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    DBLog(@"Began");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray* touchesArray = [touches allObjects];
    UITouch* touch = (UITouch*) [touchesArray lastObject];
    
    CGPoint touchLocation = [touch locationInView:self.view];
    CGPoint prevTouchLoc = [touch previousLocationInView:self.view];
    
    UIView* videosTable = self.videosTable;
    float offsetX = touchLocation.x - prevTouchLoc.x;
    //        DBLog(@" ... Move ... %f ... %f", touch.timestamp, offsetX);
    //    DBLog(@"offset: %f", offsetX);
    CGRect frame = videosTable.frame;
    
    if (offsetX <= 0 && frame.origin.x <= -self.categoriesTable.frame.size.width + 10) {
        return;
    }
    if (offsetX >= 0 && frame.origin.x >= 0 - 10) {
        return;
    }
    
    [videosTable setFrame:CGRectMake(frame.origin.x + offsetX, frame.origin.y, frame.size.width, frame.size.height)];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    DBLog(@"Ended");
    
    NSArray* touchesArray = [touches allObjects];
    UITouch* touch = (UITouch*) [touchesArray lastObject];
    CGPoint endTouchLoc = [touch locationInView:self.view];
    CGPoint prevTouchLoc = [touch previousLocationInView:self.view];
    
    UIView* videosTable = self.videosTable;
    CGRect frame = videosTable.frame;
    
    if (endTouchLoc.x - prevTouchLoc.x < 0) {
        [UIView beginAnimations:@"hideList" context:nil];
        [videosTable setFrame:(CGRect){0, 0, frame.size}];
        
        _showList = NO;
    }
    else{
        [UIView beginAnimations:@"showList" context:nil];
        [videosTable setFrame:(CGRect){self.categoriesTable.frame.size.width, 0, frame.size}];
        
        _showList = YES;
    }
    
    [UIView commitAnimations];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    DBLog(@"CANCEL!!!");
    
    UIView* videosTable = self.videosTable;
    CGRect frame = videosTable.frame;
    
    if (frame.origin.x > -160) {
        [UIView beginAnimations:@"hideList" context:nil];
        [videosTable setFrame:(CGRect){0, 0, frame.size}];
        
        _showList = NO;
    }
    else
    {
        [UIView beginAnimations:@"showList" context:nil];
        [videosTable setFrame:(CGRect){-self.categoriesTable.frame.size.width, 0, frame.size}];
        
        _showList = YES;
    }
    [UIView commitAnimations];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event NS_AVAILABLE_IOS(3_0)
{
//    DBLog(@" ... motion Began ... ");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event NS_AVAILABLE_IOS(3_0)
{
//    DBLog(@"motionEnded");
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event NS_AVAILABLE_IOS(3_0)
{
//    DBLog(@"motionCANCEL!!!");
}

#pragma mark - horizontal pan gesture methods
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:[self view]];
    // Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y)) {
        return YES;
    }
    return NO;
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer {
    // 1
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // if the gesture has just started, record the current centre location
        _original = self.videosTable.frame.origin;
    }
    
    // 2
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        // translate the center
        CGPoint translation = [recognizer translationInView:self.view];
        self.videosTable.frame = (CGRect){.origin = CGPointMake(_original.x + translation.x, _original.y), .size = self.videosTable.frame.size};
        //refreshControl
        CGRect refreshControlFrame = self.videosTableViewController.refreshControl.frame;
        float x = (320 - _original.x)/2 - REFRESH_SPINNER_WIDTH/2;
        [self.videosTableViewController.refreshControl setFrame:(CGRect){.origin = CGPointMake(x, refreshControlFrame.origin.y), .size = refreshControlFrame.size}];
        if (self.videosTable.frame.origin.x < 0) {
            [self.videosTable setFrame:(CGRect){.origin = CGPointMake(0, 0),.size = self.videosTable.frame.size}];
            [self.videosTableViewController.refreshControl setFrame:(CGRect){.origin = CGPointMake(160 - REFRESH_SPINNER_WIDTH/2, refreshControlFrame.origin.y), .size = refreshControlFrame.size}];
        }else if (self.videosTable.frame.origin.x >= self.categoriesTable.frame.size.width){
            [self.videosTable setFrame:(CGRect){.origin = CGPointMake(self.categoriesTable.frame.size.width, 0),.size = self.videosTable.frame.size}];
            [self.videosTableViewController.refreshControl setFrame:(CGRect){.origin = CGPointMake(70 - REFRESH_SPINNER_WIDTH/2, refreshControlFrame.origin.y), .size = refreshControlFrame.size}];
        }
    }
    
    // 3
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // the frame this cell would have had before being dragged
        CGRect originalFrame = CGRectZero;
        CGRect refreshControlFrame = self.videosTableViewController.refreshControl.frame;
        if (self.videosTable.frame.origin.x > _original.x) {
            //show category menu
            _showList = YES;
            
            originalFrame = (CGRect){.origin = CGPointMake(self.categoriesTable.frame.size.width, 0),.size = self.videosTable.frame.size};
            refreshControlFrame = (CGRect){.origin = CGPointMake(70 - REFRESH_SPINNER_WIDTH/2, refreshControlFrame.origin.y), .size = refreshControlFrame.size};
        }else{
            //hide category menu
            _showList = NO;
            
            originalFrame = (CGRect){.origin = CGPointMake(0, 0),.size = self.videosTable.frame.size};
            refreshControlFrame = (CGRect){.origin = CGPointMake(160 - REFRESH_SPINNER_WIDTH/2, refreshControlFrame.origin.y), .size = refreshControlFrame.size};
        }
        
        // if the item is not being deleted, snap back to the original location
        [UIView beginAnimations:@"" context:nil];
        self.videosTable.frame = originalFrame;
        self.videosTableViewController.refreshControl.frame = refreshControlFrame;
        [UIView commitAnimations];
//        [UIView animateWithDuration:0.2
//                         animations:^{
//                         }
//         ];
    }
}

#pragma mark - WebServiceDelegate
-(void)webServiceDidFinishDownloadData:(WebServiceHelper *)helper error:(NSError *)error
{
    if (error) {
        DBLog(@"%@", error.description);
    }
    
    if ([helper isKindOfClass:[RequestCategoryList class]]) {
        RequestCategoryList* returnedRequest = (RequestCategoryList*)helper;
        self.categoryArray = [NSArray arrayWithArray:returnedRequest.resultArray];
        
        [self.categoriesTable reloadData];
        
        //then request for 1' category as default
        NSDictionary* firstCategoryDict = (NSDictionary*)[self.categoryArray objectAtIndex:0];
        NSString* categoryID = [firstCategoryDict objectForKey:@"category_ID"];
        [RequestPlaylistVideos requestVideosOfPlaylist:categoryID delegate:self startIndex:1];
        
        //set number videos of selected category
        _totalVideosOfSelectedCategory = [[firstCategoryDict objectForKey:@"numb_videos"] intValue];
        
        //init self.videosArray
        self.videosArray = [NSMutableArray arrayWithCapacity:_totalVideosOfSelectedCategory];
        for (int i = 0; i < _totalVideosOfSelectedCategory; i++) {
            [self.videosArray addObject:[NSNull null]];
        }
    }else if ([helper isKindOfClass:[RequestPlaylistVideos class]]){
        RequestPlaylistVideos* returnedRequest = (RequestPlaylistVideos*)helper;
//        self.videosArray = [NSArray arrayWithArray:returnedRequest.resultArray];
        if (returnedRequest.requestedIndex < 0) {
            //if request for a list of >1 video
            [self.videosArray replaceObjectsInRange:NSMakeRange(returnedRequest.startIndex - 1, MAX_RESULTS) withObjectsFromArray:returnedRequest.resultArray];
            
            [self.videosTable reloadData];
        }else{
            //request for only 1 video
            [self.videosArray replaceObjectAtIndex:returnedRequest.requestedIndex - 1 withObject:[returnedRequest.resultArray objectAtIndex:0]];
            
            [self.videosTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:returnedRequest.requestedIndex - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [self.videosTableViewController.refreshControl endRefreshing];
    }
}

#pragma mark - private methods
-(void)viewList
{
    CGRect originalFrame = CGRectZero;
    CGRect refreshControlFrame = self.videosTableViewController.refreshControl.frame;
    if (_showList) {
        //hide category menu
        _showList = NO;
        
        originalFrame = (CGRect){.origin = CGPointMake(0, 0),.size = self.videosTable.frame.size};
        refreshControlFrame = (CGRect){.origin = CGPointMake(160 - REFRESH_SPINNER_WIDTH/2, refreshControlFrame.origin.y), .size = refreshControlFrame.size};
        
    }else{
        //show category menu
        _showList = YES;
        
        originalFrame = (CGRect){.origin = CGPointMake(self.categoriesTable.frame.size.width, 0),.size = self.videosTable.frame.size};
        refreshControlFrame = (CGRect){.origin = CGPointMake(70 - REFRESH_SPINNER_WIDTH/2, refreshControlFrame.origin.y), .size = refreshControlFrame.size};
    }
    [UIView beginAnimations:@"" context:nil];
    self.videosTable.frame = originalFrame;
    self.videosTableViewController.refreshControl.frame = refreshControlFrame;
    [UIView commitAnimations];
}

-(void)showAbout
{
    AboutViewController* aboutVC = [[[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil] autorelease];
    [[self navigationController] pushViewController:aboutVC animated:YES];
    
}

-(void)refreshData
{    
    //then request for category
    NSDictionary* firstCategoryDict = (NSDictionary*)[self.categoryArray objectAtIndex:_selectedCategory];
    NSString* categoryID = [firstCategoryDict objectForKey:@"category_ID"];
//    DBLog(@"request: %@", categoryLink);
    [RequestPlaylistVideos requestVideosOfPlaylist:categoryID delegate:self startIndex:1];
}
- (void)stopRefresh

{
    
    [self.videosTableViewController.refreshControl endRefreshing];
    
}


@end

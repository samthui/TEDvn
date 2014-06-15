//
//  RequestPlaylistVideos.m
//  TEDvn
//
//  Created by samthui7 on 4/6/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import "RequestPlaylistVideos.h"
#import "GDataXMLNode.h"

@interface RequestPlaylistVideos()

@property (nonatomic, retain) NSString* playlist;

@end

@implementation RequestPlaylistVideos

@synthesize playlist = _playlist;
@synthesize resultArray = _resultArray;
@synthesize startIndex = _startIndex;
@synthesize requestedIndex = _requestedIndex;

-(void)dealloc
{
    self.resultArray = nil;
    
    [super dealloc];
}

-(id)initRequestVideosOfPlaylist:(NSString*)playlist delegate:(id<WebServiceDelegate>)delegate startIndex:(int)startIndex
{
    if (self = [super init]) {
        self.playlist = playlist;
        self.delegate = delegate;
        self.startIndex = startIndex;
        self.requestedIndex = -1;
        [self request];
    }
    return self;
}

-(id)initRequestVideoAtIndex:(int)index playlist:(NSString *)playlist delegate:(id<WebServiceDelegate>)delegate
{
    if (self = [super init]) {
        self.playlist = playlist;
        self.delegate = delegate;
        self.startIndex = -1;
        self.requestedIndex = index;
        [self request];
    }
    return self;
}

+(id)requestVideosOfPlaylist:(NSString *)playlist delegate:(id<WebServiceDelegate>)delegate startIndex:(int)startIndex
{
    return [[[self alloc] initRequestVideosOfPlaylist:playlist delegate:delegate startIndex:startIndex] autorelease];
}

+(id)requestVideoAtIndex:(int)index playlist:(NSString *)playlist delegate:(id<WebServiceDelegate>)delegate
{
    return [[self alloc] initRequestVideoAtIndex:index playlist:playlist delegate:delegate];
}

#pragma mark - override methods
-(NSString*)URL
{
    NSString* theURL = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/playlists/%@?start-index=%i&max-results=%i&v=2", self.playlist, self.startIndex, MAX_RESULTS];//self.playlist;//
    if (self.requestedIndex >=0) {
        theURL = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/playlists/%@?start-index=%i&max-results=1&v=2", self.playlist, self.requestedIndex];
    }
    return theURL;
}

- (BOOL)parse:(NSError **)error
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:_receivedData
                                                           options:0 error:error];
    if (doc == nil) { return NO; }
    
//    DBLog(@"%@", doc.rootElement);
    
    self.resultArray = [NSMutableArray array];
    
    //TODO: parse to Model
    NSArray *entryElements = [doc.rootElement elementsForName:@"entry"];
    for (GDataXMLElement *entry in entryElements) {
        
        NSString* videoTitle = ((GDataXMLElement*)[[entry elementsForName:@"title"] objectAtIndex:0]).stringValue;
        NSArray* subStrings = [videoTitle componentsSeparatedByString:@"] "];
        if (subStrings.count > 1) {
            videoTitle = [subStrings objectAtIndex:1];
        }
//        DBLog(@"videoTitle: %@", videoTitle);
        
        NSString* videoLink = ([(GDataXMLElement*)[[entry elementsForName:@"content"] objectAtIndex:0] attributeForName:@"src"]).stringValue;
//        DBLog(@"videoLink: %@", videoLink);
        
        GDataXMLElement* mediaElement = (GDataXMLElement* )[[entry elementsForName:@"media:group"] objectAtIndex:0];
        NSString* description = ((GDataXMLElement*)[[mediaElement elementsForName:@"media:description"] objectAtIndex:0]).stringValue;
//        DBLog(@"description: %@", description);
        
        NSString* mediumThumbnailURL = [((GDataXMLElement*)[[mediaElement elementsForName:@"media:thumbnail"] objectAtIndex:1]) attributeForName:@"url"].stringValue;
//        DBLog(@"thumb: %@", mediumThumbnailURL);
        
        NSString* videoID = ((GDataXMLElement*)[[mediaElement elementsForName:@"yt:videoid"] objectAtIndex:0]).stringValue;
//        DBLog(@"videoID: %@", videoID);
        
        GDataXMLElement* statistic = (GDataXMLElement*)[[entry elementsForName:@"yt:statistics"] objectAtIndex:0];
        NSString* favorites = [statistic attributeForName:@"favoriteCount"].stringValue;
        NSString* views = [statistic attributeForName:@"viewCount"].stringValue;
    //        DBLog(@"statistic: %@", statistic);
        
        GDataXMLElement* rating = (GDataXMLElement*)[[entry elementsForName:@"yt:rating"] objectAtIndex:0];
        NSString* dislikes = [rating attributeForName:@"numDislikes"].stringValue;
        NSString* likes = [rating attributeForName:@"numLikes"].stringValue;
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:videoTitle, @"video_title",videoLink, @"video_link", mediumThumbnailURL, @"thumbnail_url", videoID, @"video_id", description, @"description", favorites, @"numb_favorites", views, @"numb_views", dislikes, @"numb_dislikes", likes, @"numb_likes", nil];
        [self.resultArray addObject:dict];
        
    }
//    DBLog(@"%i", self.resultArray.count);
    [doc release];
    
    return YES;
}


@end

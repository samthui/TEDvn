//
//  RequestCategoryList.m
//  TEDvn
//
//  Created by samthui7 on 4/5/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import "RequestCategoryList.h"
#import "GDataXMLNode.h"

@interface RequestCategoryList()

-(id)initRequest:(id<WebServiceDelegate>)delegate;

@end

@implementation RequestCategoryList

@synthesize resultArray = _resultArray;

-(void)dealloc
{
    self.resultArray = nil;
    
    [super dealloc];
}

-(id)initRequest:(id<WebServiceDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        [self request];
    }
    return self;
}

+(id)requestCategoryList:(id<WebServiceDelegate>)delegate
{
    return [[[self alloc] initRequest:delegate] autorelease];
}

#pragma mark - override methods
-(NSString*)URL
{
    return @"https://gdata.youtube.com/feeds/api/users/sXEbchdfiRpF9uq5dxgf1A/playlists?v=2";
}

- (BOOL)parse:(NSError **)error
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:_receivedData
                                                           options:0 error:error];
    if (doc == nil) { return NO; }
    
//    DBLog(@"%@", doc.rootElement);
    
    self.resultArray = [NSMutableArray array];
    
    //TODO: parse to Model
    NSArray *categoryElements = [doc.rootElement elementsForName:@"entry"];
    for (GDataXMLElement *categoryEntry in categoryElements) {
        NSString* categoryName = ((GDataXMLElement*)[[categoryEntry elementsForName:@"title"] objectAtIndex:0]).stringValue;
//        DBLog(@"categoryName: %@", categoryName);
        
        NSString* categoryID = ((GDataXMLElement* )[[categoryEntry elementsForName:@"yt:playlistId"] objectAtIndex:0]).stringValue;
//        DBLog(@"categoryID: %@", categoryID);
        
        NSString* numberOfVideos = ((GDataXMLElement* )[[categoryEntry elementsForName:@"yt:countHint"] objectAtIndex:0]).stringValue;
//        DBLog(@"numberOfVideos: %@", numberOfVideos);
        
        NSString* playlistLink = ([(GDataXMLElement*)[[categoryEntry elementsForName:@"content"] objectAtIndex:0] attributeForName:@"src"]).stringValue;
//        DBLog(@"playlistLink: %@", playlistLink);
        
        GDataXMLElement* mediaElement = (GDataXMLElement* )[[categoryEntry elementsForName:@"media:group"] objectAtIndex:0];
        NSString* smallThumbnailURL = [((GDataXMLElement*)[[mediaElement elementsForName:@"media:thumbnail"] objectAtIndex:0]) attributeForName:@"url"].stringValue;
//        DBLog(@"thumb: %@", smallThumbnailURL);
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:categoryName, @"category_name", categoryID, @"category_ID", numberOfVideos, @"numb_videos",playlistLink, @"playlist_link", smallThumbnailURL, @"thumbnail_url", nil];
        [self.resultArray addObject:dict];
        
    }
    
    [doc release];
    
    return YES;
}

@end

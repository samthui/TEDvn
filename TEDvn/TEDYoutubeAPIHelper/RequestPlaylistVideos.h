//
//  RequestPlaylistVideos.h
//  TEDvn
//
//  Created by samthui7 on 4/6/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import "WebServiceHelper.h"

#define MAX_RESULTS 3

@interface RequestPlaylistVideos : WebServiceHelper

@property (nonatomic, retain) NSMutableArray* resultArray;
@property (nonatomic, assign) int startIndex;//request for MAX_RESULTS videos start from this index
@property (nonatomic, assign) int requestedIndex;//request for only 1 video

+(id)requestVideosOfPlaylist:(NSString*)playlist delegate:(id<WebServiceDelegate>)delegate startIndex:(int)startIndex;
+(id)requestVideoAtIndex:(int)index playlist:(NSString *)playlist delegate:(id<WebServiceDelegate>)delegate;

@end

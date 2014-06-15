//
//  RequestCategoryList.h
//  TEDvn
//
//  Created by samthui7 on 4/5/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import "WebServiceHelper.h"

@interface RequestCategoryList : WebServiceHelper

@property (nonatomic, retain) NSMutableArray* resultArray;

+(id) requestCategoryList:(id<WebServiceDelegate>)delegate;

@end

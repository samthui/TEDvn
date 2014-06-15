//
//  WebServiceHelper.m
//  VoiceUtility
//
//  Created by Phien Tram on 10/11/12.
//
//

#import "WebServiceHelper.h"

@interface WebServiceHelper ()

@property (nonatomic, assign) BOOL loadingData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;

@end

@implementation WebServiceHelper

@synthesize serviceName = _serviceName;
@synthesize delegate = _delegate;
@synthesize result = _result;
@synthesize flag = _flag;
@synthesize loadingData = _loadingData;
@synthesize connection = _connection;
@synthesize receivedData = _receivedData;

- (void)dealloc
{
    [_serviceName release];
    [_result release];
    [_flag release];
    
    [_connection release];
    [_receivedData release];
    
    [super dealloc];
}

- (void)request
{
    NSString * urlString = [self URL];
    
    DBLog(@"url:%@", urlString);
    if ([urlString length] > 0) {
        self.loadingData = YES;
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        self.connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
        if (self.connection) {
            self.receivedData = [NSMutableData data];
        } else {
            self.loadingData = NO;
        }
    }
}

- (void)cancel
{
    if (self.loadingData) {
		[self.connection cancel];
		self.loadingData = NO;
		
		self.receivedData = nil;
		self.connection = nil;
	}
}

#pragma mark - Sub-class implementations

- (NSString *)URL
{
    return @"";
}

- (BOOL)parse:(NSError **)error
{
    return YES;
}

#pragma mark - URLConnection delegate

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.receivedData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self.receivedData setLength:0];
    if ([response respondsToSelector:@selector(statusCode)]) {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode >= 400) {
            [connection cancel];  // stop connecting; no more delegate messages
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat: NSLocalizedString(@"Server returned status code %d",@""), statusCode]
                                                                  forKey:NSLocalizedDescriptionKey];
            NSError *statusError = [NSError errorWithDomain:NSUnderlyingErrorKey code:statusCode userInfo:errorInfo];
            [self connection:connection didFailWithError:statusError];
        }
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.loadingData = NO;
	self.receivedData = nil;
	self.connection = nil;
    self.result = nil;
    if ([_delegate respondsToSelector:@selector(webServiceDidFinishDownloadData:error:)]) {
        [_delegate webServiceDidFinishDownloadData:self error:error];
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.loadingData = NO;
	self.connection = nil;
    NSError *error = nil;
    
    //process _receivedData depending on each sub-class situation.
    //result will be assigned after parsing
    if ([self parse:&error]) {
        if ([_delegate respondsToSelector:@selector(webServiceDidFinishDownloadData:error:)]) {
            [_delegate webServiceDidFinishDownloadData:self error:error];
        }
   	}
    //in other case (parse return NO): it means waiting an asynchronous method
    //after that, it will callback automatically
    
    self.receivedData = nil;
}

@end

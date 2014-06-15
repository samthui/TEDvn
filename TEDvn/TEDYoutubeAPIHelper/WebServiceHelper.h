//
//  WebServiceHelper.h
//  VoiceUtility
//
//  Created by Phien Tram on 10/11/12.
//
//

#import <Foundation/Foundation.h>

@protocol WebServiceDelegate;

@interface WebServiceHelper : NSObject 
{
    NSMutableData *_receivedData;
}

@property (nonatomic, retain) NSString *serviceName;
@property (nonatomic, assign) id<WebServiceDelegate> delegate;
@property (nonatomic, retain) id result;
@property (nonatomic, retain) NSString *flag;

- (void)request;
- (void)cancel;

//methods that sub-class must implement
- (NSString *)URL;
- (BOOL)parse:(NSError **)error;

@end

@protocol WebServiceDelegate <NSObject>

@optional
- (void)webServiceDidFinishDownloadData:(WebServiceHelper *)helper error:(NSError *)error;

@end
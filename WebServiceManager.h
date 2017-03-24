//
//  WebServiceManager.h
//
//

#import <Foundation/Foundation.h>

@interface WebServiceManager : NSObject
{

}

+ (NSMutableURLRequest*) requestWithUrlString:(NSString*)urlString andAuthorization:(NSString*)auth;
+ (NSURLRequest*) authorizedRequestWithService:(NSString*)service andParameters:(NSString*)params;


+ (NSURLRequest*) postRequestForLoginWithService:(NSString*)service
                                      postString:(NSDictionary*)postDict;
+ (NSURLRequest*) authorizedPostRequestWithService:(NSString*)service andParameters:(NSDictionary*)params;

+ (NSMutableURLRequest*) authorizedPutRequestWithUrlString:(NSString*)service
									  postString:(NSDictionary*)postString;
+ (NSMutableURLRequest*) authorizedPutRequestWithFullUrl:(NSString*)Url
                                                postDict:(NSDictionary*)dict;

+ (NSURLRequest*) authorizedDeleteRequestWithService:(NSString*)service;
+ (NSMutableURLRequest*) deleteRequestWithUrlString:(NSString*)urlString;

+ (void) sendRequest:(NSURLRequest*)request
		  completion:(void (^)(NSData*, NSError*)) callback;

+ (BOOL) isConnectedToNetwork;


@end

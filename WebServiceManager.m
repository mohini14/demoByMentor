//
//  WebServiceManager.m
//
//

#import "WebServiceManager.h"
#include <sys/xattr.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>
#import "EmbedKit.h"
#import "CommonFunctions.h"
#import "MDLiveConstants.h"

#define DEBUG_MODE_LOG YES
#define kNetworkErrorMessage @"Connection Time Out. Please check your network connection."
#define kServiceError       @"Connection Time Out. Please check your network connection or try again later. If the problem persist, please call the MDLIVE Helpdesk at 1-888-995-2183."

@implementation WebServiceManager

#pragma mark - GET requests

+ (NSMutableURLRequest*) requestWithUrlString:(NSString*)urlString andAuthorization:(NSString*)auth
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    [request setValue:[EmbedKit sharedInstance].uniqueID forHTTPHeaderField:@"RemoteUserId"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"iOS-MDL-EK" forHTTPHeaderField:@"Device-OS"];

    if ([EmbedKit sharedInstance].dependentID)
    {
        [request setValue:[EmbedKit sharedInstance].dependentID forHTTPHeaderField:@"DependantId"];
    }
    
    [request setTimeoutInterval:45.0];
    
    return (NSMutableURLRequest*)request;
}

+ (NSURLRequest*) authorizedRequestWithService:(NSString*)service andParameters:(NSString*)params
{
    NSString* urlString = [[[EmbedKit sharedInstance].baseUrl stringByAppendingString:service] stringByAppendingString:params];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];

    
    [request setTimeoutInterval:45.0];
    
    return [WebServiceManager addCommonHeadersToRequest:request];
    
}


#pragma mark - POST requests

+ (NSURLRequest*) postRequestForLoginWithService:(NSString*)service
                              postString:(NSDictionary*)postDict
{
    NSString* urlString = [[EmbedKit sharedInstance].baseUrl stringByAppendingString:service];
    
    NSData* postData = [NSJSONSerialization dataWithJSONObject:postDict
                                                       options:NSJSONWritingPrettyPrinted error:nil];;
    
    NSString* postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"MobileUser" forHTTPHeaderField:@"RemoteUserId"];
    [request setValue:@"iOS-MDL-EK" forHTTPHeaderField:@"Device-OS"];

    NSString *authStr = [NSString stringWithFormat:@"%@:%@", [[EmbedKit sharedInstance] apiKey], [[EmbedKit sharedInstance] secretKey]];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];

    if ([EmbedKit sharedInstance].dependentID)
    {
        [request setValue:[EmbedKit sharedInstance].dependentID forHTTPHeaderField:@"DependantId"];
    }

    [request setTimeoutInterval:45.0];
    
    [request setHTTPBody:postData];
    
    return request;
}

+ (NSURLRequest*) authorizedPostRequestWithService:(NSString*)service andParameters:(NSDictionary*)params
{
    NSString* urlString = [[EmbedKit sharedInstance].baseUrl stringByAppendingString:service];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSData* postData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:nil];;
    [request setHTTPBody:postData];
    
    NSString* postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setTimeoutInterval:45.0];

    if ([service isEqualToString:URL_VISIT_CONFIRM_ONCALL_CONSULTATION] || [service isEqualToString:URL_VISIT_CONFIRM_APPOINTMENT])
        [request setTimeoutInterval:300];
    
    return [WebServiceManager addCommonHeadersToRequest:request];
}

+ (NSURLRequest*) postRequestWithService:(NSString*)service
                               postArray:(NSArray*)postString
{
    NSString* urlString = [[EmbedKit sharedInstance].baseUrl stringByAppendingString:service];
    NSData* postData = [NSJSONSerialization dataWithJSONObject:postString
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString* postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setTimeoutInterval:45.0];
    
    [request setHTTPBody:postData];
    
    return [WebServiceManager addCommonHeadersToRequest:request];
}

#pragma mark - PUT requests

+ (NSMutableURLRequest*) authorizedPutRequestWithUrlString:(NSString*)service
                                                postString:(NSDictionary*)postString
{
    NSString* urlString = [[EmbedKit sharedInstance].baseUrl stringByAppendingString:service];
    return [WebServiceManager authorizedPutRequestWithFullUrl:urlString postDict:postString];
}

+ (NSMutableURLRequest*) authorizedPutRequestWithFullUrl:(NSString*)Url
                                                postDict:(NSDictionary*)dict
{
    NSData* postData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString* postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:Url]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setTimeoutInterval:45.0];
    
    [request setHTTPBody:postData];
    
    return [WebServiceManager addCommonHeadersToRequest:request];

}
#pragma mark - DELETE requests

+ (NSURLRequest*) authorizedDeleteRequestWithService:(NSString*)service
{
    NSString* urlString = [[EmbedKit sharedInstance].baseUrl stringByAppendingString:service];
    
    return [WebServiceManager deleteRequestWithUrlString:urlString];
}

+ (NSMutableURLRequest*) deleteRequestWithUrlString:(NSString*)urlString
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"DELETE"];

    [request setTimeoutInterval:45.0];
    
    return [WebServiceManager addCommonHeadersToRequest:request];
;
}

+ (NSMutableURLRequest*) addCommonHeadersToRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"iOS-MDL-EK" forHTTPHeaderField:@"Device-OS"];
    [request setValue:[CommonFunctions authorizationHeader]  forHTTPHeaderField:@"Authorization"];
    [request setValue:[EmbedKit sharedInstance].uniqueID forHTTPHeaderField:@"RemoteUserId"];
    
    if ([EmbedKit sharedInstance].dependentID)
    {
        [request setValue:[EmbedKit sharedInstance].dependentID forHTTPHeaderField:@"DependantId"];
    }
    return request;
}

#pragma mark - Send Request

+ (void) sendRequest:(NSURLRequest*)request
          completion:(void (^)(NSData*, NSError*)) callback
{
    if ([WebServiceManager isConnectedToNetwork] == NO)
    {
        callback(nil, [NSError errorWithDomain:@"Network" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:kNetworkErrorMessage,NSLocalizedDescriptionKey, nil]]);
        return;
    }
    
    if (DEBUG_MODE_LOG)
    {
        NSLog(@"Request# \n URL : %@ \n Headers : %@ \n Request Method : %@ \n Post body : %@\n",request.URL.absoluteString, request.allHTTPHeaderFields.description,request.HTTPMethod,request.HTTPBody?[NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:NULL]:request.HTTPBody);
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
    completionHandler:^(NSData* responseData,NSURLResponse* response, NSError* error)
  {
      NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
      if (DEBUG_MODE_LOG) {
          NSLog(@"Response String # %@",responseString);
      }

      NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
      NSUInteger responseStatusCode = [httpResponse statusCode];
      if (responseStatusCode == 200 || responseStatusCode == 201 || responseStatusCode == 202)
      {
          dispatch_async(dispatch_get_main_queue(), ^
                         {
                             callback(responseData, error);
                         });
      }
      else
      {
          dispatch_async(dispatch_get_main_queue(), ^
                        {
                            NSDictionary* errorDict;
                            if (responseData)
                            {
                                errorDict = [NSJSONSerialization
                                             JSONObjectWithData:responseData options:kNilOptions error:nil];

                            }
                            
                             NSString* errorString;
                             if (errorDict)
                             {
                                 errorString = [errorDict stringForKey:@"error"];
                             }
                             else
                                 errorString = kServiceError;
                             
                            NSError* errorInfo = [NSError errorWithDomain:@"Server error" code:responseStatusCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString,NSLocalizedDescriptionKey, nil]];

                             callback(nil,errorInfo);
                         });
      }
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  }];
    
    [dataTask resume];
}

+ (BOOL) isConnectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    // synchronous model
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags\n");
        return 0;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    return (isReachable && !needsConnection);
}


@end

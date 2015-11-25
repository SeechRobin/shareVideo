//
//  TwitterAPIManager.m
//  MyColor
//
//  Created by Robin Mukanganise on 2015/11/24.
//  Copyright © 2015 Robin Mukanganise. All rights reserved.
//

#import "TwitterAPIManager.h"


@implementation TwitterAPIManager

+(BOOL)userHasAccessToFacebook
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
}

+(BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

-(void)uploadTwitterVideo:(NSData*)videoData account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    
    NSDictionary *postParams = @{@"command": @"INIT",
                                 @"total_bytes" : [NSNumber numberWithInteger: videoData.length].stringValue,
                                 @"media_type" : @"video/mp4"
                                 };
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    request.account = account;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"HTTP Response: %li, responseData: %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (error) {
            NSLog(@"There was an error:%@", [error localizedDescription]);
        } else {
            NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            
            NSString *mediaID = [NSString stringWithFormat:@"%@", [returnedData valueForKey:@"media_id_string"]];
            
            [TwitterAPIManager tweetVideoStage2:videoData mediaID:mediaID account:account withCompletion:completion];
            
            NSLog(@"stage one success, mediaID -> %@", mediaID);
        }
    }];
}

+(void)tweetVideoStage2:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    NSDictionary *postParams = @{@"command": @"APPEND",
                                 @"media_id" : mediaID,
                                 @"segment_index" : @"0",
                                 };
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    postRequest.account = account;
    
    [postRequest addMultipartData:videoData withName:@"media" type:@"video/mp4" filename:@"video"];
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Stage2 HTTP Response: %li, %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (!error) {
            [TwitterAPIManager tweetVideoStage3:videoData mediaID:mediaID account:account withCompletion:completion];
        }
        else {
            NSLog(@"Error stage 2 - %@", error);
        }
    }];
}

+(void)tweetVideoStage3:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    
    NSDictionary *postParams = @{@"command": @"FINALIZE",
                                 @"media_id" : mediaID };
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    
    // Set the account and begin the request.
    postRequest.account = account;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Stage3 HTTP Response: %li, %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (error) {
            NSLog(@"Error stage 3 - %@", error);
        } else {
            [TwitterAPIManager tweetVideoStage4:videoData mediaID:mediaID account:account withCompletion:completion];
        }
    }];
}

+(void)tweetVideoStage4:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSString *statusContent = [NSString stringWithFormat:@"#SocialVideoHelper# https://github.com/liu044100/SocialVideoHelper"];
    
    // Set the parameters for the third twitter video request.
    NSDictionary *postParams = @{@"status": statusContent,
                                 @"media_ids" : @[mediaID]};
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    postRequest.account = account;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Stage4 HTTP Response: %li, %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (error) {
            NSLog(@"Error stage 4 - %@", error);
        } else {
            if ([urlResponse statusCode] == 200){
                NSLog(@"upload success !");
                DispatchMainThread(^(){completion();});
            }
        }
    }];
    
}


//-(void) shareOnTwitterWithVideo:(NSDictionary*) params{
//    NSString *text = params[@"text"];
//    NSData* dataVideo = params[@"video"];
//    NSString *lengthVideo = [NSString stringWithFormat:@"%d", [params[@"length"] intValue]];
//    NSString* url = @"https://upload.twitter.com/1.1/media/upload.json";
//    
//    __block NSString *mediaID;
//    
//    if([[Twitter sharedInstance] session]){
//        
//        TWTRAPIClient *client = [[Twitter sharedInstance] APIClient];
//        NSError *error;
//        // First call with command INIT
//        NSDictionary *message =  @{ @"status":text,
//                                    @"command":@"INIT",
//                                    @"media_type":@"video/mp4",
//                                    @"total_bytes":lengthVideo};
//        NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
//        
//        [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
//            
//            if(!error){
//                NSError *jsonError;
//                NSDictionary *json = [NSJSONSerialization
//                                      JSONObjectWithData:responseData
//                                      options:0
//                                      error:&jsonError];
//                
//                mediaID = [json objectForKey:@"media_id_string"];
//                client = [[Twitter sharedInstance] APIClient];
//                NSError *error;
//                NSString *videoString = [dataVideo base64EncodedStringWithOptions:0];
//                // Second call with command APPEND
//                message = @{@"command" : @"APPEND",
//                            @"media_id" : mediaID,
//                            @"segment_index" : @"0",
//                            @"media" : videoString};
//                
//                NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
//                
//                [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
//                    
//                    if(!error){
//                        client = [[Twitter sharedInstance] APIClient];
//                        NSError *error;
//                        // Third call with command FINALIZE
//                        message = @{@"command" : @"FINALIZE",
//                                    @"media_id" : mediaID};
//                        
//                        NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
//                        
//                        [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
//                            
//                            if(!error){
//                                client = [[Twitter sharedInstance] APIClient];
//                                NSError *error;
//                                // publish video with status
//                                NSString *url = @"https://api.twitter.com/1.1/statuses/update.json";
//                                NSMutableDictionary *message = [[NSMutableDictionary alloc] initWithObjectsAndKeys:text,@"status",@"true",@"wrap_links",mediaID, @"media_ids", nil];
//                                NSURLRequest *preparedRequest = [client URLRequestWithMethod:@"POST" URL:url parameters:message error:&error];
//                                
//                                [client sendTwitterRequest:preparedRequest completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
//                                    if(!error){
//                                        NSError *jsonError;
//                                        NSDictionary *json = [NSJSONSerialization
//                                                              JSONObjectWithData:responseData
//                                                              options:0
//                                                              error:&jsonError];
//                                        NSLog(@"%@", json);
//                                    }else{
//                                        NSLog(@"Error: %@", error);
//                                    }
//                                }];
//                            }else{
//                                NSLog(@"Error command FINALIZE: %@", error);
//                            }
//                        }];
//                        
//                    }else{
//                        NSLog(@"Error command APPEND: %@", error);
//                    }
//                }];
//                
//            }else{
//                NSLog(@"Error command INIT: %@", error);
//            }
//            
//        }];
//    }
@end

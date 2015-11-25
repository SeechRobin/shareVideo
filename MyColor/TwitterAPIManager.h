//
//  TwitterAPIManager.h
//  MyColor
//
//  Created by Robin Mukanganise on 2015/11/24.
//  Copyright © 2015 Robin Mukanganise. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>


#define DispatchMainThread(block, ...) if(block) dispatch_async(dispatch_get_main_queue(), ^{ block(__VA_ARGS__); })

@interface TwitterAPIManager : ViewController

-(void)uploadTwitterVideo:(NSData*)videoData account:(ACAccount*)account withCompletion:(dispatch_block_t)completion;

//+(void)uploadFacebookVideo:(NSData*)videoData account:(ACAccount*)account withCompletion:(dispatch_block_t)completion;

-(BOOL)userHasAccessToFacebook;
-(BOOL)userHasAccessToTwitter;


@end

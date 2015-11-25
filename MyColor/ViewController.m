//
//  ViewController.m
//  MyColor
//
//  Created by Robin Mukanganise on 2015/11/23.
//  Copyright © 2015 Robin Mukanganise. All rights reserved.
//

#import "ViewController.h"
#import "TwitterAPIManager.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize view_color;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    view_color.backgroundColor = [UIColor blueColor];
    //self.view_color.backgroundColor = FlatOrangeDark;
    
  
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    __block ACAccount *_account = [[ACAccount alloc] init];
    [account requestAccessToAccountsWithType:twitterAccountType options:nil
                                  completion:^(BOOL granted, NSError *error){
    
                      
              NSArray *twitterAccounts = [account accountsWithAccountType:twitterAccountType];
              NSLog(@"TWitter Accounts %@", [twitterAccounts lastObject]);
              _account = [twitterAccounts lastObject];
                                      
    }];

 

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"mp4"];
    
    NSArray* myImages = [[NSBundle mainBundle] pathsForResourcesOfType:@"mp4"
                                              inDirectory:nil];
    
    NSLog(@"List of my mp4 %@", myImages);

    NSLog(@"What is my file path? %@", filePath);
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:&error];
    if(data){
        TwitterAPIManager *apiManager = [[TwitterAPIManager alloc] init];
        [apiManager uploadTwitterVideo:data account:_account withCompletion:nil];
    }
    else{
        NSLog(@"Error");
    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) pressedButton {
    NSLog(@"Pressed Button");
}

@end

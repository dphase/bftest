//
//  DPViewController.m
//  bftest
//
//  Created by Joshua Deere on 4/15/14.
//  Copyright (c) 2014 project93. All rights reserved.
//

#import "DPViewController.h"
#import "RNEncryptor.h"

@interface DPViewController ()

@end

@implementation DPViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSData    *passwd = [@"mypassword" dataUsingEncoding:NSUTF8StringEncoding];
  NSString  *key    = @"edcc7b24416ea259b229141785aca337";

  NSError   *err;

  NSData    *cipher = [RNEncryptor encryptData:passwd
                                  withSettings:kRNCryptorAES256Settings
                                      password:key
                                         error:&err];

  NSLog(@"\n\n✅ passwd          |  %@\n✅ cipher (base64) |  %@\n✅ cipher (raw)    | %@",
        [[NSString alloc] initWithData:passwd encoding:NSUTF8StringEncoding],
        [cipher base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed],
        cipher);
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

@end

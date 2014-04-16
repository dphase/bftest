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
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *keyText;
@property (weak, nonatomic) IBOutlet UILabel *cipherText;
@property (weak, nonatomic) IBOutlet UILabel *tokenText;
@property (weak, nonatomic) IBOutlet UILabel *error;

- (IBAction)loginAction:(id)sender;
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

- (IBAction)loginAction:(id)sender {
    [_username resignFirstResponder];
    [_password resignFirstResponder];
    
    NSString *username = _username.text;
    NSString *password = _password.text;
    NSString *key = @"";
    NSString *cipher = @"";
    NSString *token = @"";
    
    NSDictionary *keyDict = [self retrieveJSONFromURL:
                             [NSURL URLWithString:
                              [NSString stringWithFormat:@"https://secure.schoolstatus.com/api/v3/auth/token.json?username=%@", username]]];
    NSArray *keyParts = [(NSString*)[keyDict objectForKey:@"token"] componentsSeparatedByString:@";"];
    key = keyParts[0];
    _keyText.text = key;
    _keyText.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.800];
    
    NSError *err;
    NSData  *cipherData = [RNEncryptor encryptData:[password dataUsingEncoding:NSUTF8StringEncoding]
                                  withSettings:kRNCryptorAES256Settings
                                      password:key
                                         error:&err];
    cipher = [cipherData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    _cipherText.text = cipher;
    _cipherText.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.800];
    
    NSDictionary *tokenDict = [self retrieveJSONWithPost:[NSURL URLWithString:@"https://secure.schoolstatus.com/api/v3/auth/token.json"] andPostParams:[NSDictionary dictionaryWithObjectsAndKeys:username,@"username",cipher,@"password", nil]] ;
                                                                                                                                                        
    token = [tokenDict objectForKey:@"token"];
    _tokenText.text = [NSString stringWithFormat:@"%@", tokenDict];
    _tokenText.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.800];
}

#pragma mark - custom
-(NSDictionary*)retrieveJSONFromURL:(NSURL*)jsonURL {
    NSURLResponse *resp;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:jsonURL] returningResponse:&resp error:&error];
    
    if (error.localizedDescription) {
        _error.text = error.localizedDescription;
    }
    else {
        _error.text = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    
    NSError* localError;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError.localizedDescription) {
        _error.text = localError.localizedDescription;
    }
    
    return parsedObject;
    
}

-(NSDictionary*)retrieveJSONWithPost:(NSURL*)postURL andPostParams:(NSDictionary*)postParams {
    NSError *err;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:postParams options:0 error:&err];
    // Create the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLResponse *resp;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
    
    if (error.localizedDescription) {
        _error.text = error.localizedDescription;
    }
    else {
        _error.text = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    
    NSError* localError;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError.localizedDescription) {
        _error.text = localError.localizedDescription;
    }
    
    return parsedObject;

}

@end

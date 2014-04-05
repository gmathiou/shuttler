//
//  SH_SplashScreenViewController.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 14/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_SplashScreenViewController.h"
#import "Reachability.h"
#import "SH_Constants.h"
#import "SH_DataHandler.h"

@interface SH_SplashScreenViewController ()
@property NSMutableData *_responseData;
@property SH_DataHandler *dataHandler;
@property NSString *username;
@property NSString *passwordSHA;
@end

@implementation SH_SplashScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkNetworkConnection];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    _dataHandler = [SH_DataHandler sharedInstance];
    [self authenticateUser];
    }

-(void) authenticateUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password_sha = [defaults objectForKey:@"password_sha"];
    
    if(username && password_sha){
        _username = username;
        _passwordSHA = password_sha;
    } else {
        [self presentLogin:self];
    }

    
    NSString *requestURL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/authenticate/",Server_URL];
    
    //Construct the JSON here. Like string for now
    NSString *post = [NSString stringWithFormat: @"{\"email\":\"%@\",\"password\":\"%@\"}",
                      _username,
                      _passwordSHA];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:requestsTimeOut];
    [NSURLConnection connectionWithRequest:request delegate:self];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self presentLogin:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self._responseData = [[NSMutableData alloc] init];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    if(code == 200){
        _dataHandler.user.signedIn = YES;
        _dataHandler.user.username = _username;
        [self presentHome:self];
    } else {
        [self presentLogin:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self._responseData appendData:data];
}

-(void)checkNetworkConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"network_error", nil)]
                                           message:[NSString stringWithFormat:NSLocalizedString(@"no_internet", nil)]
                                          delegate:nil
                                 cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"all_right", nil)]
                                 otherButtonTitles:nil];
        [alert show];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentHome:(id)sender
{
    [self performSegueWithIdentifier:@"splashToHomeSegue" sender:sender];
}

- (IBAction)presentLogin:(id)sender
{
    [self performSegueWithIdentifier:@"splashToLoginSegue" sender:sender];
}


@end

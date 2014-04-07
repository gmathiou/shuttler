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
#import <FacebookSDK/FacebookSDK.h>

@interface SH_SplashScreenViewController ()
@property NSMutableData *_responseData;
@property SH_DataHandler *dataHandler;
@property NSString *username;
@property NSString *passwordSHA;
@property NSURLConnection *authenticateConnection;
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
    _facebookLoginView.readPermissions = @[@"email", @"basic_info"];
    if(_dataHandler.user.facebookLogedIn == NO){
        [self authenticateUser];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
        [_spinner stopAnimating];
        return;
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
    _authenticateConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(_dataHandler.user.facebookLogedIn == YES){
        [_spinner stopAnimating];
        return;
    }
    self._responseData = [[NSMutableData alloc] init];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    if(code == 200){
        _dataHandler.user.signedIn = YES;
        [_dataHandler.user setIdentification:_username];
        [_dataHandler.user setName:_username];
        [_dataHandler.user setPassword:_passwordSHA];
        [self presentHome:self];
    }
    [_spinner stopAnimating];
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

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    if(user.username == nil || _dataHandler.user.facebookLogedIn == YES)
        return;
    
    NSString *email = [user objectForKey:@"email"];
    NSString *password = [_dataHandler sha1:email];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:email forKey:@"username"];
    
    [defaults setObject:password forKey:@"password_sha"];
    
    [_dataHandler.user setFacebookLogedIn:YES];
    [_dataHandler.user setSignedIn:YES];
    [_dataHandler.user setIdentification:email];
    [_dataHandler.user setName:user.name];
    [_dataHandler.user setUsername:user.username];
    [_dataHandler.user setPassword:password];
    
    [defaults synchronize];
    [_spinner stopAnimating];
    [_authenticateConnection cancel];
    [self sendRegistrationRequest];
    [self presentHome:self];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(void)sendRegistrationRequest
{
    NSString *requestURL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/registration/",Server_URL];
    //Construct the JSON here. Like string for now
    NSString *post = [NSString stringWithFormat: @"{\"email\":\"%@\",\"password\":\"%@\"}",
                      _dataHandler.user.identification,
                      _dataHandler.user.password];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:requestsTimeOut];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (IBAction)loginButtonPressed:(id)sender {
}

- (IBAction)registerButtonPressed:(id)sender {
}

- (IBAction)goToSplash: (UIStoryboardSegue*) segue
{
}
@end

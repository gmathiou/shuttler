//
//  SH_ViewController.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 13/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_LoginViewController.h"
#import "SH_HomeViewController.h"
#import "Reachability.h"
#import "SH_DataHandler.h"
#import "SH_Constants.h"

@interface SH_LoginViewController ()
@property NSMutableData *_responseData;
@property SH_DataHandler *dataHandler;
@property NSString *inputUsername;
@property NSString *inputPasswordSHA;
@end

@implementation SH_LoginViewController

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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _dataHandler = [SH_DataHandler sharedInstance];
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

-(void)dismissKeyboard {
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self.formScrollView setContentOffset:CGPointZero animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        
        if([self fieldsValidation]){
            [self sendAuthenticationRequest];
        }
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentHome:(id)sender
{
    [self performSegueWithIdentifier:@"loginToHomeSegue" sender:sender];
}

- (IBAction)presentRegistration:(id)sender
{
    [self performSegueWithIdentifier:@"loginToRegistrationSegue" sender:sender];
}

- (IBAction)presentTutorial:(id)sender
{
    [self performSegueWithIdentifier:@"loginToTutorialSegue" sender:sender];
}

- (IBAction)signInButtonPressed:(id)sender
{
    if([self fieldsValidation])
        [self sendAuthenticationRequest];
}

-(void) sendAuthenticationRequest
{
    NSString *requestURL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/authenticate/",Server_URL];
    NSString *sha1Pass = [_dataHandler sha1:_passwordTextField.text];
    
    //Construct the JSON here. Like string for now
    NSString *post = [NSString stringWithFormat: @"{\"email\":\"%@\",\"password\":\"%@\"}",
                      _usernameTextField.text,
                      sha1Pass];
    
    _inputUsername =_usernameTextField.text;
    _inputPasswordSHA = sha1Pass;
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:requestsTimeOut];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    [_signInLoadingIndicator setHidden:NO];
}

-(BOOL)fieldsValidation
{
    if(_usernameTextField.text.length == 0 || _passwordTextField.text.length == 0){
        [_errorMsgLabel setText:[NSString stringWithFormat:NSLocalizedString(@"fillin_all_fields", nil)]];
        [_signInLoadingIndicator setHidden:YES];
        [_errorMsgImage setHidden:NO];
        [_errorMsgLabel setHidden:NO];
        return false;
    }
    return true;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(_usernameTextField.text.length == 0 || _passwordTextField.text.length == 0){
        [_errorMsgLabel setText:[NSString stringWithFormat:NSLocalizedString(@"fillin_all_fields", nil)]];
    } else {
        [_errorMsgLabel setText:[NSString stringWithFormat:NSLocalizedString(@"connection_error", nil)]];
    }
    [_signInLoadingIndicator setHidden:YES];
    [_errorMsgImage setHidden:NO];
    [_errorMsgLabel setHidden:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self._responseData = [[NSMutableData alloc] init];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    if(code == 200){
        [_errorMsgImage setHidden:YES];
        [_errorMsgLabel setHidden:YES];
        [_dataHandler.user setSignedIn:YES];
        [_dataHandler.user setIdentification:_usernameTextField.text];
        [_dataHandler.user setName:_usernameTextField.text];
        [_dataHandler.user setPassword:_inputPasswordSHA];
        
        // Store the data
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:_inputUsername forKey:@"username"];
        [defaults setObject:_inputPasswordSHA forKey:@"password_sha"];
        [defaults synchronize];
        
        [_passwordTextField setText:@""];
        
        [self presentHome:self];
    } else {
        [_errorMsgLabel setText:[NSString stringWithFormat:NSLocalizedString(@"account_not_exists", nil)]];
        [_errorMsgImage setHidden:NO];
        [_errorMsgLabel setHidden:NO];
    }
    [_signInLoadingIndicator setHidden:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self._responseData appendData:data];
}

- (IBAction)goToLogin: (UIStoryboardSegue*) segue
{
}

- (IBAction)registerButtonPressed:(id)sender {
    [self presentRegistration:self];
}
@end

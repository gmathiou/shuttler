//
//  SH_RegisterViewController.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 5/4/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_RegisterViewController.h"
#import "SH_HomeViewController.h"
#import "Reachability.h"
#import <CommonCrypto/CommonDigest.h>
#import "SH_DataHandler.h"

@interface SH_RegisterViewController ()
@property NSMutableData *_responseData;
@property SH_DataHandler *dataHandler;
@property NSString *inputUsername;
@property NSString *inputPasswordSHA;
@end

@implementation SH_RegisterViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)deregisterFromKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


-(void)dismissKeyboard {
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint buttonOrigin = self.registerButton.frame.origin;
    CGFloat buttonHeight = self.registerButton.frame.size.height;
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight + 10);
        [self.formScrollView setContentOffset:scrollPoint animated:YES];
    }
    
    //If the error msgs are visible, hide them
    [_errorMsgImage setHidden:YES];
    [_errorMsgLabel setHidden:YES];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    [self.formScrollView setContentOffset:CGPointZero animated:NO];
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
        if(_usernameTextField.text.length > 0 && _passwordTextField.text.length >0){
            [self sendRegistrationRequest];
        }
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)presentHome:(id)sender
{
    [self performSegueWithIdentifier:@"registrationToHomeSegue" sender:sender];
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
    [_registerLoadingIndicator setHidden:YES];
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
        [_dataHandler.user setPassword:_inputPasswordSHA];
        
        // Store the data
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:_inputUsername forKey:@"username"];
        [defaults setObject:_inputPasswordSHA forKey:@"password_sha"];
        [defaults synchronize];
        
        [_passwordTextField setText:@""];
        
        [self presentHome:self];
    } else {
        [_errorMsgLabel setText:[NSString stringWithFormat:NSLocalizedString(@"account_exists", nil)]];
        [_errorMsgImage setHidden:NO];
        [_errorMsgLabel setHidden:NO];
    }
    [_registerLoadingIndicator setHidden:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self._responseData appendData:data];
}


- (IBAction)registerButtonPressed:(id)sender {
    [self sendRegistrationRequest];
}

-(void)sendRegistrationRequest
{
    if(_usernameTextField.text.length == 0 || _passwordTextField.text.length == 0){
        [_errorMsgLabel setText:[NSString stringWithFormat:NSLocalizedString(@"fillin_all_fields", nil)]];
        [_errorMsgImage setHidden:NO];
        [_errorMsgLabel setHidden:NO];
        return;
    }
    
    //Username cannot contain the @ symbol
    if([_usernameTextField.text rangeOfString:@""].location != NSNotFound){
        [_errorMsgLabel setText:[NSString stringWithFormat:NSLocalizedString(@"at_forbiden", nil)]];
        [_errorMsgImage setHidden:NO];
        [_errorMsgLabel setHidden:NO];
        return;
    }
    
    NSString *requestURL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/registration/",Server_URL];
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
    
    [_registerLoadingIndicator setHidden:NO];
}

@end

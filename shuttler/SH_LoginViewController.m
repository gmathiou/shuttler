//
//  SH_ViewController.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 13/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_LoginViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "SH_HomeViewController.h"
#import "Reachability.h"

static NSString * const kClientId = @"980435887734-8d0ri4s01lr8sf4i722a4fuf03elrnjd.apps.googleusercontent.com";

@interface SH_LoginViewController ()

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    //signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    signIn.scopes = @[ @"profile" ];            // "profile" scope

    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    
    self.signInButton.colorScheme = 1;
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

-(void)viewDidAppear:(BOOL)animated
{
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        _signInButton.hidden = YES;
        [self presentHome:self];
    } else {
        _signInButton.hidden = NO;
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

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (error) {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"network_error", nil)]
                                           message:[NSString stringWithFormat:NSLocalizedString(@"no_internet", nil)]
                                          delegate:nil
                                 cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"all_right", nil)]
                                 otherButtonTitles:nil];
        [alert show];
    } else {
        if ([[GPPSignIn sharedInstance] authentication]) {
            // The user is signed in.
            _signInButton.hidden = YES;
            [self presentHome:self];
        }
    }
}

- (IBAction)presentHome:(id)sender
{
    [self performSegueWithIdentifier:@"loginToHomeSegue" sender:sender];
}

- (IBAction)presentTutorial:(id)sender
{
    [self performSegueWithIdentifier:@"loginToTutorialSegue" sender:sender];
}

- (IBAction)goToLogin: (UIStoryboardSegue*) segue
{
}

@end

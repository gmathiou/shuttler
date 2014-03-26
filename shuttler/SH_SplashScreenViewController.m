//
//  SH_SplashScreenViewController.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 14/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_SplashScreenViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

static NSString * const kClientId = @"980435887734-8d0ri4s01lr8sf4i722a4fuf03elrnjd.apps.googleusercontent.com";

@interface SH_SplashScreenViewController ()

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
    
    BOOL signInStatus = [signIn trySilentAuthentication];
    
    //Silent authenticate failed, Go to login screen
    if(signInStatus == NO){
        [self presentLogin:self];
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
    /* Use these lines if you want some delay */
//    NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 1 ];
//    [NSThread sleepUntilDate:future];
    
    if(error){
        [self presentLogin:self];
    } else {
        if ([[GPPSignIn sharedInstance] authentication]) {
            [self presentHome:self];
        }
    }
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

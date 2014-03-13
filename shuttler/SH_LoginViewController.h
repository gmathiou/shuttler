//
//  SH_ViewController.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 13/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@class GPPSignInButton;

@interface SH_LoginViewController : UIViewController <GPPSignInDelegate>
@property (weak, nonatomic) IBOutlet GPPSignInButton *signInButton;

@end


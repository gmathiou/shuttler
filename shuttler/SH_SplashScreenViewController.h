//
//  SH_SplashScreenViewController.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 14/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

@interface SH_SplashScreenViewController : UIViewController  <GPPSignInDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

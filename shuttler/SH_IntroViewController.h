//
//  SH_LoginTutorialViewController.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 19/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SH_IntroPageViewController.h"

@interface SH_IntroViewController : UIViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
- (IBAction)skipIntroButtonPressed:(id)sender;
@end

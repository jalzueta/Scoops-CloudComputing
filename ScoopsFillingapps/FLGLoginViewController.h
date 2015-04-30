//
//  FLGLoginViewController.h
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 29/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

@import UIKit;

typedef void (^profileCompletion)(NSDictionary* profInfo);
typedef void (^completeBlock)(NSArray* results);
typedef void (^completeOnError)(NSError *error);
typedef void (^completionWithURL)(NSURL *theUrl, NSError *error);

@interface FLGLoginViewController : UIViewController

- (IBAction)skipLogin:(id)sender;
- (IBAction)login:(id)sender;

@end

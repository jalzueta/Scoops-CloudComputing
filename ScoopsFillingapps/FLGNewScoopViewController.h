//
//  FLGNewScoopViewController.h
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 30/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

@import UIKit;
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "GAITrackedViewController.h"

@interface FLGNewScoopViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UILabel *scoopAuthorView;
@property (weak, nonatomic) IBOutlet UIImageView *scoopAuthorImageView;
@property (weak, nonatomic) IBOutlet UITextField *scoopTitleView;
@property (weak, nonatomic) IBOutlet UITextView *scoopTextView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBarView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIControl *loadingVeloView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityView;

- (id) initWithUser: (id) userInfo
             client: (MSClient *) client;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)addScoop:(id)sender;
- (IBAction)myScoops:(id)sender;
- (IBAction)allScoops:(id)sender;
- (IBAction)takePhoto:(id)sender;

@end

//
//  FLGNewScoopViewController.h
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 30/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

@import UIKit;
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@interface FLGNewScoopViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *scoopAuthorView;
@property (weak, nonatomic) IBOutlet UIImageView *scoopAuthorImageView;
@property (weak, nonatomic) IBOutlet UITextField *scoopTitleView;
@property (weak, nonatomic) IBOutlet UITextView *scoopTextView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBarView;

- (id) initWithUser: (id) userInfo
             client: (MSClient *) client;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)addScoop:(id)sender;
- (IBAction)myScoops:(id)sender;
- (IBAction)takePhoto:(id)sender;

@end
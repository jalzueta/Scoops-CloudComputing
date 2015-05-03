//
//  FLGDetalleMyScoopViewController.h
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 1/5/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

@import UIKit;
@class Scoop;
@class FLGDetalleMyScoopViewController;
#import "GAITrackedViewController.h"

@protocol FLGDetalleMyScoopViewControllerDelegate <NSObject>

- (void) detalleMyScoopviewController: (FLGDetalleMyScoopViewController *)detalleMyScoopviewController didPublishNewWithId: (NSString *) scoopId;

@end

@interface FLGDetalleMyScoopViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UITextField *authorView;
@property (weak, nonatomic) IBOutlet UITextField *scoreView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *statusView;
@property (weak, nonatomic) IBOutlet UIButton *publicarButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIControl *loadingVeloView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityView;

@property (nonatomic, strong) Scoop *scoop;
@property (weak, nonatomic) id<FLGDetalleMyScoopViewControllerDelegate> delegate;

- (id) initWithModel: (Scoop *) scoop;

- (IBAction)publish:(id)sender;

@end
